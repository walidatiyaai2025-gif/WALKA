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

    final WalkaRemoteProductMediaPayload products = remoteProducts ??
        cachedProducts ??
        _bundledProducts();
    final WalkaRemoteSurfaceMediaPayload surfaces = remoteSurfaces ??
        cachedSurfaces ??
        _bundledSurfaces();

    final bool bothRemote = remoteProducts != null && remoteSurfaces != null;
    final bool anyRemote = remoteProducts != null || remoteSurfaces != null;
    final bool anyCache = cachedProducts != null || cachedSurfaces != null;
    final WalkaRemoteMediaSource source = bothRemote
        ? WalkaRemoteMediaSource.remote
        : (anyRemote || anyCache)
            ? WalkaRemoteMediaSource.cache
            : WalkaRemoteMediaSource.bundled;

    return WalkaRemoteMediaSnapshot(
      products: products,
      surfaces: surfaces,
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
        // Valid remote metadata remains usable if persistence is unavailable.
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
        // Valid remote metadata remains usable if persistence is unavailable.
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

  WalkaRemoteProductMediaPayload _bundledProducts() {
    final Map<String, List<WalkaRemoteMediaItem>> empty =
        <String, List<WalkaRemoteMediaItem>>{};
    for (final String id in walkaSupportedProductVariants.values
        .expand((List<String> ids) => ids)) {
      empty[id] = const <WalkaRemoteMediaItem>[];
    }
    return WalkaRemoteProductMediaPayload(
      revisionToken: _bundledRevision,
      galleriesByVariant: empty,
    );
  }

  WalkaRemoteSurfaceMediaPayload _bundledSurfaces() {
    return WalkaRemoteSurfaceMediaPayload(
      revisionToken: _bundledRevision,
      itemsBySlot: <String, List<WalkaRemoteMediaItem>>{
        for (final String key in walkaSupportedRemoteMediaSlots.keys)
          key: const <WalkaRemoteMediaItem>[],
      },
    );
  }
}

const String _bundledRevision =
    '0000000000000000000000000000000000000000000000000000000000000000';
