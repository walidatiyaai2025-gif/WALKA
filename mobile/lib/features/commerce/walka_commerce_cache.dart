import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'walka_commerce_map.dart';

abstract interface class WalkaCommerceCache {
  Future<WalkaCommerceSnapshot?> read();

  Future<void> write(WalkaCommerceSnapshot snapshot);
}

class SharedPreferencesWalkaCommerceCache implements WalkaCommerceCache {
  static const String storageKey = 'walka.commerce.amazon.snapshot.v1';

  @override
  Future<WalkaCommerceSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaCommerceSnapshot.fromCacheJson(
        Map<String, dynamic>.from(decoded),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaCommerceSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.verificationDigest == null) {
      throw const FormatException('Only verified published commerce is cacheable.');
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toCacheJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA commerce snapshot.');
    }
  }
}
