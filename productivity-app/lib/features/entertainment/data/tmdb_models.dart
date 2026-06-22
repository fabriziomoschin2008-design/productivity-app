const tmdbImageBase = 'https://image.tmdb.org/t/p/w500';
const tmdbImageLarge = 'https://image.tmdb.org/t/p/w780';

String? tmdbPosterUrl(String? path) =>
    path != null && path.isNotEmpty ? '$tmdbImageBase$path' : null;

class TmdbSearchResult {
  final int id;
  final String title;
  final String? posterPath;
  final String? releaseDate;
  final double? voteAverage;
  final String? overview;
  final bool isTv;

  const TmdbSearchResult({
    required this.id,
    required this.title,
    required this.isTv,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
    this.overview,
  });

  String get year {
    final d = releaseDate;
    if (d == null || d.length < 4) return '';
    return d.substring(0, 4);
  }

  factory TmdbSearchResult.fromMovieJson(Map<String, dynamic> j) =>
      TmdbSearchResult(
        id: j['id'] as int,
        title: (j['title'] as String?) ?? '',
        posterPath: j['poster_path'] as String?,
        releaseDate: j['release_date'] as String?,
        voteAverage: (j['vote_average'] as num?)?.toDouble(),
        overview: j['overview'] as String?,
        isTv: false,
      );

  factory TmdbSearchResult.fromTvJson(Map<String, dynamic> j) =>
      TmdbSearchResult(
        id: j['id'] as int,
        title: (j['name'] as String?) ?? '',
        posterPath: j['poster_path'] as String?,
        releaseDate: j['first_air_date'] as String?,
        voteAverage: (j['vote_average'] as num?)?.toDouble(),
        overview: j['overview'] as String?,
        isTv: true,
      );
}

class TmdbMovieDetails {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? releaseDate;
  final int? runtime;
  final double? voteAverage;
  final List<String> genreNames;

  const TmdbMovieDetails({
    required this.id,
    required this.title,
    required this.genreNames,
    this.overview,
    this.posterPath,
    this.releaseDate,
    this.runtime,
    this.voteAverage,
  });

  String get year {
    final d = releaseDate;
    if (d == null || d.length < 4) return '';
    return d.substring(0, 4);
  }

  factory TmdbMovieDetails.fromJson(Map<String, dynamic> j) => TmdbMovieDetails(
        id: j['id'] as int,
        title: (j['title'] as String?) ?? '',
        overview: j['overview'] as String?,
        posterPath: j['poster_path'] as String?,
        releaseDate: j['release_date'] as String?,
        runtime: j['runtime'] as int?,
        voteAverage: (j['vote_average'] as num?)?.toDouble(),
        genreNames: (j['genres'] as List?)
                ?.map((g) => (g as Map)['name'] as String)
                .toList() ??
            [],
      );
}

class TmdbTvDetails {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? firstAirDate;
  final int? numberOfSeasons;
  final double? voteAverage;
  final List<String> genreNames;

  const TmdbTvDetails({
    required this.id,
    required this.title,
    required this.genreNames,
    this.overview,
    this.posterPath,
    this.firstAirDate,
    this.numberOfSeasons,
    this.voteAverage,
  });

  String get year {
    final d = firstAirDate;
    if (d == null || d.length < 4) return '';
    return d.substring(0, 4);
  }

  factory TmdbTvDetails.fromJson(Map<String, dynamic> j) => TmdbTvDetails(
        id: j['id'] as int,
        title: (j['name'] as String?) ?? '',
        overview: j['overview'] as String?,
        posterPath: j['poster_path'] as String?,
        firstAirDate: j['first_air_date'] as String?,
        numberOfSeasons: j['number_of_seasons'] as int?,
        voteAverage: (j['vote_average'] as num?)?.toDouble(),
        genreNames: (j['genres'] as List?)
                ?.map((g) => (g as Map)['name'] as String)
                .toList() ??
            [],
      );
}
