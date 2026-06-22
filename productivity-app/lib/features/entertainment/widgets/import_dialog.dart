import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/tmdb_service.dart';
import '../providers/entertainment_providers.dart';

// ─── Parser ──────────────────────────────────────────────────────────────────

class _ParsedItem {
  final String title;
  final bool isTv;
  final int? season;
  final bool originalLanguage;

  const _ParsedItem({
    required this.title,
    required this.isTv,
    this.season,
    this.originalLanguage = false,
  });
}

class _SeriesEntry {
  final String title;
  final List<int> seasons;
  final bool originalLanguage;

  const _SeriesEntry(
      {required this.title,
      required this.seasons,
      required this.originalLanguage});
}

List<_ParsedItem> _parseList(String text) {
  final items = <_ParsedItem>[];
  for (var line in text.split('\n')) {
    // Strip markdown list markers and formatting
    line = line
        .trim()
        .replaceAll(RegExp(r'^[-*•]\s*'), '')
        .replaceAll('***', '')
        .replaceAll('**', '')
        .replaceAll('*', '')
        .trim();
    if (line.isEmpty) continue;

    final origLang = RegExp(r'\(lingua originale\)', caseSensitive: false)
        .hasMatch(line);
    line = line
        .replaceAll(RegExp(r'\(lingua originale\)', caseSensitive: false), '')
        .trim();

    // Detect season: "stagione N" or "sN" at end
    final seasonMatch =
        RegExp(r'\s+(?:stagione\s+(\d+)|s(\d+))$', caseSensitive: false)
            .firstMatch(line);

    if (seasonMatch != null) {
      final seasonNum =
          int.parse(seasonMatch.group(1) ?? seasonMatch.group(2)!);
      final seriesTitle = line.substring(0, seasonMatch.start).trim();
      if (seriesTitle.isNotEmpty) {
        items.add(_ParsedItem(
          title: seriesTitle,
          isTv: true,
          season: seasonNum,
          originalLanguage: origLang,
        ));
      }
    } else if (line.isNotEmpty) {
      items.add(_ParsedItem(
        title: line,
        isTv: false,
        originalLanguage: origLang,
      ));
    }
  }
  return items;
}

// Groups TV series entries by (normalized) title
Map<String, _SeriesEntry> _groupSeries(List<_ParsedItem> items) {
  final map = <String, _SeriesEntry>{};
  for (final item in items.where((i) => i.isTv)) {
    final key = item.title.toLowerCase().trim();
    final existing = map[key];
    final seasons = [
      ...?existing?.seasons,
      if (item.season != null) item.season!,
    ]..sort();
    map[key] = _SeriesEntry(
      title: existing?.title ?? item.title,
      seasons: seasons,
      originalLanguage: existing?.originalLanguage ?? item.originalLanguage,
    );
  }
  return map;
}

// ─── Import Dialog ───────────────────────────────────────────────────────────

class ImportDialog extends ConsumerStatefulWidget {
  const ImportDialog({super.key});

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  final _ctrl = TextEditingController();
  bool _running = false;
  int _total = 0;
  int _done = 0;
  int _failed = 0;
  String _currentTitle = '';
  bool _finished = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final apiKey = AppSettings.tmdbApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Configura prima la API key TMDb nelle impostazioni intrattenimento.')));
      return;
    }
    final tmdb = TmdbService(apiKey);
    final text = _ctrl.text;
    if (text.trim().isEmpty) return;

    final parsed = _parseList(text);
    final movies = parsed.where((i) => !i.isTv).toList();
    final seriesMap = _groupSeries(parsed);
    _total = movies.length + seriesMap.length;
    _done = 0;
    _failed = 0;
    _finished = false;
    setState(() => _running = true);

    // Import movies
    for (final m in movies) {
      if (!mounted) return;
      setState(() => _currentTitle = m.title);
      try {
        final results = await tmdb.searchMovies(m.title);
        if (results.isNotEmpty) {
          final details = await tmdb.getMovieDetails(results.first.id);
          if (details != null) {
            await ref.read(moviesProvider.notifier).addFromTmdb(
                  details,
                  status: 'watched',
                  inOriginalLanguage: m.originalLanguage,
                );
          } else {
            await ref.read(moviesProvider.notifier).addManual(m.title,
                inOriginalLanguage: m.originalLanguage);
          }
        } else {
          await ref.read(moviesProvider.notifier).addManual(m.title,
              inOriginalLanguage: m.originalLanguage);
          _failed++;
        }
      } catch (_) {
        await ref.read(moviesProvider.notifier).addManual(m.title,
            inOriginalLanguage: m.originalLanguage);
        _failed++;
      }
      _done++;
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Import TV series
    for (final entry in seriesMap.values) {
      if (!mounted) return;
      setState(() => _currentTitle = entry.title);
      try {
        final results = await tmdb.searchTv(entry.title);
        if (results.isNotEmpty) {
          final details = await tmdb.getTvDetails(results.first.id);
          if (details != null) {
            await ref.read(tvProvider.notifier).addFromTmdb(
                  details,
                  entry.seasons,
                  status: 'watching',
                  inOriginalLanguage: entry.originalLanguage,
                );
          } else {
            await ref.read(tvProvider.notifier).addManual(
                  entry.title,
                  entry.seasons,
                  inOriginalLanguage: entry.originalLanguage,
                );
          }
        } else {
          await ref.read(tvProvider.notifier).addManual(
                entry.title,
                entry.seasons,
                inOriginalLanguage: entry.originalLanguage,
              );
          _failed++;
        }
      } catch (_) {
        await ref.read(tvProvider.notifier).addManual(
              entry.title,
              entry.seasons,
              inOriginalLanguage: entry.originalLanguage,
            );
        _failed++;
      }
      _done++;
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Importa lista',
                  style: AppTextStyles.headingCard
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Incolla la lista. Formato: una voce per riga. Serie TV con "s1"/"stagione 1" alla fine.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (!_running) ...[
                TextField(
                  controller: _ctrl,
                  maxLines: 14,
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.bodySmall
                      .copyWith(fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText:
                        '- Breaking Bad stagione 1\n- Oppenheimer\n- Squid game s1 (lingua originale)',
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                  ),
                ),
              ] else ...[
                // Progress
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _total > 0 ? _done / _total : 0,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                if (!_finished)
                  Row(
                    children: [
                      const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _currentTitle,
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('$_done / $_total',
                          style: AppTextStyles.label),
                    ],
                  ),
                if (_finished) ...[
                  Row(children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.income, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Importazione completata: $_done aggiunt${_done == 1 ? "o" : "i"}${_failed > 0 ? ", $_failed senza metadati" : ""}.',
                      style: AppTextStyles.bodyRegular
                          .copyWith(color: AppColors.income),
                    ),
                  ]),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_finished)
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Chiudi'),
                    )
                  else if (!_running) ...[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annulla')),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _ctrl.text.trim().isEmpty ? null : _run,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Importa'),
                    ),
                  ] else
                    TextButton(
                        onPressed: null,
                        child: const Text('Importazione in corso...')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
