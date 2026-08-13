import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_category_presentation_content.dart';

abstract interface class WalkaCategoryPresentationCache {
  Future<WalkaCategoryPresentationSnapshot?> read();

  Future<void> write(WalkaCategoryPresentationSnapshot snapshot);
}

class SharedPreferencesWalkaCategoryPresentationCache
    implements WalkaCategoryPresentationCache {
  static const String storageKey = 'walka.content.categories.presentation.snapshot.v1';

  @override
  Future<WalkaCategoryPresentationSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaCategoryPresentationSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaCategoryPresentationSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException(
        'Only published category presentation may be cached.',
      );
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA category presentation.');
    }
  }
}
