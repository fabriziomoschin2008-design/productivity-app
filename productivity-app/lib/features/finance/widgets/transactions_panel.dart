import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/layout/adaptive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/local/database.dart';
import '../models/account_with_balance.dart';
import '../providers/finance_providers.dart';
import 'add_transaction_dialog.dart';
import 'charts_panel.dart';
import 'goals_panel.dart';

enum _FinanceView { transactions, charts, goals }

class TransactionsPanel extends ConsumerStatefulWidget {
  const TransactionsPanel({super.key});

  @override
  ConsumerState<TransactionsPanel> createState() => _TransactionsPanelState();
}

class _TransactionsPanelState extends ConsumerState<TransactionsPanel> {
  _FinanceView _view = _FinanceView.transactions;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(financeProvider.select((s) => s.selectedAccount));
    final transactions = ref.watch(
      financeProvider.select((s) => s.transactions),
    );

    return Column(
      children: [
        _TransactionsPanelHeader(
          account: account,
          view: _view,
          onViewChanged: (v) => setState(() => _view = v),
          onAddTransaction: account == null || _view == _FinanceView.goals
              ? null
              : () => showDialog(
                  context: context,
                  builder: (_) =>
                      AddTransactionDialog(accountId: account.account.id),
                ),
        ),
        const Divider(),
        Expanded(
          child: switch (_view) {
            _FinanceView.goals => const GoalsPanel(),
            _FinanceView.charts =>
              account == null
                  ? const _NoAccountSelected()
                  : ChartsPanel(transactions: transactions),
            _FinanceView.transactions =>
              account == null
                  ? const _NoAccountSelected()
                  : _TransactionList(transactions: transactions),
          },
        ),
      ],
    );
  }
}

class _TransactionsPanelHeader extends StatelessWidget {
  final AccountWithBalance? account;
  final _FinanceView view;
  final ValueChanged<_FinanceView> onViewChanged;
  final VoidCallback? onAddTransaction;

  const _TransactionsPanelHeader({
    required this.account,
    required this.view,
    required this.onViewChanged,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final compact = AdaptiveLayout.isPhone(context);
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          view == _FinanceView.goals
              ? 'Obiettivi'
              : (account?.account.name ?? ''),
          style: AppTextStyles.headingCard.copyWith(fontSize: 17),
        ),
        if (view != _FinanceView.goals && account != null) ...[
          const SizedBox(height: 4),
          Text(
            formatCurrency(account!.balance),
            style: AppTextStyles.displayAmount.copyWith(
              color: account!.balance < 0
                  ? AppColors.expense
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 20, 16, 16),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleSection,
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _ViewTabs(view: view, onChanged: onViewChanged),
                ),
                if (onAddTransaction != null) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onAddTransaction,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Movimento'),
                  ),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(child: titleSection),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _ViewTabs(view: view, onChanged: onViewChanged),
                ),
                if (onAddTransaction != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onAddTransaction,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Movimento'),
                  ),
                ],
              ],
            ),
    );
  }
}

class _ViewTabs extends StatelessWidget {
  final _FinanceView view;
  final ValueChanged<_FinanceView> onChanged;

  const _ViewTabs({required this.view, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tab(Icons.list_alt_outlined, 'Movimenti', _FinanceView.transactions),
        const SizedBox(width: 2),
        _tab(Icons.bar_chart_outlined, 'Grafici', _FinanceView.charts),
        const SizedBox(width: 2),
        _tab(Icons.flag_outlined, 'Obiettivi', _FinanceView.goals),
      ],
    );
  }

  Widget _tab(IconData icon, String label, _FinanceView target) {
    final active = view == target;
    return TextButton.icon(
      onPressed: () => onChanged(target),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: active ? AppColors.accent : AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  final List<TransactionEntry> transactions;
  const _TransactionList({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text('Nessun movimento', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Usa "Movimento" per aggiungerne uno',
              style: AppTextStyles.label,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const Divider(indent: 28, endIndent: 20),
      itemBuilder: (_, i) => _TransactionTile(
        tx: transactions[i],
        onDelete: () => ref
            .read(financeProvider.notifier)
            .deleteTransaction(transactions[i].id),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntry tx;
  final VoidCallback onDelete;

  const _TransactionTile({required this.tx, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final amountColor = isIncome ? AppColors.income : AppColors.expense;
    final amountText = (isIncome ? '+' : '-') + formatCurrency(tx.amount);
    final compact = AdaptiveLayout.isPhone(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 28,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDateShort(tx.date), style: AppTextStyles.label),
                const SizedBox(height: 1),
                Text(
                  tx.category,
                  style: AppTextStyles.bodyRegular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tx.note != null && tx.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      tx.note!,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountText,
            style: AppTextStyles.amountMedium.copyWith(color: amountColor),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            color: AppColors.textDisabled,
            tooltip: 'Elimina',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _NoAccountSelected extends StatelessWidget {
  const _NoAccountSelected();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 40,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 14),
          Text(
            'Seleziona un conto',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
