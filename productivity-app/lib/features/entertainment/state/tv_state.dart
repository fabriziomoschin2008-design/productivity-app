import '../../../data/local/database.dart';

class TvState {
  final List<TvSery> series;
  final String filter;
  final String search;

  const TvState({
    this.series = const [],
    this.filter = 'all',
    this.search = '',
  });

  List<TvSery> get filtered {
    var list = filter == 'all' ? series : series.where((s) => s.status == filter).toList();
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((s) => s.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  TvState copyWith({List<TvSery>? series, String? filter, String? search}) =>
      TvState(
        series: series ?? this.series,
        filter: filter ?? this.filter,
        search: search ?? this.search,
      );
}
