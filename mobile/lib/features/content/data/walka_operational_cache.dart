import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_operational_content.dart';

abstract interface class WalkaMaintenanceNoticeCache {
  Future<WalkaMaintenanceNoticeSnapshot?> read();
  Future<void> write(WalkaMaintenanceNoticeSnapshot snapshot);
}

abstract interface class WalkaAppConfigCache {
  Future<WalkaAppConfigSnapshot?> read();
  Future<void> write(WalkaAppConfigSnapshot snapshot);
}

class SharedPreferencesWalkaMaintenanceNoticeCache
    implements WalkaMaintenanceNoticeCache {
  static const String storageKey =
      'walka.content.maintenance.notice.snapshot.v1';

  @override
  Future<WalkaMaintenanceNoticeSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaMaintenanceNoticeSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaMaintenanceNoticeSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException('Only published maintenance content may be cached.');
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist maintenance content.');
    }
  }
}

class SharedPreferencesWalkaAppConfigCache implements WalkaAppConfigCache {
  static const String storageKey = 'walka.content.app.config.snapshot.v1';

  @override
  Future<WalkaAppConfigSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaAppConfigSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaAppConfigSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException('Only published App Config may be cached.');
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist App Config.');
    }
  }
}
