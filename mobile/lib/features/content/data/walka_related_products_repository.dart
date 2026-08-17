import 'dart:convert';

import '../domain/walka_mobile_content.dart';
import '../domain/walka_related_products_content.dart';
import 'walka_related_products_cache.dart';

class WalkaRelatedProductsRepository {
  WalkaRelatedProductsRepository({
    required WalkaRelatedProductsCache cache,
    Future<WalkaRelatedProductsPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaRelatedProductsCache _cache;
  final Future<WalkaRelatedProductsPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaRelatedProductsSnapshot> load() async {
    final WalkaRelatedProductsSnapshot? cached = await _tryCache();
    final WalkaRelatedProductsSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaRelatedProductsSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaRelatedProductsSnapshot?> _tryRemote(
    WalkaRelatedProductsSnapshot? cached,
  ) async {
    final Future<WalkaRelatedProductsPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaRelatedProductsPayload payload = await loader();
      final WalkaRelatedProductsSnapshot snapshot = WalkaRelatedProductsSnapshot(
        content: payload.content,
        revision: payload.revision,
        publishedAt: payload.publishedAt,
        fetchedAt: _clock().toUtc(),
        source: WalkaContentSource.remote,
      );

      if (cached != null) {
        if (snapshot.revision < cached.revision) return cached;
        if (snapshot.revision == cached.revision &&
            !_sameContent(snapshot.content, cached.content)) {
          return cached;
        }
      }

      try {
        await _cache.write(snapshot);
      } on Object {
        // Valid remote content remains usable even if persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaRelatedProductsSnapshot?> _tryCache() async {
    try {
      final WalkaRelatedProductsSnapshot? snapshot = await _cache.read();
      if (snapshot == null ||
          snapshot.revision < 1 ||
          snapshot.publishedAt == null) {
        return null;
      }
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }

  bool _sameContent(
    WalkaRelatedProductsContent left,
    WalkaRelatedProductsContent right,
  ) {
    return jsonEncode(left.toJson()) == jsonEncode(right.toJson());
  }
}
