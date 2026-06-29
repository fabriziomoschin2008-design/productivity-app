import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppSettings {
  AppSettings._();

  static SharedPreferences? _prefs;
  static const _tmdbApiKeyKey = 'tmdb_api_key';
  static const _tmdbApiKeyUpdatedAtKey = 'tmdb_api_key_updated_at';
  static const _userSettingsTable = 'user_settings';
  static const _userSettingsKeyColumn = 'setting_key';
  static const _userSettingsValueColumn = 'value';
  static const _userSettingsUpdatedAtColumn = 'updated_at';
  static const _userSettingsDeletedAtColumn = 'deleted_at';

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String? get tmdbApiKey => _prefs?.getString(_tmdbApiKeyKey);

  static String? getString(String key) => _prefs?.getString(key);

  static Future<void> setTmdbApiKey(
    String key, {
    bool syncToCloud = true,
    DateTime? updatedAt,
  }) async {
    await init();
    final trimmed = key.trim();
    final effectiveUpdatedAt = (updatedAt ?? DateTime.now()).toUtc();
    if (trimmed.isEmpty) {
      await _prefs!.remove(_tmdbApiKeyKey);
    } else {
      await _prefs!.setString(_tmdbApiKeyKey, trimmed);
    }
    await _prefs!.setString(
      _tmdbApiKeyUpdatedAtKey,
      effectiveUpdatedAt.toIso8601String(),
    );

    if (syncToCloud) {
      await _syncTmdbApiKeyToCloud(
        trimmed.isEmpty ? null : trimmed,
        effectiveUpdatedAt,
      );
    }
  }

  static Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  static Future<void> removeString(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  static DateTime? get _tmdbApiKeyUpdatedAt {
    final value = _prefs?.getString(_tmdbApiKeyUpdatedAtKey);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  static Future<void> syncTmdbApiKeyWithCloud() async {
    await init();
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) return;

    final remote = await _readTmdbApiKeyFromCloud();
    if (!remote.available) return;

    final cloudKey = remote.key;
    final cloudUpdatedAt = remote.updatedAt;

    final localKey = tmdbApiKey?.trim() ?? '';
    final localUpdatedAt = _tmdbApiKeyUpdatedAt;

    if (cloudUpdatedAt != null &&
        (localUpdatedAt == null || cloudUpdatedAt.isAfter(localUpdatedAt))) {
      await _setTmdbApiKeyLocal(
        cloudKey.isEmpty ? null : cloudKey,
        cloudUpdatedAt,
      );
      return;
    }

    if (localUpdatedAt != null &&
        (cloudUpdatedAt == null || localUpdatedAt.isAfter(cloudUpdatedAt))) {
      await _syncTmdbApiKeyToCloud(
        localKey.isEmpty ? null : localKey,
        localUpdatedAt,
      );
      return;
    }

    if (localKey.isEmpty && cloudKey.isNotEmpty) {
      await _setTmdbApiKeyLocal(
        cloudKey,
        cloudUpdatedAt ?? DateTime.now().toUtc(),
      );
      return;
    }

    if (localKey.isNotEmpty && cloudKey.isEmpty) {
      await _syncTmdbApiKeyToCloud(
        localKey,
        localUpdatedAt ?? DateTime.now().toUtc(),
      );
    }
  }

  static Future<void> _setTmdbApiKeyLocal(
    String? key,
    DateTime updatedAt,
  ) async {
    if (key == null || key.trim().isEmpty) {
      await _prefs!.remove(_tmdbApiKeyKey);
    } else {
      await _prefs!.setString(_tmdbApiKeyKey, key.trim());
    }
    await _prefs!.setString(
      _tmdbApiKeyUpdatedAtKey,
      updatedAt.toUtc().toIso8601String(),
    );
  }

  static Future<void> _syncTmdbApiKeyToCloud(
    String? key,
    DateTime updatedAt,
  ) async {
    if (await _syncTmdbApiKeyToSettingsTable(key, updatedAt)) {
      return;
    }
    await _syncTmdbApiKeyToUserMetadata(key, updatedAt);
  }

  static Future<({bool available, String key, DateTime? updatedAt})>
  _readTmdbApiKeyFromCloud() async {
    final tableState = await _readTmdbApiKeyFromSettingsTable();
    if (tableState != null) return tableState;

    final metadataState = await _readTmdbApiKeyFromUserMetadata();
    if (metadataState != null) return metadataState;

    return (available: false, key: '', updatedAt: null);
  }

  static Future<({bool available, String key, DateTime? updatedAt})?>
  _readTmdbApiKeyFromSettingsTable() async {
    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) return null;
    try {
      final row = await client
          .from(_userSettingsTable)
          .select()
          .eq('user_id', client.auth.currentUser!.id)
          .eq(_userSettingsKeyColumn, _tmdbApiKeyKey)
          .maybeSingle();

      if (row == null) {
        return (available: true, key: '', updatedAt: null);
      }

      final valueRaw = row[_userSettingsValueColumn];
      final deletedAtRaw = row[_userSettingsDeletedAtColumn];
      final updatedAtRaw = row[_userSettingsUpdatedAtColumn];
      final isDeleted = deletedAtRaw is String && deletedAtRaw.isNotEmpty;
      final value = isDeleted
          ? ''
          : (valueRaw is String ? valueRaw.trim() : '');
      final updatedAtValue = updatedAtRaw is String
          ? DateTime.tryParse(updatedAtRaw)?.toUtc()
          : null;
      return (available: true, key: value, updatedAt: updatedAtValue);
    } catch (_) {
      return null;
    }
  }

  static Future<({bool available, String key, DateTime? updatedAt})?>
  _readTmdbApiKeyFromUserMetadata() async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) return null;

    try {
      User remoteUser = currentUser;
      final response = await client.auth.getUser();
      if (response.user != null) {
        remoteUser = response.user!;
      }

      final metadata = remoteUser.userMetadata ?? const <String, dynamic>{};
      final cloudKeyRaw = metadata[_tmdbApiKeyKey];
      final cloudUpdatedAtRaw = metadata[_tmdbApiKeyUpdatedAtKey];
      final cloudKey = cloudKeyRaw is String ? cloudKeyRaw.trim() : '';
      final cloudUpdatedAt = cloudUpdatedAtRaw is String
          ? DateTime.tryParse(cloudUpdatedAtRaw)?.toUtc()
          : null;
      return (available: true, key: cloudKey, updatedAt: cloudUpdatedAt);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _syncTmdbApiKeyToSettingsTable(
    String? key,
    DateTime updatedAt,
  ) async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) return false;
    try {
      await client.from(_userSettingsTable).upsert({
        'user_id': currentUser.id,
        _userSettingsKeyColumn: _tmdbApiKeyKey,
        _userSettingsValueColumn: key,
        _userSettingsUpdatedAtColumn: updatedAt.toUtc().toIso8601String(),
        _userSettingsDeletedAtColumn: key == null
            ? updatedAt.toUtc().toIso8601String()
            : null,
      }, onConflict: 'user_id,$_userSettingsKeyColumn');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _syncTmdbApiKeyToUserMetadata(
    String? key,
    DateTime updatedAt,
  ) async {
    final client = Supabase.instance.client;
    if (client.auth.currentUser == null) return;
    await client.auth.updateUser(
      UserAttributes(
        data: {
          _tmdbApiKeyKey: key ?? '',
          _tmdbApiKeyUpdatedAtKey: updatedAt.toUtc().toIso8601String(),
        },
      ),
    );
  }
}
