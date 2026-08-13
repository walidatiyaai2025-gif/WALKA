import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_home_banner_content.dart';

abstract interface class WalkaHomeBannerCache {
  Future<WalkaHomeBannerSnapshot?> read();

  Future<void> write(WalkaHomeBannerSnapshot snapshot);
}

class SharedPreferencesWalkaHomeBannerCache implements WalkaHomeBannerCache {
  static const String storageKey = 'walka.content.home.banner.snapshot.v1';

  @override
  Future<WalkaHomeBannerSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaHomeBannerSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaHomeBannerSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException('Only published Home banner content may be cached.');
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA Home banner content.');
    }
  }
}
