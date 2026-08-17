import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_related_products_content.dart';

abstract interface class WalkaRelatedProductsCache {
  Future<WalkaRelatedProductsSnapshot?> read();
  Future<void> write(WalkaRelatedProductsSnapshot snapshot);
  Future<void> clear();
}

class SharedPreferencesWalkaRelatedProductsCache
    implements WalkaRelatedProductsCache {
  static const String storageKey =
      'walka.content.pdp.related-products.snapshot.v1';

  @override
  Future<WalkaRelatedProductsSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaRelatedProductsSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaRelatedProductsSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException(
        'Only validated published related products may be cached.',
      );
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA related-products snapshot.');
    }
  }

  @override
  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
