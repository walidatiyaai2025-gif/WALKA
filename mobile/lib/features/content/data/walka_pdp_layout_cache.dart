import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_pdp_layout_content.dart';

abstract interface class WalkaPdpLayoutCache {
  Future<WalkaPdpLayoutSnapshot?> read();
  Future<void> write(WalkaPdpLayoutSnapshot snapshot);
  Future<void> clear();
}

class SharedPreferencesWalkaPdpLayoutCache implements WalkaPdpLayoutCache {
  static const String storageKey = 'walka.content.pdp.layout.snapshot.v1';

  @override
  Future<WalkaPdpLayoutSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return WalkaPdpLayoutSnapshot.fromCacheJson(Map<String, dynamic>.from(decoded));
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaPdpLayoutSnapshot snapshot) async {
    if (snapshot.revision < 1 || snapshot.publishedAt == null) {
      throw const FormatException('Only validated published PDP layout may be cached.');
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(storageKey, jsonEncode(snapshot.toCacheJson()));
    if (!saved) throw StateError('Unable to persist WALKA PDP layout snapshot.');
  }

  @override
  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
