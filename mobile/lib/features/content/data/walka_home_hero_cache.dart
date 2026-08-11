import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_mobile_content.dart';

abstract interface class WalkaHomeHeroCache {
  Future<WalkaHomeHeroSnapshot?> read();

  Future<void> write(WalkaHomeHeroSnapshot snapshot);

  Future<void> clear();
}

class SharedPreferencesWalkaHomeHeroCache implements WalkaHomeHeroCache {
  static const String storageKey = 'walka.content.home.hero.snapshot.v1';

  @override
  Future<WalkaHomeHeroSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaHomeHeroSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaHomeHeroSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException(
        'Only validated published Home content may be cached.',
      );
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA Home content snapshot.');
    }
  }

  @override
  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
