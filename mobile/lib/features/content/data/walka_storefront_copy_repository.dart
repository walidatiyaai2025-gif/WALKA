import 'dart:convert';

import '../domain/walka_mobile_content.dart';
import '../domain/walka_storefront_copy_content.dart';
import 'walka_storefront_copy_cache.dart';

class WalkaStorefrontCopyRepository {
  WalkaStorefrontCopyRepository({
    required WalkaStorefrontCopyCache cache,
    Future<WalkaStorefrontCopyPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaStorefrontCopyCache _cache;
  final Future<WalkaStorefrontCopyPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaStorefrontCopySnapshot> load() async {
    final WalkaStorefrontCopySnapshot? cached = await _tryCache();
    final WalkaStorefrontCopySnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaStorefrontCopySnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaStorefrontCopySnapshot?> _tryRemote(
    WalkaStorefrontCopySnapshot? cached,
  ) async {
    final Future<WalkaStorefrontCopyPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;
    try {
      final WalkaStorefrontCopyPayload payload = await loader();
      final WalkaStorefrontCopySnapshot snapshot = WalkaStorefrontCopySnapshot(
        content: payload.content,
        revision: payload.revision,
        publishedAt: payload.publishedAt,
        fetchedAt: _clock().toUtc(),
        source: WalkaContentSource.remote,
      );
      if (cached != null) {
        if (snapshot.revision < cached.revision) return cached;
        if (snapshot.revision == cached.revision &&
            jsonEncode(snapshot.content.toJson()) !=
                jsonEncode(cached.content.toJson())) {
          return cached;
        }
      }
      try {
        await _cache.write(snapshot);
      } on Object {
        // Valid remote content remains usable if local persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaStorefrontCopySnapshot?> _tryCache() async {
    try {
      final WalkaStorefrontCopySnapshot? snapshot = await _cache.read();
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
}
