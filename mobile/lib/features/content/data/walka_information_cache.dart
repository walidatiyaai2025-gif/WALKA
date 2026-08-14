import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_information_content.dart';

abstract interface class WalkaInformationCache {
  Future<WalkaInformationSnapshot?> read();

  Future<void> write(WalkaInformationSnapshot snapshot);

  Future<void> clear();
}

class SharedPreferencesWalkaInformationCache implements WalkaInformationCache {
  static const String storageKey = 'walka.content.information.snapshot.v1';

  @override
  Future<WalkaInformationSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaInformationSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaInformationSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException(
        'Only validated published Information content may be cached.',
      );
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA Information snapshot.');
    }
  }

  @override
  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
