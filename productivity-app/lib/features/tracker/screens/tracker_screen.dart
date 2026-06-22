import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/tracker_providers.dart';
import '../widgets/add_tracker_dialog.dart';
import '../widgets/tracker_card.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackers = ref.watch(trackerProvider.select((s) => s.trackers));

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32).copyWith(top: 32, bottom: 20),
            child: Row(
              children: [
                Text('Tracker', style: AppTextStyles.headingCard.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const AddTrackerDialog(),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nuovo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Content
          Expanded(
            child: trackers.isEmpty
                ? const _EmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: trackers
                          .map((t) => TrackerCard(key: ValueKey(t.id), tracker: t))
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.track_changes_rounded,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('Nessun tracker ancora',
              style: AppTextStyles.bodyRegular.copyWith(fontSize: 15)
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            'Premi "Nuovo" per aggiungere la tua prima regola.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
