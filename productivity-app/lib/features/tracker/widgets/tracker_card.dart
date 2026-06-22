import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/tracker_providers.dart';
import 'add_tracker_dialog.dart';

class TrackerCard extends ConsumerWidget {
  final Tracker tracker;

  const TrackerCard({super.key, required this.tracker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(tracker.colorValue);
    final progress =
        (tracker.currentValue / tracker.targetValue).clamp(0.0, 1.0);
    final unit = tracker.unit ?? '';
    final currentFmt = _fmt(tracker.currentValue);
    final targetFmt = _fmt(tracker.targetValue);

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2D2A26),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tracker.name,
                  style: AppTextStyles.bodyRegular
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tracker.completedCycles > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tracker.completedCycles} ${tracker.completedCycles == 1 ? "ciclo" : "cicli"}',
                    style: AppTextStyles.label.copyWith(color: color),
                  ),
                ),
              if (tracker.isDailyAutoIncrement)
                Tooltip(
                  message: 'Incremento automatico ogni giorno a mezzanotte',
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(Icons.update_rounded,
                        size: 15, color: AppColors.textSecondary),
                  ),
                ),
              _OverflowMenu(tracker: tracker),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 14),
          // Value display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: currentFmt,
                      style: AppTextStyles.headingCard.copyWith(color: color),
                    ),
                    TextSpan(
                      text: ' / $targetFmt${unit.isNotEmpty ? " $unit" : ""}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _ActionBtn(
                    icon: Icons.remove_rounded,
                    color: AppColors.textSecondary,
                    onTap: tracker.currentValue <= 0
                        ? null
                        : () => ref
                            .read(trackerProvider.notifier)
                            .decrement(tracker.id),
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.add_rounded,
                    color: color,
                    onTap: () =>
                        ref.read(trackerProvider.notifier).increment(tracker.id),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? color.withValues(alpha: 0.10)
              : AppColors.divider.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? color : AppColors.textDisabled,
        ),
      ),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  final Tracker tracker;

  const _OverflowMenu({required this.tracker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded,
          size: 18, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      offset: const Offset(0, 8),
      onSelected: (v) async {
        if (v == 'edit') {
          await showDialog<void>(
            context: context,
            builder: (_) => AddTrackerDialog(existing: tracker),
          );
        } else if (v == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Elimina tracker'),
              content: Text(
                  'Vuoi eliminare "${tracker.name}"? I dati non saranno recuperabili.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.expense),
                  child: const Text('Elimina'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await ref.read(trackerProvider.notifier).deleteTracker(tracker.id);
          }
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 16),
            SizedBox(width: 10),
            Text('Modifica'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 16, color: AppColors.expense),
            SizedBox(width: 10),
            Text('Elimina', style: TextStyle(color: AppColors.expense)),
          ]),
        ),
      ],
    );
  }
}
