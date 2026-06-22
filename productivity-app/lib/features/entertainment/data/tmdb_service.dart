import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tmdb_models.dart';

class TmdbService {
  static const _base = 'https://api.themoviedb.org/3';

  final String _apiKey;
  TmdbService(this._apiKey);

  Uri _url(String path, [Map<String, String>? extra]) => Uri.parse('$_base$path')
      .replace(queryParameters: {'api_key': _apiKey, 'language': 'it-IT', ...?extra});

  Future<List<TmdbSearchResult>> searchMovies(String query) async {
    final res = await http.get(_url('/search/movie', {'query': query}));
    if (res.statusCode != 200) return [];
    final list = (jsonDecode(res.body)['results'] as List?) ?? [];
    return list.map((j) => TmdbSearchResult.fromMovieJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<TmdbSearchResult>> searchTv(String query) async {
    final res = await http.get(_url('/search/tv', {'query': query}));
    if (res.statusCode != 200) return [];
    final list = (jsonDecode(res.body)['results'] as List?) ?? [];
    return list.map((j) => TmdbSearchResult.fromTvJson(j as Map<String, dynamic>)).toList();
  }

  Future<TmdbMovieDetails?> getMovieDetails(int tmdbId) async {
    final res = await http.get(_url('/movie/$tmdbId'));
    if (res.statusCode != 200) return null;
    return TmdbMovieDetails.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<TmdbMovieDetails?> getMovieDetailsEn(int tmdbId) async {
    final res = await http.get(_url('/movie/$tmdbId', {'language': 'en-US'}));
    if (res.statusCode != 200) return null;
    return TmdbMovieDetails.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<TmdbTvDetails?> getTvDetails(int tmdbId) async {
    final res = await http.get(_url('/tv/$tmdbId'));
    if (res.statusCode != 200) return null;
    return TmdbTvDetails.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<TmdbTvDetails?> getTvDetailsEn(int tmdbId) async {
    final res = await http.get(_url('/tv/$tmdbId', {'language': 'en-US'}));
    if (res.statusCode != 200) return null;
    return TmdbTvDetails.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
