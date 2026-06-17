import '../../../data/local/database.dart';
import '../models/account_with_balance.dart';

class _Sentinel {
  const _Sentinel();
}

class FinanceState {
  final List<AccountWithBalance> accounts;
  final String? selectedAccountId;
  final List<TransactionEntry> transactions;
  final bool isLoading;

  const FinanceState({
    this.accounts = const [],
    this.selectedAccountId,
    this.transactions = const [],
    this.isLoading = false,
  });

  double get totalBalance =>
      accounts.fold(0.0, (sum, a) => sum + a.balance);

  AccountWithBalance? get selectedAccount =>
      accounts.where((a) => a.account.id == selectedAccountId).firstOrNull;

  FinanceState copyWith({
    List<AccountWithBalance>? accounts,
    Object? selectedAccountId = const _Sentinel(),
    List<TransactionEntry>? transactions,
    bool? isLoading,
  }) {
    return FinanceState(
      accounts: accounts ?? this.accounts,
      selectedAccountId: selectedAccountId is _Sentinel
          ? this.selectedAccountId
          : selectedAccountId as String?,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
