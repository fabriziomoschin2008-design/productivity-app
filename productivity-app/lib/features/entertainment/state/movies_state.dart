import '../../../data/local/database.dart' show Movy;

class MoviesState {
  final List<Movy> movies;
  final String filter; // all | watched | want_to_watch | watching
  final String search;

  const MoviesState({
    this.movies = const [],
    this.filter = 'all',
    this.search = '',
  });

  List<Movy> get filtered {
    var list = filter == 'all' ? movies : movies.where((m) => m.status == filter).toList();
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((m) => m.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  MoviesState copyWith({List<Movy>? movies, String? filter, String? search}) =>
      MoviesState(
        movies: movies ?? this.movies,
        filter: filter ?? this.filter,
        search: search ?? this.search,
      );
}
