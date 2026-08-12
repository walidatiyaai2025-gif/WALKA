import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_home_featured_content.dart';

abstract interface class WalkaHomeFeaturedCache {
  Future<WalkaHomeFeaturedSnapshot?> read();

  Future<void> write(WalkaHomeFeaturedSnapshot snapshot);
}

class SharedPreferencesWalkaHomeFeaturedCache implements WalkaHomeFeaturedCache {
  static const String storageKey = 'walka.content.home.featured.snapshot.v1';

  @override
  Future<WalkaHomeFeaturedSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaHomeFeaturedSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaHomeFeaturedSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException('Only published featured content may be cached.');
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA featured content.');
    }
  }
}
