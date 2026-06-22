import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/tmdb_service.dart';
import '../providers/entertainment_providers.dart';

class RefreshMetadataDialog extends ConsumerStatefulWidget {
  const RefreshMetadataDialog({super.key});

  @override
  ConsumerState<RefreshMetadataDialog> createState() =>
      _RefreshMetadataDialogState();
}

class _RefreshMetadataDialogState
    extends ConsumerState<RefreshMetadataDialog> {
  bool _finished = false;
  int _total = 0;
  int _done = 0;
  int _failed = 0;
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final apiKey = AppSettings.tmdbApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Configura prima la API key TMDb nelle impostazioni intrattenimento.')));
      return;
    }
    final tmdb = TmdbService(apiKey);

    final movies = ref
        .read(moviesProvider)
        .movies
        .where((m) => m.posterPath == null)
        .toList();
    final series = ref
        .read(tvProvider)
        .series
        .where((s) => s.posterPath == null)
        .toList();
    _total = movies.length + series.length;

    if (_total == 0) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tutti i poster sono già presenti.')));
      return;
    }

    setState(() {});

    for (final m in movies) {
      if (!mounted) return;
      setState(() => _currentTitle = m.title);
      try {
        if (m.tmdbId != null) {
          final d = await tmdb.getMovieDetails(m.tmdbId!);
          if (d != null) {
            await ref.read(moviesProvider.notifier).updateFromTmdb(m.id, d);
          } else {
            _failed++;
          }
        } else {
          final results = await tmdb.searchMovies(m.title);
          if (results.isNotEmpty) {
            final d = await tmdb.getMovieDetails(results.first.id);
            if (d != null) {
              await ref.read(moviesProvider.notifier).updateFromTmdb(m.id, d);
            } else {
              _failed++;
            }
          } else {
            _failed++;
          }
        }
      } catch (_) {
        _failed++;
      }
      _done++;
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 300));
    }

    for (final s in series) {
      if (!mounted) return;
      setState(() => _currentTitle = s.title);
      try {
        if (s.tmdbId != null) {
          final d = await tmdb.getTvDetails(s.tmdbId!);
          if (d != null) {
            await ref.read(tvProvider.notifier).updateFromTmdb(s.id, d);
          } else {
            _failed++;
          }
        } else {
          final results = await tmdb.searchTv(s.title);
          if (results.isNotEmpty) {
            final d = await tmdb.getTvDetails(results.first.id);
            if (d != null) {
              await ref.read(tvProvider.notifier).updateFromTmdb(s.id, d);
            } else {
              _failed++;
            }
          } else {
            _failed++;
          }
        }
      } catch (_) {
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
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aggiornamento poster',
                  style: AppTextStyles.headingCard
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _total > 0 ? _done / _total : null,
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
                    if (_total > 0)
                      Text('$_done / $_total', style: AppTextStyles.label),
                  ],
                ),
              if (_finished)
                Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.income, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Completato: $_done aggiornati'
                      '${_failed > 0 ? ', $_failed senza risultati' : ''}.',
                      style: AppTextStyles.bodyRegular
                          .copyWith(color: AppColors.income),
                    ),
                  ),
                ]),
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
                  else
                    TextButton(
                      onPressed: null,
                      child: const Text('Aggiornamento in corso...'),
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
