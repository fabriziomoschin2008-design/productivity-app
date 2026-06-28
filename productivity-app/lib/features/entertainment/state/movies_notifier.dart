import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/error_handler.dart';
import '../../../data/local/database.dart';
import '../data/tmdb_models.dart';
import 'movies_state.dart';
import 'tv_state.dart';

class MoviesNotifier extends StateNotifier<MoviesState> {
  final AppDatabase _db;
  StreamSubscription<List<Movy>>? _sub;

  MoviesNotifier(this._db) : super(const MoviesState()) {
    _sub = _db.watchMovies().listen((list) {
      state = state.copyWith(movies: list);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void setFilter(String f) => state = state.copyWith(filter: f);
  void setSearch(String q) => state = state.copyWith(search: q);

  Future<void> addFromTmdb(
    TmdbMovieDetails d, {
    String status = 'watched',
    bool inOriginalLanguage = false,
  }) async {
    try {
      await _db.insertMovie(
        MoviesCompanion(
          tmdbId: Value(d.id),
          title: Value(d.title),
          overview: Value(d.overview),
          posterPath: Value(d.posterPath),
          releaseDate: Value(d.releaseDate),
          runtime: Value(d.runtime),
          voteAverage: Value(d.voteAverage),
          genreNames: Value(d.genreNames.join(', ')),
          status: Value(status),
          inOriginalLanguage: Value(inOriginalLanguage),
        ),
      );
      AppLogger.instance.info('Film aggiunto: ${d.title}');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> addManual(
    String title, {
    String status = 'watched',
    bool inOriginalLanguage = false,
  }) async {
    try {
      await _db.insertMovie(
        MoviesCompanion(
          title: Value(title),
          status: Value(status),
          inOriginalLanguage: Value(inOriginalLanguage),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _db.updateMovie(
        MoviesCompanion(
          id: Value(id),
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> updateRating(String id, int? rating) async {
    try {
      await _db.updateMovie(
        MoviesCompanion(
          id: Value(id),
          userRating: Value(rating),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> updateLanguagePreference(
    Movy m, {
    TmdbMovieDetails? overrideDetails,
  }) async {
    try {
      await _db.updateMovie(
        MoviesCompanion(
          id: Value(m.id),
          tmdbId: Value(m.tmdbId),
          title: Value(overrideDetails?.title ?? m.title),
          overview: Value(overrideDetails?.overview ?? m.overview),
          posterPath: Value(overrideDetails?.posterPath ?? m.posterPath),
          releaseDate: Value(overrideDetails?.releaseDate ?? m.releaseDate),
          runtime: Value(overrideDetails?.runtime ?? m.runtime),
          voteAverage: Value(overrideDetails?.voteAverage ?? m.voteAverage),
          genreNames: Value(
            overrideDetails != null
                ? overrideDetails.genreNames.join(', ')
                : m.genreNames,
          ),
          status: Value(m.status),
          userRating: Value(m.userRating),
          inOriginalLanguage: Value(!m.inOriginalLanguage),
          updatedAt: Value(DateTime.now()),
        ),
      );
      AppLogger.instance.info(
        'Lingua film aggiornata: ${overrideDetails?.title ?? m.title} OL=${!m.inOriginalLanguage}',
      );
    } catch (e, st) {
      AppErrorHandler.handle(e, st);
    }
  }

  Future<void> updateFromTmdb(String id, TmdbMovieDetails d) async {
    try {
      await _db.updateMovie(
        MoviesCompanion(
          id: Value(id),
          tmdbId: Value(d.id),
          posterPath: Value(d.posterPath),
          overview: Value(d.overview),
          releaseDate: Value(d.releaseDate),
          runtime: Value(d.runtime),
          voteAverage: Value(d.voteAverage),
          genreNames: Value(d.genreNames.join(', ')),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _db.deleteMovieById(id);
      AppLogger.instance.info('Film eliminato: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }
}

class TvNotifier extends StateNotifier<TvState> {
  final AppDatabase _db;
  StreamSubscription<List<TvSery>>? _sub;

  TvNotifier(this._db) : super(const TvState()) {
    _sub = _db.watchTvSeries().listen((list) {
      state = state.copyWith(series: list);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void setFilter(String f) => state = state.copyWith(filter: f);
  void setSearch(String q) => state = state.copyWith(search: q);

  List<int> _decodeSeason(String json) {
    try {
      return (jsonDecode(json) as List).cast<int>();
    } catch (_) {
      return [];
    }
  }

  String _encodeSeason(List<int> list) => jsonEncode(list..sort());

  Future<void> addFromTmdb(
    TmdbTvDetails d,
    List<int> watchedSeasons, {
    String status = 'watching',
    bool inOriginalLanguage = false,
  }) async {
    try {
      await _db.insertTvSeries(
        TvSeriesCompanion(
          tmdbId: Value(d.id),
          title: Value(d.title),
          overview: Value(d.overview),
          posterPath: Value(d.posterPath),
          firstAirDate: Value(d.firstAirDate),
          totalSeasons: Value(d.numberOfSeasons),
          voteAverage: Value(d.voteAverage),
          genreNames: Value(d.genreNames.join(', ')),
          status: Value(status),
          watchedSeasons: Value(_encodeSeason(watchedSeasons)),
          inOriginalLanguage: Value(inOriginalLanguage),
        ),
      );
      AppLogger.instance.info('Serie TV aggiunta: ${d.title}');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> addManual(
    String title,
    List<int> watchedSeasons, {
    String status = 'watching',
    bool inOriginalLanguage = false,
  }) async {
    try {
      await _db.insertTvSeries(
        TvSeriesCompanion(
          title: Value(title),
          status: Value(status),
          watchedSeasons: Value(_encodeSeason(watchedSeasons)),
          inOriginalLanguage: Value(inOriginalLanguage),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  Future<void> toggleSeason(String id, int season) async {
    try {
      final entry = state.series.where((s) => s.id == id).firstOrNull;
      if (entry == null) return;
      final seasons = _decodeSeason(entry.watchedSeasons);
      if (seasons.contains(season)) {
        seasons.remove(season);
      } else {
        seasons.add(season);
      }
      final total = entry.totalSeasons;
      String? autoStatus;
      if (total != null && total > 0 && seasons.length >= total) {
        autoStatus = 'watched';
      } else if (entry.status == 'watched') {
        autoStatus = 'watching';
      }
      await _db.updateTvSeries(
        TvSeriesCompanion(
          id: Value(id),
          watchedSeasons: Value(_encodeSeason(seasons)),
          status: autoStatus != null ? Value(autoStatus) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _db.updateTvSeries(
        TvSeriesCompanion(
          id: Value(id),
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> updateRating(String id, int? rating) async {
    try {
      await _db.updateTvSeries(
        TvSeriesCompanion(
          id: Value(id),
          userRating: Value(rating),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> updateLanguagePreference(
    TvSery entry, {
    TmdbTvDetails? overrideDetails,
  }) async {
    try {
      await _db.updateTvSeries(
        TvSeriesCompanion(
          id: Value(entry.id),
          tmdbId: Value(entry.tmdbId),
          title: Value(overrideDetails?.title ?? entry.title),
          overview: Value(overrideDetails?.overview ?? entry.overview),
          posterPath: Value(overrideDetails?.posterPath ?? entry.posterPath),
          firstAirDate: Value(
            overrideDetails?.firstAirDate ?? entry.firstAirDate,
          ),
          totalSeasons: Value(
            overrideDetails?.numberOfSeasons ?? entry.totalSeasons,
          ),
          voteAverage: Value(overrideDetails?.voteAverage ?? entry.voteAverage),
          genreNames: Value(
            overrideDetails != null
                ? overrideDetails.genreNames.join(', ')
                : entry.genreNames,
          ),
          status: Value(entry.status),
          userRating: Value(entry.userRating),
          watchedSeasons: Value(entry.watchedSeasons),
          inOriginalLanguage: Value(!entry.inOriginalLanguage),
          updatedAt: Value(DateTime.now()),
        ),
      );
      AppLogger.instance.info(
        'Lingua serie TV aggiornata: ${overrideDetails?.title ?? entry.title} OL=${!entry.inOriginalLanguage}',
      );
    } catch (e, st) {
      AppErrorHandler.handle(e, st);
    }
  }

  Future<void> updateFromTmdb(String id, TmdbTvDetails d) async {
    try {
      await _db.updateTvSeries(
        TvSeriesCompanion(
          id: Value(id),
          tmdbId: Value(d.id),
          posterPath: Value(d.posterPath),
          overview: Value(d.overview),
          firstAirDate: Value(d.firstAirDate),
          totalSeasons: Value(d.numberOfSeasons),
          voteAverage: Value(d.voteAverage),
          genreNames: Value(d.genreNames.join(', ')),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, s) {
      AppErrorHandler.handle(e, s, showUi: false);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _db.deleteTvSeriesById(id);
      AppLogger.instance.info('Serie TV eliminata: $id');
    } catch (e, s) {
      AppErrorHandler.handle(e, s);
    }
  }

  List<int> watchedSeasonsOf(String id) {
    final entry = state.series.where((s) => s.id == id).firstOrNull;
    if (entry == null) return [];
    return _decodeSeason(entry.watchedSeasons);
  }
}
