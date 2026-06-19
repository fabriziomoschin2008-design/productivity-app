import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/calendar_providers.dart';
import 'add_habit_dialog.dart';

const _categoryOrder = ['Mattina', 'Pomeriggio', 'Sera'];

class HabitsSidePanel extends ConsumerWidget {
  const HabitsSidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final byCategory = state.habitsByCategory;

    return SizedBox(
      width: 272,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text('Abitudini',
                    style: AppTextStyles.headingCard.copyWith(fontSize: 15)),
                const Spacer(),
                SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: () => showAddHabitDialog(context),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Aggiungi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.habits.isEmpty
                ? _EmptyHabits(onAdd: () => showAddHabitDialog(context))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      for (final cat in _categoryOrder)
                        if (byCategory.containsKey(cat)) ...[
                          _CategoryHeader(cat),
                          for (final h in byCategory[cat]!)
                            _HabitTile(
                              name: h.name,
                              onDelete: () => ref
                                  .read(calendarProvider.notifier)
                                  .deleteHabit(h.id),
                            ),
                        ],
                      // Eventuali categorie non standard
                      for (final cat in byCategory.keys
                          .where((c) => !_categoryOrder.contains(c)))
                        ...[
                          _CategoryHeader(cat),
                          for (final h in byCategory[cat]!)
                            _HabitTile(
                              name: h.name,
                              onDelete: () => ref
                                  .read(calendarProvider.notifier)
                                  .deleteHabit(h.id),
                            ),
                        ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  const _CategoryHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.textDisabled,
          letterSpacing: 0.8,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final String name;
  final VoidCallback onDelete;
  const _HabitTile({required this.name, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: const Icon(Icons.repeat, size: 16, color: AppColors.textDisabled),
      title: Text(name, style: AppTextStyles.bodySmall),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'delete') {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (dialogCtx) => AlertDialog(
                title: const Text('Elimina abitudine'),
                content: const Text(
                    'Vuoi eliminare questa abitudine? Verranno rimossi anche tutti i log.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('Annulla'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      onDelete();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense),
                    child: const Text('Elimina',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'delete', child: Text('Elimina')),
        ],
        icon: const Icon(Icons.more_vert, size: 14),
        iconColor: AppColors.textDisabled,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _EmptyHabits extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyHabits({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat, size: 36, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text('Nessuna abitudine',
              style: AppTextStyles.bodyRegular
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton(onPressed: onAdd, child: const Text('Aggiungi abitudine')),
        ],
      ),
    );
  }
}
