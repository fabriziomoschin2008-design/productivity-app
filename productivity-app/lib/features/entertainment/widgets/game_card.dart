import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../state/games_state.dart';

Color gameStatusColor(String status) => switch (status) {
      'completed' => AppColors.income,
      'want_to_play' => AppColors.accent,
      _ => AppColors.primary,
    };

String gameStatusLabel(String status) => switch (status) {
      'completed' => 'Completato',
      'want_to_play' => 'Da giocare',
      _ => 'In corso',
    };

class GameCard extends StatefulWidget {
  final Game game;
  final VoidCallback onTap;
  const GameCard({super.key, required this.game, required this.onTap});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final objectives = decodeObjectives(g.objectives);
    final doneCount = objectives.where((o) => o.done).length;
    final total = objectives.length;
    final nextObj = objectives.cast<GameObjective?>().firstWhere(
          (o) => o != null && !o.done,
          orElse: () => null,
        );
    final color = gameStatusColor(g.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? color.withValues(alpha: 0.5) : AppColors.border,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 4, color: color),
                  Expanded(
                    child: Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  g.title,
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusChip(g.status),
                            ],
                          ),
                          if (g.platform != null && g.platform!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              g.platform!,
                              style: AppTextStyles.label.copyWith(
                                  color: AppColors.textSecondary, fontSize: 10),
                            ),
                          ],
                          if (total > 0) ...[
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: doneCount / total,
                                      backgroundColor: AppColors.divider,
                                      valueColor: AlwaysStoppedAnimation(color),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$doneCount/$total',
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                          if (nextObj != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.arrow_right_rounded,
                                    size: 14, color: color),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    nextObj.desc,
                                    style: AppTextStyles.label
                                        .copyWith(color: color),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final color = gameStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        gameStatusLabel(status),
        style: AppTextStyles.label.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class GamesFilterRow extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const GamesFilterRow({super.key, required this.current, required this.onChanged});

  static const _filters = {
    'all': 'Tutti',
    'playing': 'In corso',
    'completed': 'Completati',
    'want_to_play': 'Da giocare',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.entries.map((e) {
          final active = current == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value,
                  style: AppTextStyles.label.copyWith(
                      color: active ? Colors.white : AppColors.textSecondary)),
              selected: active,
              onSelected: (_) => onChanged(e.key),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          );
        }).toList(),
      ),
    );
  }
}
