import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authUserProvider = StreamProvider<User?>((ref) async* {
  final client = Supabase.instance.client;
  yield client.auth.currentUser;
  yield* client.auth.onAuthStateChange.map((event) => event.session?.user);
});
