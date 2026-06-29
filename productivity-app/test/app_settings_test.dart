import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/services/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setTmdbApiKey trims and persists the key', () async {
    await AppSettings.setTmdbApiKey('  abc123  ');

    expect(AppSettings.tmdbApiKey, 'abc123');
  });

  test('setTmdbApiKey removes the saved key when empty', () async {
    await AppSettings.setTmdbApiKey('abc123');
    expect(AppSettings.tmdbApiKey, 'abc123');

    await AppSettings.setTmdbApiKey('   ');

    expect(AppSettings.tmdbApiKey, isNull);
  });
}
