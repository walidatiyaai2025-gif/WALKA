import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/walka_remote_media.dart';

abstract interface class WalkaRemoteMediaCache {
  Future<WalkaRemoteProductMediaPayload?> readProducts();

  Future<WalkaRemoteSurfaceMediaPayload?> readSurfaces();

  Future<void> writeProducts(WalkaRemoteProductMediaPayload payload);

  Future<void> writeSurfaces(WalkaRemoteSurfaceMediaPayload payload);
}

class SharedPreferencesWalkaRemoteMediaCache implements WalkaRemoteMediaCache {
  SharedPreferencesWalkaRemoteMediaCache({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String _productsKey = 'walka.remote_media.products.v1';
  static const String _surfacesKey = 'walka.remote_media.surfaces.v1';

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  @override
  Future<WalkaRemoteProductMediaPayload?> readProducts() async {
    final String? encoded = (await _prefs).getString(_productsKey);
    if (encoded == null || encoded.isEmpty) return null;
    final Object? decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      throw const FormatException('Cached product media root must be an object.');
    }
    return WalkaRemoteProductMediaPayload.fromCacheJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  @override
  Future<WalkaRemoteSurfaceMediaPayload?> readSurfaces() async {
    final String? encoded = (await _prefs).getString(_surfacesKey);
    if (encoded == null || encoded.isEmpty) return null;
    final Object? decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      throw const FormatException('Cached surface media root must be an object.');
    }
    return WalkaRemoteSurfaceMediaPayload.fromCacheJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  @override
  Future<void> writeProducts(WalkaRemoteProductMediaPayload payload) async {
    await (await _prefs).setString(
      _productsKey,
      jsonEncode(payload.toCacheJson()),
    );
  }

  @override
  Future<void> writeSurfaces(WalkaRemoteSurfaceMediaPayload payload) async {
    await (await _prefs).setString(
      _surfacesKey,
      jsonEncode(payload.toCacheJson()),
    );
  }
}
