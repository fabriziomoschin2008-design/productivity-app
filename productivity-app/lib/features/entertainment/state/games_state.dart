import 'dart:convert';
import '../../../data/local/database.dart';

class GameObjective {
  final String desc;
  final bool done;
  const GameObjective({required this.desc, required this.done});
  Map<String, dynamic> toJson() => {'desc': desc, 'done': done};
  factory GameObjective.fromJson(Map<String, dynamic> j) =>
      GameObjective(desc: j['desc'] as String? ?? '', done: j['done'] as bool? ?? false);
}

List<GameObjective> decodeObjectives(String json) {
  try {
    return (jsonDecode(json) as List)
        .map((e) => GameObjective.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

String encodeObjectives(List<GameObjective> list) =>
    jsonEncode(list.map((o) => o.toJson()).toList());

class GamesState {
  final List<Game> games;
  final String filter; // all | playing | completed | want_to_play
  final String search;

  const GamesState({
    this.games = const [],
    this.filter = 'all',
    this.search = '',
  });

  List<Game> get filtered {
    var list = filter == 'all' ? games : games.where((g) => g.status == filter).toList();
    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((g) => g.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  GamesState copyWith({List<Game>? games, String? filter, String? search}) =>
      GamesState(
        games: games ?? this.games,
        filter: filter ?? this.filter,
        search: search ?? this.search,
      );
}
