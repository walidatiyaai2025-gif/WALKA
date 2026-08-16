import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_storefront_copy_content.dart';

abstract interface class WalkaStorefrontCopyCache {
  Future<WalkaStorefrontCopySnapshot?> read();
  Future<void> write(WalkaStorefrontCopySnapshot snapshot);
}

class SharedPreferencesWalkaStorefrontCopyCache
    implements WalkaStorefrontCopyCache {
  static const String storageKey = 'walka.content.storefront.copy.snapshot.v1';

  @override
  Future<WalkaStorefrontCopySnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaStorefrontCopySnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaStorefrontCopySnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException('Only published Storefront copy may be cached.');
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA Storefront copy.');
    }
  }
}
