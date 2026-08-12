import 'dart:convert';

import '../domain/walka_home_featured_content.dart';
import '../domain/walka_mobile_content.dart';
import 'walka_home_featured_cache.dart';

class WalkaHomeFeaturedRepository {
  WalkaHomeFeaturedRepository({
    required WalkaHomeFeaturedCache cache,
    Future<WalkaHomeFeaturedPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaHomeFeaturedCache _cache;
  final Future<WalkaHomeFeaturedPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaHomeFeaturedSnapshot> load() async {
    final WalkaHomeFeaturedSnapshot? cached = await _tryCache();
    final WalkaHomeFeaturedSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaHomeFeaturedSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaHomeFeaturedSnapshot?> _tryRemote(
    WalkaHomeFeaturedSnapshot? cached,
  ) async {
    final Future<WalkaHomeFeaturedPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaHomeFeaturedPayload payload = await loader();
      final WalkaHomeFeaturedSnapshot snapshot = WalkaHomeFeaturedSnapshot(
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
        // Valid remote data remains usable even if persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaHomeFeaturedSnapshot?> _tryCache() async {
    try {
      final WalkaHomeFeaturedSnapshot? snapshot = await _cache.read();
      if (snapshot == null || snapshot.revision < 1 || snapshot.publishedAt == null) {
        return null;
      }
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }
}
