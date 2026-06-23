import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/entertainment_providers.dart';
import '../state/games_state.dart';

class ImportGamesDialog extends ConsumerStatefulWidget {
  const ImportGamesDialog({super.key});

  @override
  ConsumerState<ImportGamesDialog> createState() => _ImportGamesDialogState();
}

class _ImportGamesDialogState extends ConsumerState<ImportGamesDialog> {
  final _textCtrl = TextEditingController();
  List<({String title, List<GameObjective> objectives})> _parsed = [];
  bool _importing = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _parse() {
    final lines = _textCtrl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    setState(() {
      _parsed = lines.map(_parseLine).toList();
    });
  }

  // Format: "Title (achieved_obj) prossimo (next_obj) prossimo (future_obj)"
  // First () = done=true (current status), rest = done=false (upcoming)
  static ({String title, List<GameObjective> objectives}) _parseLine(
      String line) {
    final chunks =
        line.split(RegExp(r'\s+prossimo\s+', caseSensitive: false));
    final parenRegex = RegExp(r'\(([^)]+)\)');

    String title = '';
    final objectives = <GameObjective>[];

    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i].trim();
      final match = parenRegex.firstMatch(chunk);
      if (match != null) {
        if (i == 0) {
          title = chunk.substring(0, match.start).trim();
        }
        final desc = match.group(1)!.trim();
        if (desc.isNotEmpty) {
          objectives.add(GameObjective(desc: desc, done: i == 0));
        }
      } else if (i == 0) {
        title = chunk;
      }
    }

    if (title.isEmpty) title = line.trim();
    // Strip leading bullet/list markers like "- ", "• ", "* "
    title = title.replaceFirst(RegExp(r'^[-•*]+\s*'), '').trim();
    return (title: title, objectives: objectives);
  }

  Future<void> _import() async {
    if (_parsed.isEmpty) return;
    setState(() => _importing = true);
    final notifier = ref.read(gamesProvider.notifier);
    for (final g in _parsed) {
      if (g.title.isNotEmpty) {
        await notifier.addGame(g.title, objectives: g.objectives);
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: screenHeight * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + textarea (altezza fissa) ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Importa giochi',
                      style: AppTextStyles.headingCard.copyWith(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    'Formato: Titolo (obiettivo raggiunto) prossimo (obiettivo futuro)',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textCtrl,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          'Zelda BOTW (Prima partita) prossimo (100%)\nDark Souls (Prima run)',
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _parse,
                    icon: const Icon(Icons.preview_rounded, size: 16),
                    label: const Text('Anteprima'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero),
                  ),
                ],
              ),
            ),
            // ── Lista anteprima (flessibile, non trabocca) ───────────────
            if (_parsed.isNotEmpty) ...[
              const Divider(color: AppColors.divider),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                  itemCount: _parsed.length,
                  itemBuilder: (_, i) {
                    final g = _parsed[i];
                    final doneCount =
                        g.objectives.where((o) => o.done).length;
                    final total = g.objectives.length;
                    final hasPending = g.objectives.any((o) => !o.done);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.videogame_asset_rounded,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(g.title,
                                style: AppTextStyles.bodyRegular.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ),
                          if (total > 0) ...[
                            Text('$doneCount/$total obiettivi',
                                style: AppTextStyles.label.copyWith(
                                    color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (hasPending
                                      ? AppColors.primary
                                      : AppColors.income)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              hasPending ? 'In corso' : 'Completato',
                              style: AppTextStyles.label.copyWith(
                                color: hasPending
                                    ? AppColors.primary
                                    : AppColors.income,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            // ── Footer con bottoni (altezza fissa) ──────────────────────
            const Divider(color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
              child: Row(
                children: [
                  Text(
                    _parsed.isEmpty
                        ? 'Nessun gioco trovato'
                        : '${_parsed.length} giochi trovati',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annulla'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: (_importing || _parsed.isEmpty) ? null : _import,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _importing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_parsed.isEmpty
                            ? 'Importa'
                            : 'Importa ${_parsed.length} giochi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
