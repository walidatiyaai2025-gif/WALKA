import 'dart:convert';

import '../domain/walka_remote_media.dart';
import 'walka_remote_media_cache.dart';

class WalkaRemoteMediaRepository {
  WalkaRemoteMediaRepository({
    required WalkaRemoteMediaCache cache,
    Future<WalkaRemoteProductMediaPayload> Function()? productLoader,
    Future<WalkaRemoteSurfaceMediaPayload> Function()? surfaceLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _productLoader = productLoader,
        _surfaceLoader = surfaceLoader,
        _clock = clock ?? DateTime.now;

  final WalkaRemoteMediaCache _cache;
  final Future<WalkaRemoteProductMediaPayload> Function()? _productLoader;
  final Future<WalkaRemoteSurfaceMediaPayload> Function()? _surfaceLoader;
  final DateTime Function() _clock;

  Future<WalkaRemoteMediaSnapshot> load() async {
    final WalkaRemoteProductMediaPayload? cachedProducts =
        await _tryReadProducts();
    final WalkaRemoteSurfaceMediaPayload? cachedSurfaces =
        await _tryReadSurfaces();

    final WalkaRemoteProductMediaPayload? remoteProducts =
        await _tryRemoteProducts(cachedProducts);
    final WalkaRemoteSurfaceMediaPayload? remoteSurfaces =
        await _tryRemoteSurfaces(cachedSurfaces);

    final WalkaRemoteProductMediaPayload? products =
        remoteProducts ?? cachedProducts;
    final WalkaRemoteSurfaceMediaPayload? surfaces =
        remoteSurfaces ?? cachedSurfaces;

    if (products == null && surfaces == null) {
      return WalkaRemoteMediaSnapshot.unavailable(fetchedAt: _clock());
    }

    final bool bothRemote = remoteProducts != null && remoteSurfaces != null;
    final WalkaRemoteMediaSource source = bothRemote
        ? WalkaRemoteMediaSource.remote
        : WalkaRemoteMediaSource.cache;

    return WalkaRemoteMediaSnapshot(
      products: products ?? WalkaRemoteProductMediaPayload.empty(),
      surfaces: surfaces ?? WalkaRemoteSurfaceMediaPayload.empty(),
      source: source,
      fetchedAt: _clock().toUtc(),
    );
  }

  Future<WalkaRemoteProductMediaPayload?> _tryRemoteProducts(
    WalkaRemoteProductMediaPayload? cached,
  ) async {
    final Future<WalkaRemoteProductMediaPayload> Function()? loader =
        _productLoader;
    if (loader == null) return null;
    try {
      final WalkaRemoteProductMediaPayload remote = await loader();
      if (_sameRevisionDifferentPayload(
        remote.revisionToken,
        remote.toCacheJson(),
        cached?.revisionToken,
        cached?.toCacheJson(),
      )) {
        return cached;
      }
      try {
        await _cache.writeProducts(remote);
      } on Object {
        // A valid remote snapshot remains usable if local persistence fails.
      }
      return remote;
    } on Object {
      return null;
    }
  }

  Future<WalkaRemoteSurfaceMediaPayload?> _tryRemoteSurfaces(
    WalkaRemoteSurfaceMediaPayload? cached,
  ) async {
    final Future<WalkaRemoteSurfaceMediaPayload> Function()? loader =
        _surfaceLoader;
    if (loader == null) return null;
    try {
      final WalkaRemoteSurfaceMediaPayload remote = await loader();
      if (_sameRevisionDifferentPayload(
        remote.revisionToken,
        remote.toCacheJson(),
        cached?.revisionToken,
        cached?.toCacheJson(),
      )) {
        return cached;
      }
      try {
        await _cache.writeSurfaces(remote);
      } on Object {
        // A valid remote snapshot remains usable if local persistence fails.
      }
      return remote;
    } on Object {
      return null;
    }
  }

  Future<WalkaRemoteProductMediaPayload?> _tryReadProducts() async {
    try {
      return await _cache.readProducts();
    } on Object {
      return null;
    }
  }

  Future<WalkaRemoteSurfaceMediaPayload?> _tryReadSurfaces() async {
    try {
      return await _cache.readSurfaces();
    } on Object {
      return null;
    }
  }

  bool _sameRevisionDifferentPayload(
    String remoteRevision,
    Map<String, dynamic> remote,
    String? cachedRevision,
    Map<String, dynamic>? cached,
  ) {
    return cachedRevision != null &&
        cached != null &&
        remoteRevision == cachedRevision &&
        jsonEncode(remote) != jsonEncode(cached);
  }
}
