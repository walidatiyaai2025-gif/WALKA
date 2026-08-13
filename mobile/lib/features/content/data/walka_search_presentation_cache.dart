import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_search_presentation_content.dart';

abstract interface class WalkaSearchPresentationCache {
  Future<WalkaSearchPresentationSnapshot?> read();

  Future<void> write(WalkaSearchPresentationSnapshot snapshot);
}

class SharedPreferencesWalkaSearchPresentationCache
    implements WalkaSearchPresentationCache {
  static const String storageKey = 'walka.content.search.presentation.snapshot.v1';

  @override
  Future<WalkaSearchPresentationSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaSearchPresentationSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaSearchPresentationSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException(
        'Only published Search presentation may be cached.',
      );
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA Search presentation.');
    }
  }
}
