import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local/database.dart';
import '../providers/entertainment_providers.dart';
import '../widgets/add_media_dialog.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/import_dialog.dart';
import '../widgets/media_card.dart';
import '../widgets/media_detail_dialog.dart';
import '../widgets/refresh_metadata_dialog.dart';

class EntertainmentScreen extends ConsumerStatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  ConsumerState<EntertainmentScreen> createState() =>
      _EntertainmentScreenState();
}

class _EntertainmentScreenState extends ConsumerState<EntertainmentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Row(
              children: [
                Text('Intrattenimento',
                    style: AppTextStyles.headingCard.copyWith(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                // API key settings
                IconButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const ApiKeyDialog(),
                  ),
                  icon: const Icon(Icons.settings_rounded,
                      color: AppColors.textSecondary, size: 20),
                  tooltip: 'Impostazioni TMDb',
                ),
                const SizedBox(width: 4),
                // Refresh posters
                IconButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const RefreshMetadataDialog(),
                  ),
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.textSecondary, size: 20),
                  tooltip: 'Aggiorna poster',
                ),
                const SizedBox(width: 4),
                // Import list
                OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const ImportDialog(),
                  ),
                  icon: const Icon(Icons.upload_rounded, size: 16),
                  label: const Text('Importa lista'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(width: 10),
                // Add button (context-aware)
                AnimatedBuilder(
                  animation: _tabs,
                  builder: (_, _) => FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          AddMediaDialog(isTv: _tabs.index == 1),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label:
                        Text(_tabs.index == 0 ? 'Film' : 'Serie TV'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Tabs ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TabBar(
              controller: _tabs,
              isScrollable: false,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: AppColors.divider,
              tabs: const [
                Tab(text: 'Film'),
                Tab(text: 'Serie TV'),
              ],
            ),
          ),
          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _MoviesTab(),
                _TvTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Film tab ────────────────────────────────────────────────────────────────

class _MoviesTab extends ConsumerStatefulWidget {
  const _MoviesTab();

  @override
  ConsumerState<_MoviesTab> createState() => _MoviesTabState();
}

class _MoviesTabState extends ConsumerState<_MoviesTab> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(moviesProvider).search;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moviesProvider);
    final movies = state.filtered;

    return Column(
      children: [
        _Toolbar(
          searchCtrl: _searchCtrl,
          filter: state.filter,
          onSearch: (q) => ref.read(moviesProvider.notifier).setSearch(q),
          onFilter: (f) => ref.read(moviesProvider.notifier).setFilter(f),
        ),
        Expanded(
          child: movies.isEmpty
              ? _EmptyState(
                  label: state.search.isNotEmpty || state.filter != 'all'
                      ? 'Nessun film trovato'
                      : 'Nessun film. Premi "Film" per aggiungerne uno.',
                  icon: Icons.movie_rounded,
                )
              : _PosterGrid(
                  itemCount: movies.length,
                  builder: (i) => _MovieCard(movie: movies[i]),
                ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movy movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
        : null;
    return MediaCard(
      title: movie.title,
      posterUrl: posterUrl,
      year: movie.releaseDate?.length != null && movie.releaseDate!.length >= 4
          ? movie.releaseDate!.substring(0, 4)
          : null,
      rating: movie.voteAverage,
      subtitle: movie.genreNames,
      inOriginalLanguage: movie.inOriginalLanguage,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => MovieDetailDialog(movie: movie),
      ),
    );
  }
}

// ─── Serie TV tab ────────────────────────────────────────────────────────────

class _TvTab extends ConsumerStatefulWidget {
  const _TvTab();

  @override
  ConsumerState<_TvTab> createState() => _TvTabState();
}

class _TvTabState extends ConsumerState<_TvTab> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(tvProvider).search;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tvProvider);
    final series = state.filtered;

    return Column(
      children: [
        _Toolbar(
          searchCtrl: _searchCtrl,
          filter: state.filter,
          onSearch: (q) => ref.read(tvProvider.notifier).setSearch(q),
          onFilter: (f) => ref.read(tvProvider.notifier).setFilter(f),
        ),
        Expanded(
          child: series.isEmpty
              ? _EmptyState(
                  label: state.search.isNotEmpty || state.filter != 'all'
                      ? 'Nessuna serie trovata'
                      : 'Nessuna serie TV. Premi "Serie TV" per aggiungerne una.',
                  icon: Icons.tv_rounded,
                )
              : _PosterGrid(
                  itemCount: series.length,
                  builder: (i) => _TvCard(series: series[i]),
                ),
        ),
      ],
    );
  }
}

class _TvCard extends ConsumerWidget {
  final TvSery series;
  const _TvCard({required this.series});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posterUrl = series.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${series.posterPath}'
        : null;
    List<int> seasons = [];
    try {
      seasons = (jsonDecode(series.watchedSeasons) as List).cast<int>();
    } catch (_) {}

    return MediaCard(
      title: series.title,
      posterUrl: posterUrl,
      year: series.firstAirDate?.length != null &&
              series.firstAirDate!.length >= 4
          ? series.firstAirDate!.substring(0, 4)
          : null,
      rating: series.voteAverage,
      subtitle: series.genreNames,
      watchedSeasons: seasons,
      inOriginalLanguage: series.inOriginalLanguage,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => TvDetailDialog(series: series),
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String filter;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onFilter;

  const _Toolbar({
    required this.searchCtrl,
    required this.filter,
    required this.onSearch,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          SizedBox(
            width: 240,
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Cerca...',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary, size: 18),
                filled: true,
                fillColor: AppColors.surface,
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
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 16),
          StatusFilterRow(current: filter, onChanged: onFilter),
        ],
      ),
    );
  }
}

class _PosterGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(int) builder;

  const _PosterGrid({required this.itemCount, required this.builder});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 170,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) => builder(i),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  final IconData icon;
  const _EmptyState({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(label,
              style: AppTextStyles.bodyRegular
                  .copyWith(color: AppColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
