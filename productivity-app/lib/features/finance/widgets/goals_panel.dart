import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/local/database.dart';
import '../providers/finance_providers.dart';
import 'add_goal_dialog.dart';

class GoalsPanel extends ConsumerWidget {
  const GoalsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider).goals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GoalsPanelHeader(
          onAdd: () => showDialog(
            context: context,
            useRootNavigator: false,
            builder: (_) => const AddGoalDialog(),
          ),
        ),
        Expanded(
          child: goals.isEmpty
              ? _EmptyGoals()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
                  itemCount: goals.length,
                  itemBuilder: (_, i) => _GoalCard(goal: goals[i]),
                ),
        ),
      ],
    );
  }
}

class _GoalsPanelHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _GoalsPanelHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 20, 12),
      child: Row(
        children: [
          Text('OBIETTIVI FINANZIARI', style: AppTextStyles.headingSection),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            color: AppColors.primary,
            tooltip: 'Nuovo obiettivo',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final done = goal.isCompleted || goal.currentAmount >= goal.targetAmount;
    final progressColor = done ? AppColors.income : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (done)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_circle,
                      size: 15, color: AppColors.income),
                ),
              Expanded(
                child: Text(goal.name,
                    style: AppTextStyles.headingCard,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => _onAction(context, ref, v),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'update', child: Text('Aggiorna importo')),
                  if (!done)
                    const PopupMenuItem(
                        value: 'complete', child: Text('Segna completato')),
                  const PopupMenuItem(
                      value: 'delete', child: Text('Elimina')),
                ],
                icon: const Icon(Icons.more_vert,
                    size: 16, color: AppColors.textDisabled),
                padding: EdgeInsets.zero,
                splashRadius: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatCurrency(goal.currentAmount)} / ${formatCurrency(goal.targetAmount)}',
                style: AppTextStyles.amountSmall,
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.label.copyWith(
                  color: done ? AppColors.income : AppColors.textSecondary,
                  fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
          if (goal.deadline != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 11, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Scadenza: ${formatDateMedium(goal.deadline!)}',
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ],
          if (goal.note != null && goal.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(goal.note!,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  void _onAction(BuildContext context, WidgetRef ref, String value) {
    final notifier = ref.read(goalsProvider.notifier);
    switch (value) {
      case 'update':
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (_) => _UpdateProgressDialog(
            goalId: goal.id,
            goalName: goal.name,
            currentAmount: goal.currentAmount,
          ),
        );
      case 'complete':
        notifier.completeGoal(goal.id);
      case 'delete':
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Elimina obiettivo'),
            content: Text('Eliminare "${goal.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  notifier.deleteGoal(goal.id);
                },
                child: Text('Elimina',
                    style: TextStyle(color: AppColors.expense)),
              ),
            ],
          ),
        );
    }
  }
}

class _UpdateProgressDialog extends ConsumerStatefulWidget {
  final String goalId;
  final String goalName;
  final double currentAmount;
  const _UpdateProgressDialog({
    required this.goalId,
    required this.goalName,
    required this.currentAmount,
  });

  @override
  ConsumerState<_UpdateProgressDialog> createState() =>
      _UpdateProgressDialogState();
}

class _UpdateProgressDialogState
    extends ConsumerState<_UpdateProgressDialog> {
  late final TextEditingController _amountCtrl;
  String? _selectedAccountId;
  bool _deductFromAccount = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final delta =
        double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (delta == null || delta <= 0) return;
    setState(() => _saving = true);

    final newTotal = widget.currentAmount + delta;
    await ref
        .read(goalsProvider.notifier)
        .updateProgress(widget.goalId, newTotal);

    if (_deductFromAccount && _selectedAccountId != null) {
      await ref.read(financeProvider.notifier).addTransaction(
            accountId: _selectedAccountId!,
            amount: delta,
            type: 'expense',
            category: 'Obiettivi',
            date: DateTime.now(),
            note: widget.goalName,
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(financeProvider).accounts;

    return Dialog(
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aggiungi importo',
                  style: AppTextStyles.headingCard.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                'Totale attuale: ${formatCurrency(widget.currentAmount)}',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Importo da aggiungere',
                  prefixText: '€ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              // Optional account deduction
              if (accounts.isNotEmpty) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _deductFromAccount,
                      onChanged: (v) => setState(() {
                        _deductFromAccount = v ?? false;
                        if (!_deductFromAccount) {
                          _selectedAccountId = null;
                        }
                      }),
                    ),
                    const Text('Scala da un conto bancario'),
                  ],
                ),
                if (_deductFromAccount) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'Conto',
                      isDense: true,
                    ),
                    items: accounts
                        .map((a) => DropdownMenuItem(
                              value: a.account.id,
                              child: Text(a.account.name),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedAccountId = v),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Salva'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 36, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text('Nessun obiettivo', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Text('Usa + per aggiungerne uno', style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
