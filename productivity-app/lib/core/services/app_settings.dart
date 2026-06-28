import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String? get tmdbApiKey => _prefs?.getString('tmdb_api_key');

  static Future<void> setTmdbApiKey(String key) async {
    await init();
    await _prefs!.setString('tmdb_api_key', key.trim());
  }
}
