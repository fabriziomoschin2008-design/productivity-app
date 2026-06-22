import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
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
                          ? Image.network(posterUrl, fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _placeholder(m.title))
                          : _placeholder(m.title),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title,
                            style: AppTextStyles.headingCard.copyWith(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        if (m.releaseDate != null && m.releaseDate!.length >= 4)
                          Text(m.releaseDate!.substring(0, 4),
                              style: AppTextStyles.bodySmall),
                        if (m.genreNames != null &&
                            m.genreNames!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(m.genreNames!,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                        if (m.runtime != null) ...[
                          const SizedBox(height: 4),
                          Text('${m.runtime} min',
                              style: AppTextStyles.bodySmall),
                        ],
                        if (m.voteAverage != null) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(m.voteAverage!.toStringAsFixed(1),
                                style: AppTextStyles.bodyRegular
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text(' / 10',
                                style: AppTextStyles.bodySmall),
                          ]),
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
                        Text('La tua valutazione',
                            style: AppTextStyles.label),
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
                      ],
                    ),
                  ),
                ],
              ),
              if (m.overview != null && m.overview!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 12),
                Text(m.overview!,
                    style: AppTextStyles.bodyRegular
                        .copyWith(color: AppColors.textSecondary, height: 1.5)),
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
                      final confirm = await _confirmDelete(context, m.title);
                      if (confirm == true && context.mounted) {
                        await ref
                            .read(moviesProvider.notifier)
                            .delete(m.id);
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

  Widget _placeholder(String title) => Container(
        color: AppColors.surfaceElevated,
        alignment: Alignment.center,
        child: Text(
            title.isNotEmpty ? title[0].toUpperCase() : '?',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.primary.withValues(alpha: 0.4))),
      );

  Future<bool?> _confirmDelete(BuildContext ctx, String title) =>
      showDialog<bool>(
        context: ctx,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Elimina film'),
          content: Text('Vuoi eliminare "$title"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: const Text('Annulla')),
            TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.expense),
                child: const Text('Elimina')),
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
  late String _status;
  late int? _rating;

  @override
  void initState() {
    super.initState();
    _status = widget.series.status;
    _rating = widget.series.userRating;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.series;
    final posterUrl = s.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${s.posterPath}'
        : null;
    final totalS = s.totalSeasons ?? 0;
    final watched = ref.watch(tvProvider.notifier).watchedSeasonsOf(s.id);

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
                          ? Image.network(posterUrl, fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _placeholder(s.title))
                          : _placeholder(s.title),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title,
                            style: AppTextStyles.headingCard.copyWith(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        if (s.firstAirDate != null &&
                            s.firstAirDate!.length >= 4)
                          Text(s.firstAirDate!.substring(0, 4),
                              style: AppTextStyles.bodySmall),
                        if (s.genreNames != null &&
                            s.genreNames!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(s.genreNames!,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                        if (s.voteAverage != null) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(s.voteAverage!.toStringAsFixed(1),
                                style: AppTextStyles.bodyRegular
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text(' / 10', style: AppTextStyles.bodySmall),
                          ]),
                        ],
                        const SizedBox(height: 12),
                        _StatusDrop(
                          value: _status,
                          onChanged: (v) async {
                            setState(() => _status = v);
                            await ref
                                .read(tvProvider.notifier)
                                .updateStatus(s.id, v);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text('La tua valutazione',
                            style: AppTextStyles.label),
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
                      onSelected: (_) => ref
                          .read(tvProvider.notifier)
                          .toggleSeason(s.id, sn),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      side: BorderSide(
                          color: sel ? AppColors.primary : AppColors.border),
                    );
                  }),
                ),
              ],
              if (s.overview != null && s.overview!.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (totalS == 0) const Divider(color: AppColors.divider),
                const SizedBox(height: 8),
                Text(s.overview!,
                    style: AppTextStyles.bodyRegular
                        .copyWith(color: AppColors.textSecondary, height: 1.5)),
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

  Widget _placeholder(String title) => Container(
        color: AppColors.surfaceElevated,
        alignment: Alignment.center,
        child: Text(
            title.isNotEmpty ? title[0].toUpperCase() : '?',
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.primary.withValues(alpha: 0.4))),
      );

  Future<bool?> _confirmDelete(BuildContext ctx, String title) =>
      showDialog<bool>(
        context: ctx,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Elimina serie TV'),
          content: Text('Vuoi eliminare "$title"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: const Text('Annulla')),
            TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.expense),
                child: const Text('Elimina')),
          ],
        ),
      );
}

// ─── Shared ──────────────────────────────────────────────────────────────────

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
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
