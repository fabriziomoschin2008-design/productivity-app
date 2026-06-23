import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/entertainment_providers.dart';
import '../state/games_state.dart';
import 'game_card.dart';
import 'media_card.dart' show StarRating;

class GameDetailDialog extends ConsumerStatefulWidget {
  final Game game;
  const GameDetailDialog({super.key, required this.game});

  @override
  ConsumerState<GameDetailDialog> createState() => _GameDetailState();
}

class _GameDetailState extends ConsumerState<GameDetailDialog> {
  late int? _rating;
  late String _status;

  @override
  void initState() {
    super.initState();
    _rating = widget.game.userRating;
    _status = widget.game.status;
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final current = ref
        .watch(gamesProvider)
        .games
        .firstWhere((x) => x.id == g.id, orElse: () => g);

    // Sync local status with provider (auto-updated by toggleObjective)
    if (_status != current.status) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _status = current.status);
      });
    }

    final objectives = decodeObjectives(current.objectives);
    final nextIndex = objectives.indexWhere((o) => !o.done);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title + status indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gameStatusColor(_status),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      current.title,
                      style: AppTextStyles.headingCard.copyWith(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (current.platform != null && current.platform!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(current.platform!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
              const SizedBox(height: 14),
              _GameStatusDrop(
                value: _status,
                onChanged: (v) async {
                  setState(() => _status = v);
                  await ref.read(gamesProvider.notifier).updateStatus(g.id, v);
                },
              ),
              const SizedBox(height: 12),
              Text('La tua valutazione', style: AppTextStyles.label),
              const SizedBox(height: 6),
              StarRating(
                value: _rating,
                onChanged: (r) async {
                  final val = r == 0 ? null : r;
                  setState(() => _rating = val);
                  await ref.read(gamesProvider.notifier).updateRating(g.id, val);
                },
              ),
              if (objectives.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),
                Text('Obiettivi', style: AppTextStyles.label),
                const SizedBox(height: 8),
                ...objectives.asMap().entries.map((entry) {
                  final i = entry.key;
                  final obj = entry.value;
                  final isNext = !obj.done && i == nextIndex;
                  return _ObjectiveRow(
                    desc: obj.desc,
                    done: obj.done,
                    isNext: isNext,
                    onTap: () =>
                        ref.read(gamesProvider.notifier).toggleObjective(g.id, i),
                  );
                }),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.expense, size: 18),
                    label: const Text('Elimina',
                        style: TextStyle(color: AppColors.expense)),
                    onPressed: () async {
                      final confirm = await _confirmDelete(context, current.title);
                      if (confirm == true && context.mounted) {
                        await ref.read(gamesProvider.notifier).delete(g.id);
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext ctx, String title) =>
      showDialog<bool>(
        context: ctx,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Elimina gioco'),
          content: Text('Vuoi eliminare "$title"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: const Text('Annulla')),
            TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.expense),
                child: const Text('Elimina')),
          ],
        ),
      );
}

class _ObjectiveRow extends StatelessWidget {
  final String desc;
  final bool done;
  final bool isNext;
  final VoidCallback onTap;

  const _ObjectiveRow({
    required this.desc,
    required this.done,
    required this.isNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.income
        : (isNext ? AppColors.primary : AppColors.textDisabled);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(
              done
                  ? Icons.check_circle_rounded
                  : (isNext
                      ? Icons.radio_button_unchecked_rounded
                      : Icons.circle_outlined),
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                desc,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: done ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            if (isNext) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'prossimo',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GameStatusDrop extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _GameStatusDrop({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value, // ignore: deprecated_member_use
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'playing', child: Text('In corso')),
        DropdownMenuItem(value: 'completed', child: Text('Completato')),
        DropdownMenuItem(value: 'want_to_play', child: Text('Da giocare')),
      ],
      onChanged: (v) => onChanged(v ?? value),
    );
  }
}
