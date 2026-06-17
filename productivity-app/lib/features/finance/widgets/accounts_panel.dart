import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/account_with_balance.dart';
import '../providers/finance_providers.dart';
import 'add_account_dialog.dart';
import 'edit_account_dialog.dart';

class AccountsPanel extends ConsumerWidget {
  const AccountsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);

    return Container(
      width: 272,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            onAdd: () => showDialog(
              context: context,
              builder: (_) => const AddAccountDialog(),
            ),
          ),
          const Divider(),
          Expanded(
            child: state.accounts.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.accounts.length,
                    itemBuilder: (_, i) {
                      final awb = state.accounts[i];
                      return _AccountTile(
                        awb: awb,
                        selected: awb.account.id == state.selectedAccountId,
                        onTap: () => ref
                            .read(financeProvider.notifier)
                            .selectAccount(awb.account.id),
                        onEdit: () => showDialog(
                          context: context,
                          builder: (_) =>
                              EditAccountDialog(account: awb.account),
                        ),
                        onDelete: () => _confirmDelete(context, ref, awb),
                      );
                    },
                  ),
          ),
          const Divider(),
          _TotalRow(total: state.totalBalance),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, AccountWithBalance awb) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina conto'),
        content: Text(
            'Eliminare "${awb.account.name}" e tutti i suoi movimenti?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(financeProvider.notifier)
                  .deleteAccount(awb.account.id);
            },
            child:
                Text('Elimina', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _PanelHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Row(
        children: [
          Text('CONTI', style: AppTextStyles.headingSection),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            color: AppColors.primary,
            tooltip: 'Nuovo conto',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final AccountWithBalance awb;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountTile({
    required this.awb,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(awb.account.colorValue);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            border: selected
                ? const Border(
                    left: BorderSide(color: AppColors.accent, width: 3))
                : const Border(
                    left: BorderSide(color: Colors.transparent, width: 3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      awb.account.name,
                      style: AppTextStyles.headingCard.copyWith(
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatCurrency(awb.balance),
                      style: AppTextStyles.amountSmall.copyWith(
                        color: awb.balance < 0
                            ? AppColors.expense
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Modifica')),
                  PopupMenuItem(value: 'delete', child: Text('Elimina')),
                ],
                icon: const Icon(Icons.more_vert,
                    size: 16, color: AppColors.textDisabled),
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final double total;
  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTALE', style: AppTextStyles.headingSection),
          const SizedBox(height: 6),
          Text(
            formatCurrency(total),
            style: AppTextStyles.displayAmount.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 36, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text('Nessun conto', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text('Usa + per aggiungerne uno', style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
