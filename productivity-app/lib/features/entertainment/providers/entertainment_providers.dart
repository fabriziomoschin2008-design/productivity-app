import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/finance/providers/finance_providers.dart';
import '../state/movies_notifier.dart';
import '../state/movies_state.dart';
import '../state/tv_state.dart';

final moviesProvider = StateNotifierProvider<MoviesNotifier, MoviesState>((ref) {
  return MoviesNotifier(ref.watch(databaseProvider));
});

final tvProvider = StateNotifierProvider<TvNotifier, TvState>((ref) {
  return TvNotifier(ref.watch(databaseProvider));
});
