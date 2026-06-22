import 'dart:convert';
import 'dart:io';

/// Persistent key-value settings stored in %LOCALAPPDATA%\ProductivityApp\settings.json
class AppSettings {
  AppSettings._();

  static File _file() {
    final base = Platform.environment['LOCALAPPDATA'] ?? '';
    return File('$base\\ProductivityApp\\settings.json');
  }

  static Map<String, dynamic> _read() {
    final f = _file();
    if (!f.existsSync()) return {};
    try {
      return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> _write(Map<String, dynamic> data) async {
    final f = _file();
    await f.parent.create(recursive: true);
    await f.writeAsString(jsonEncode(data));
  }

  static String? get tmdbApiKey => _read()['tmdb_api_key'] as String?;

  static Future<void> setTmdbApiKey(String key) async {
    final data = _read();
    data['tmdb_api_key'] = key.trim();
    await _write(data);
  }
}
