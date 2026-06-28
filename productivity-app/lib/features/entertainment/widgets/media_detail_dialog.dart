// ignore_for_file: unused_element_parameter

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../data/tmdb_models.dart';
import '../data/tmdb_service.dart';
import '../providers/entertainment_providers.dart';
import 'media_card.dart';

class MovieDetailDialog extends ConsumerStatefulWidget {
  final Movy movie;
  const MovieDetailDialog({super.key, required this.movie});

  @override
  ConsumerState<MovieDetailDialog> createState() => _MovieDetailState();
}

class _MovieDetailState extends ConsumerState<MovieDetailDialog> {
  late String _status;
  late int? _rating;

  @override
  void initState() {
    super.initState();
    _status = widget.movie.status;
    _rating = widget.movie.userRating;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.movie;
    final posterUrl = m.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${m.posterPath}'
        : null;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 120,
                      height: 180,
                      child: posterUrl != null
                          ? Image.network(
                              posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholder(m.title),
                            )
                          : _placeholder(m.title),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: AppTextStyles.headingCard.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (m.releaseDate != null && m.releaseDate!.length >= 4)
                          Text(
                            m.releaseDate!.substring(0, 4),
                            style: AppTextStyles.bodySmall,
                          ),
                        if (m.genreNames != null &&
                            m.genreNames!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            m.genreNames!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (m.runtime != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${m.runtime} min',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                        if (m.voteAverage != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                m.voteAverage!.toStringAsFixed(1),
                                style: AppTextStyles.bodyRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(' / 10', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Status dropdown
                        _StatusDrop(
                          value: _status,
                          onChanged: (v) async {
                            setState(() => _status = v);
                            await ref
                                .read(moviesProvider.notifier)
                                .updateStatus(m.id, v);
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
                            await ref
                                .read(moviesProvider.notifier)
                                .updateRating(m.id, val);
                          },
                        ),
                        const SizedBox(height: 12),
                        _CopyLanguageButton(
                          isOl: m.inOriginalLanguage,
                          onPressed: () async {
                            TmdbMovieDetails? enDetails;
                            if (!m.inOriginalLanguage && m.tmdbId != null) {
                              final key = AppSettings.tmdbApiKey;
                              if (key != null && key.isNotEmpty) {
                                enDetails = await TmdbService(
                                  key,
                                ).getMovieDetailsEn(m.tmdbId!);
                              }
                            }
                            await ref
                                .read(moviesProvider.notifier)
                                .updateLanguagePreference(
                                  m,
                                  overrideDetails: enDetails,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    m.inOriginalLanguage
                                        ? 'Versione doppiata aggiornata.'
                                        : 'Versione in lingua originale aggiornata.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (m.overview != null && m.overview!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),
                Text(
                  m.overview!,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.expense,
                      size: 18,
                    ),
                    label: const Text(
                      'Elimina',
                      style: TextStyle(color: AppColors.expense),
                    ),
                    onPressed: () async {
                      final confirm = await _confirmDelete(context, m.title);
                      if (confirm == true && context.mounted) {
                        await ref.read(moviesProvider.notifier).delete(m.id);
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
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _placeholder(String title) => Container(
    color: AppColors.surfaceElevated,
    alignment: Alignment.center,
    child: Text(
      title.isNotEmpty ? title[0].toUpperCase() : '?',
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.primary.withValues(alpha: 0.4),
      ),
    ),
  );

  Future<bool?> _confirmDelete(BuildContext ctx, String title) =>
      showDialog<bool>(
        context: ctx,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Elimina film'),
          content: Text('Vuoi eliminare "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              child: const Text('Elimina'),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class TvDetailDialog extends ConsumerStatefulWidget {
  final TvSery series;
  const TvDetailDialog({super.key, required this.series});

  @override
  ConsumerState<TvDetailDialog> createState() => _TvDetailState();
}

class _TvDetailState extends ConsumerState<TvDetailDialog> {
  late int? _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.series.userRating;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.series;
    final current = ref
        .watch(tvProvider)
        .series
        .firstWhere((t) => t.id == s.id, orElse: () => s);
    final posterUrl = current.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${current.posterPath}'
        : null;
    final totalS = current.totalSeasons ?? 0;
    List<int> watched = [];
    try {
      watched = (jsonDecode(current.watchedSeasons) as List).cast<int>();
    } catch (_) {}

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 120,
                      height: 180,
                      child: posterUrl != null
                          ? Image.network(
                              posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _placeholder(current.title),
                            )
                          : _placeholder(current.title),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.title,
                          style: AppTextStyles.headingCard.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (current.firstAirDate != null &&
                            current.firstAirDate!.length >= 4)
                          Text(
                            current.firstAirDate!.substring(0, 4),
                            style: AppTextStyles.bodySmall,
                          ),
                        if (current.genreNames != null &&
                            current.genreNames!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            current.genreNames!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (current.voteAverage != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                current.voteAverage!.toStringAsFixed(1),
                                style: AppTextStyles.bodyRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(' / 10', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        _StatusDrop(
                          value: current.status,
                          onChanged: (v) async {
                            await ref
                                .read(tvProvider.notifier)
                                .updateStatus(s.id, v);
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
                            await ref
                                .read(tvProvider.notifier)
                                .updateRating(s.id, val);
                          },
                        ),
                        const SizedBox(height: 12),
                        _CopyLanguageButton(
                          isOl: current.inOriginalLanguage,
                          onPressed: () async {
                            TmdbTvDetails? enDetails;
                            if (!current.inOriginalLanguage &&
                                current.tmdbId != null) {
                              final key = AppSettings.tmdbApiKey;
                              if (key != null && key.isNotEmpty) {
                                enDetails = await TmdbService(
                                  key,
                                ).getTvDetailsEn(current.tmdbId!);
                              }
                            }
                            await ref
                                .read(tvProvider.notifier)
                                .updateLanguagePreference(
                                  current,
                                  overrideDetails: enDetails,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    current.inOriginalLanguage
                                        ? 'Versione doppiata aggiornata.'
                                        : 'Versione in lingua originale aggiornata.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (totalS > 0) ...[
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),
                Text('Stagioni viste', style: AppTextStyles.label),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: List.generate(totalS, (i) {
                    final sn = i + 1;
                    final sel = watched.contains(sn);
                    return FilterChip(
                      label: Text('Stagione $sn'),
                      selected: sel,
                      onSelected: (_) =>
                          ref.read(tvProvider.notifier).toggleSeason(s.id, sn),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      side: BorderSide(
                        color: sel ? AppColors.primary : AppColors.border,
                      ),
                    );
                  }),
                ),
              ],
              if (current.overview != null && current.overview!.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (totalS == 0) const Divider(color: AppColors.divider),
                const SizedBox(height: 8),
                Text(
                  current.overview!,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.expense,
                      size: 18,
                    ),
                    label: const Text(
                      'Elimina',
                      style: TextStyle(color: AppColors.expense),
                    ),
                    onPressed: () async {
                      final confirm = await _confirmDelete(context, s.title);
                      if (confirm == true && context.mounted) {
                        await ref.read(tvProvider.notifier).delete(s.id);
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
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _placeholder(String title) => Container(
    color: AppColors.surfaceElevated,
    alignment: Alignment.center,
    child: Text(
      title.isNotEmpty ? title[0].toUpperCase() : '?',
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.primary.withValues(alpha: 0.4),
      ),
    ),
  );

  Future<bool?> _confirmDelete(BuildContext ctx, String title) =>
      showDialog<bool>(
        context: ctx,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Elimina serie TV'),
          content: Text('Vuoi eliminare "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.expense),
              child: const Text('Elimina'),
            ),
          ],
        ),
      );
}

// ─── Shared ──────────────────────────────────────────────────────────────────

class _CopyLanguageButton extends StatelessWidget {
  final bool isOl;
  final bool alreadyExists;
  final VoidCallback? onPressed;

  const _CopyLanguageButton({
    required this.isOl,
    this.alreadyExists = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (alreadyExists) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            isOl
                ? 'Versione doppiata già presente'
                : 'Versione OL già presente',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
        ],
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.translate_rounded, size: 14),
      label: Text(isOl ? 'Passa a versione doppiata' : 'Passa a versione OL'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: AppTextStyles.label,
      ),
    );
  }
}

class _StatusDrop extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _StatusDrop({required this.value, required this.onChanged});

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
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'watched', child: Text('Visto')),
        DropdownMenuItem(value: 'watching', child: Text('In corso')),
        DropdownMenuItem(value: 'want_to_watch', child: Text('Da vedere')),
      ],
      onChanged: (v) => onChanged(v ?? value),
    );
  }
}
