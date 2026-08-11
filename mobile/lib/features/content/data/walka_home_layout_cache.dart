import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_home_layout_content.dart';

abstract interface class WalkaHomeLayoutCache {
  Future<WalkaHomeLayoutSnapshot?> read();

  Future<void> write(WalkaHomeLayoutSnapshot snapshot);

  Future<void> clear();
}

class SharedPreferencesWalkaHomeLayoutCache implements WalkaHomeLayoutCache {
  static const String storageKey = 'walka.content.home.layout.snapshot.v1';

  @override
  Future<WalkaHomeLayoutSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaHomeLayoutSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaHomeLayoutSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException(
        'Only validated published Home layout may be cached.',
      );
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA Home layout snapshot.');
    }
  }

  @override
  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
