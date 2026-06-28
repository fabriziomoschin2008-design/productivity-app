import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String? get tmdbApiKey => _prefs?.getString('tmdb_api_key');

  static String? getString(String key) => _prefs?.getString(key);

  static Future<void> setTmdbApiKey(String key) async {
    await init();
    await _prefs!.setString('tmdb_api_key', key.trim());
  }

  static Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }
}
