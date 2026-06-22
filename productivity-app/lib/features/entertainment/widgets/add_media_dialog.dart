import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/tmdb_models.dart';
import '../data/tmdb_service.dart';
import '../providers/entertainment_providers.dart';

/// Dialog per aggiungere un film o una serie TV cercando su TMDb.
class AddMediaDialog extends ConsumerStatefulWidget {
  final bool isTv;

  const AddMediaDialog({super.key, required this.isTv});

  @override
  ConsumerState<AddMediaDialog> createState() => _AddMediaDialogState();
}

class _AddMediaDialogState extends ConsumerState<AddMediaDialog> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<TmdbSearchResult> _results = [];
  bool _loading = false;
  bool _adding = false;
  TmdbSearchResult? _selected;
  bool _inOriginalLanguage = false;
  String _status = 'watched';

  // TV-only
  final Set<int> _watchedSeasons = {};
  int _totalSeasons = 0;

  TmdbService? get _tmdb {
    final key = AppSettings.tmdbApiKey;
    return key != null && key.isNotEmpty ? TmdbService(key) : null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q.trim()));
  }

  Future<void> _search(String q) async {
    final tmdb = _tmdb;
    if (tmdb == null) return;
    setState(() => _loading = true);
    try {
      final res = widget.isTv ? await tmdb.searchTv(q) : await tmdb.searchMovies(q);
      if (mounted) setState(() => _results = res.take(6).toList());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectResult(TmdbSearchResult r) async {
    final tmdb = _tmdb;
    setState(() => _selected = r);
    if (tmdb == null) return;
    if (widget.isTv) {
      final details = await tmdb.getTvDetails(r.id);
      if (mounted && details != null) {
        setState(() => _totalSeasons = details.numberOfSeasons ?? 0);
      }
    }
  }

  Future<void> _submit() async {
    setState(() => _adding = true);
    try {
      final tmdb = _tmdb;
      final sel = _selected;
      if (sel == null) {
        // Manual add (no selection)
        final title = _searchCtrl.text.trim();
        if (title.isEmpty) return;
        if (widget.isTv) {
          await ref.read(tvProvider.notifier).addManual(
                title,
                _watchedSeasons.toList(),
                status: _status,
                inOriginalLanguage: _inOriginalLanguage,
              );
        } else {
          await ref.read(moviesProvider.notifier).addManual(
                title,
                status: _status,
                inOriginalLanguage: _inOriginalLanguage,
              );
        }
      } else if (tmdb != null) {
        if (widget.isTv) {
          final details = await tmdb.getTvDetails(sel.id);
          if (details != null) {
            await ref.read(tvProvider.notifier).addFromTmdb(
                  details,
                  _watchedSeasons.toList(),
                  status: _status,
                  inOriginalLanguage: _inOriginalLanguage,
                );
          }
        } else {
          final details = await tmdb.getMovieDetails(sel.id);
          if (details != null) {
            await ref.read(moviesProvider.notifier).addFromTmdb(
                  details,
                  status: _status,
                  inOriginalLanguage: _inOriginalLanguage,
                );
          }
        }
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noApiKey = AppSettings.tmdbApiKey == null;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isTv ? 'Aggiungi serie TV' : 'Aggiungi film',
                style: AppTextStyles.headingCard
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              if (noApiKey)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Nessuna API key TMDb. La ricerca automatica non è disponibile. Aggiungi la chiave nelle impostazioni o aggiungi manualmente il titolo.',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Search field
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cerca titolo...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textSecondary),
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._results.map((r) => _ResultTile(
                      result: r,
                      selected: _selected?.id == r.id,
                      onTap: () => _selectResult(r),
                    )),
              ],
              // Season selector (TV only, after selection)
              if (widget.isTv && _totalSeasons > 0) ...[
                const SizedBox(height: 16),
                Text('Stagioni viste', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: List.generate(_totalSeasons, (i) {
                    final s = i + 1;
                    final sel = _watchedSeasons.contains(s);
                    return FilterChip(
                      label: Text('S$s'),
                      selected: sel,
                      onSelected: (_) => setState(() {
                        if (sel) {
                          _watchedSeasons.remove(s);
                        } else {
                          _watchedSeasons.add(s);
                        }
                      }),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      side: BorderSide(
                          color: sel ? AppColors.primary : AppColors.border),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 16),
              // Status selector
              DropdownButtonFormField<String>(
                value: _status, // ignore: deprecated_member_use
                decoration: InputDecoration(
                  labelText: 'Stato',
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'watched', child: Text('Visto')),
                  DropdownMenuItem(value: 'watching', child: Text('In corso')),
                  DropdownMenuItem(
                      value: 'want_to_watch', child: Text('Da vedere')),
                ],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              const SizedBox(height: 12),
              // Original language toggle
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('Lingua originale', style: AppTextStyles.bodyRegular),
                value: _inOriginalLanguage,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _inOriginalLanguage = v),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annulla')),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: (_adding ||
                            (_selected == null &&
                                _searchCtrl.text.trim().isEmpty))
                        ? null
                        : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _adding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Aggiungi'),
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

class _ResultTile extends StatelessWidget {
  final TmdbSearchResult result;
  final bool selected;
  final VoidCallback onTap;

  const _ResultTile(
      {required this.result, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final posterUrl = tmdbPosterUrl(result.posterPath);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 36,
                height: 54,
                child: posterUrl != null
                    ? Image.network(posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppColors.surfaceElevated))
                    : const ColoredBox(color: AppColors.surfaceElevated),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.title,
                      style: AppTextStyles.bodyRegular
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (result.year.isNotEmpty)
                    Text(result.year,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (result.voteAverage != null) ...[
              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
              const SizedBox(width: 2),
              Text(result.voteAverage!.toStringAsFixed(1),
                  style: AppTextStyles.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
