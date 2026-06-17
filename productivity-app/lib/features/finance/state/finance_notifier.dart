import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/local/database.dart';
import '../models/account_with_balance.dart';
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
      final withBalances = await _computeBalances(accountList);

      String? selectedId = state.selectedAccountId;
      if (selectedId == null && withBalances.isNotEmpty) {
        selectedId = withBalances.first.account.id;
      } else if (selectedId != null &&
          !withBalances.any((a) => a.account.id == selectedId)) {
        selectedId =
            withBalances.isNotEmpty ? withBalances.first.account.id : null;
      }

      state = state.copyWith(
          accounts: withBalances, selectedAccountId: selectedId);

      if (selectedId != null) _subscribeToTransactions(selectedId);
    });
  }

  void _subscribeToTransactions(String accountId) {
    _transactionsSub?.cancel();
    _transactionsSub =
        _db.watchTransactionsByAccount(accountId).listen((txList) async {
      state = state.copyWith(transactions: txList);
      await _refreshBalances();
    });
  }

  Future<List<AccountWithBalance>> _computeBalances(
      List<Account> accountList) async {
    return Future.wait(accountList.map((a) async {
      final txList = await _db.getTransactionsByAccount(a.id);
      return AccountWithBalance(
          account: a, balance: _balance(a.openingBalance, txList));
    }));
  }

  Future<void> _refreshBalances() async {
    final updated =
        await _computeBalances(state.accounts.map((a) => a.account).toList());
    state = state.copyWith(accounts: updated);
  }

  double _balance(double opening, List<TransactionEntry> txList) {
    return txList.fold(
        opening, (sum, t) => t.type == 'income' ? sum + t.amount : sum - t.amount);
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
    AppLogger.instance
        .info('Conto aggiunto: $name (saldo iniziale: €$openingBalance)');
    await _db.upsertAccount(AccountsCompanion.insert(
      name: name,
      colorValue: colorValue,
      openingBalance: Value(openingBalance),
    ));
  }

  Future<void> editAccount({
    required String id,
    required String name,
    required int colorValue,
    required double openingBalance,
  }) async {
    AppLogger.instance.info('Conto modificato: $name [id: $id]');
    await _db.upsertAccount(AccountsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      openingBalance: Value(openingBalance),
    ));
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
        'Movimento aggiunto: $type "$category" €$amount [conto: $accountId]');
    await _db.insertTransaction(TransactionEntriesCompanion.insert(
      accountId: accountId,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: Value(note),
    ));
  }

  Future<void> deleteTransaction(String id) async {
    AppLogger.instance.info('Movimento eliminato [id: $id]');
    await _db.deleteTransactionById(id);
  }

  @override
  void dispose() {
    _accountsSub?.cancel();
    _transactionsSub?.cancel();
    super.dispose();
  }
}
