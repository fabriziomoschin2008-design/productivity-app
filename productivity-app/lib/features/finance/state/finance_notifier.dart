import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/local/database.dart';
import '../models/account_with_balance.dart';
import '../services/excel_service.dart';
import 'finance_state.dart';

class FinanceNotifier extends StateNotifier<FinanceState> {
  final AppDatabase _db;
  StreamSubscription<List<Account>>? _accountsSub;
  StreamSubscription<List<TransactionEntry>>? _transactionsSub;

  FinanceNotifier(this._db) : super(const FinanceState()) {
    _subscribeToAccounts();
  }

  void _subscribeToAccounts() {
    _accountsSub = _db.watchAccounts().listen((accountList) async {
      // Cancel transaction sub immediately when no accounts remain, to prevent
      // _refreshBalances from restoring deleted accounts via stale state.
      if (accountList.isEmpty) {
        _transactionsSub?.cancel();
        _transactionsSub = null;
      }

      final withBalances = await _computeBalances(accountList);

      String? selectedId = state.selectedAccountId;
      if (selectedId == null && withBalances.isNotEmpty) {
        selectedId = withBalances.first.account.id;
      } else if (selectedId != null &&
          !withBalances.any((a) => a.account.id == selectedId)) {
        selectedId = withBalances.isNotEmpty
            ? withBalances.first.account.id
            : null;
      }

      state = state.copyWith(
        accounts: withBalances,
        selectedAccountId: selectedId,
      );

      if (selectedId != null) {
        _subscribeToTransactions(selectedId);
      } else {
        _transactionsSub?.cancel();
        _transactionsSub = null;
      }
    });
  }

  void _subscribeToTransactions(String accountId) {
    _transactionsSub?.cancel();
    _transactionsSub = _db.watchTransactionsByAccount(accountId).listen((
      txList,
    ) async {
      state = state.copyWith(transactions: txList);
      await _refreshBalances();
    });
  }

  Future<List<AccountWithBalance>> _computeBalances(
    List<Account> accountList,
  ) async {
    return Future.wait(
      accountList.map((a) async {
        final txList = await _db.getTransactionsByAccount(a.id);
        return AccountWithBalance(
          account: a,
          balance: _balance(a.openingBalance, txList),
        );
      }),
    );
  }

  Future<void> _refreshBalances() async {
    final count = state.accounts.length;
    if (count == 0) return;
    final updated = await _computeBalances(
      state.accounts.map((a) => a.account).toList(),
    );
    // If accounts were added or removed while we were computing, discard this
    // stale result — _subscribeToAccounts will have already set the correct state.
    if (state.accounts.length != count) return;
    state = state.copyWith(accounts: updated);
  }

  double _balance(double opening, List<TransactionEntry> txList) {
    return txList.fold(
      opening,
      (sum, t) => t.type == 'income' ? sum + t.amount : sum - t.amount,
    );
  }

  void selectAccount(String accountId) {
    state = state.copyWith(selectedAccountId: accountId);
    _subscribeToTransactions(accountId);
  }

  Future<void> addAccount({
    required String name,
    required int colorValue,
    double openingBalance = 0,
  }) async {
    AppLogger.instance.info(
      'Conto aggiunto: $name (saldo iniziale: €$openingBalance)',
    );
    await _db.upsertAccount(
      AccountsCompanion.insert(
        name: name,
        colorValue: colorValue,
        openingBalance: Value(openingBalance),
      ),
    );
  }

  Future<void> editAccount({
    required String id,
    required String name,
    required int colorValue,
    required double openingBalance,
  }) async {
    AppLogger.instance.info('Conto modificato: $name [id: $id]');
    await _db.upsertAccount(
      AccountsCompanion(
        id: Value(id),
        name: Value(name),
        colorValue: Value(colorValue),
        openingBalance: Value(openingBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteAccount(String accountId) async {
    AppLogger.instance.info('Conto eliminato [id: $accountId]');
    await _db.deleteAccountWithTransactions(accountId);
  }

  Future<void> addTransaction({
    required String accountId,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    AppLogger.instance.info(
      'Movimento aggiunto: $type "$category" €$amount [conto: $accountId]',
    );
    await _db.insertTransaction(
      TransactionEntriesCompanion.insert(
        accountId: accountId,
        amount: amount,
        type: type,
        category: category,
        date: date,
        note: Value(note),
      ),
    );
    await _refreshBalances();
  }

  Future<void> deleteTransaction(String id) async {
    AppLogger.instance.info('Movimento eliminato [id: $id]');
    await _db.deleteTransactionById(id);
  }

  Future<
    ({
      bool success,
      String? error,
      List<String>? created,
      List<String>? updated,
    })
  >
  importAccountsFromExcel(File file) async {
    final existingAccounts = state.accounts.map((a) => a.account).toList();

    final result = await ExcelService.importAccounts(file, existingAccounts);

    if (result.error != null) {
      return (
        success: false,
        error: result.error,
        created: null,
        updated: null,
      );
    }

    try {
      final created = <String>[];

      for (final newAcc in result.newAccounts) {
        AppLogger.instance.info(
          'Conto importato: ${newAcc.name} (ID: ${newAcc.id})',
        );
        await _db.upsertAccount(
          AccountsCompanion(
            id: Value(newAcc.id),
            name: Value(newAcc.name),
            colorValue: Value(newAcc.colorValue),
            openingBalance: Value(newAcc.openingBalance),
            updatedAt: Value(DateTime.now()),
          ),
        );
        created.add(newAcc.id);
      }

      for (final accId in result.updatedAccountIds) {
        final updAcc = result.newAccounts.firstWhere(
          (a) => a.id == accId,
          orElse: () => result.newAccounts.isNotEmpty
              ? result.newAccounts.first
              : Account(
                  id: '',
                  name: '',
                  colorValue: 0,
                  openingBalance: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  deletedAt: null,
                ),
        );
        if (updAcc.name.isNotEmpty) {
          AppLogger.instance.info(
            'Conto aggiornato: ${updAcc.name} [ID: $accId]',
          );
          await editAccount(
            id: accId,
            name: updAcc.name,
            colorValue: updAcc.colorValue,
            openingBalance: updAcc.openingBalance,
          );
        }
      }

      for (final tx in result.transactions) {
        AppLogger.instance.info(
          'Movimento importato: ${tx.type} "${tx.category}" €${tx.amount}',
        );
        await _db.insertTransaction(
          TransactionEntriesCompanion.insert(
            id: Value(tx.id),
            accountId: tx.accountId,
            amount: tx.amount,
            type: tx.type,
            category: tx.category,
            date: tx.date,
            note: Value(tx.note),
          ),
        );
      }

      return (
        success: true,
        error: null,
        created: created,
        updated: result.updatedAccountIds,
      );
    } catch (e) {
      AppLogger.instance.error('Errore import Excel: $e');
      return (
        success: false,
        error: 'Errore durante import: $e',
        created: null,
        updated: null,
      );
    }
  }

  @override
  void dispose() {
    _accountsSub?.cancel();
    _transactionsSub?.cancel();
    super.dispose();
  }
}
