import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_catalog.dart';

abstract interface class WalkaCatalogCache {
  Future<WalkaCatalogSnapshot?> read();

  Future<void> write(WalkaCatalogSnapshot snapshot);

  Future<void> clear();
}

class SharedPreferencesWalkaCatalogCache implements WalkaCatalogCache {
  static const String storageKey = 'walka.catalog.snapshot.v1';

  @override
  Future<WalkaCatalogSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? raw = preferences.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final WalkaCatalogSnapshot snapshot = WalkaCatalogSnapshot.fromJson(
        Map<String, dynamic>.from(decoded as Map),
        source: WalkaCatalogSource.cache,
      );
      WalkaCatalogContract.validate(snapshot);
      return snapshot;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(WalkaCatalogSnapshot snapshot) async {
    WalkaCatalogContract.validate(snapshot);
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(
      storageKey,
      jsonEncode(snapshot.toJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist WALKA catalog snapshot.');
    }
  }

  @override
  Future<void> clear() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
