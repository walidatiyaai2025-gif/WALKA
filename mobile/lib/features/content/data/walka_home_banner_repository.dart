import 'dart:convert';

import '../domain/walka_home_banner_content.dart';
import '../domain/walka_mobile_content.dart';
import 'walka_home_banner_cache.dart';

class WalkaHomeBannerRepository {
  WalkaHomeBannerRepository({
    required WalkaHomeBannerCache cache,
    Future<WalkaHomeBannerPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaHomeBannerCache _cache;
  final Future<WalkaHomeBannerPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaHomeBannerSnapshot> load() async {
    final WalkaHomeBannerSnapshot? cached = await _tryCache();
    final WalkaHomeBannerSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaHomeBannerSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaHomeBannerSnapshot?> _tryRemote(
    WalkaHomeBannerSnapshot? cached,
  ) async {
    final Future<WalkaHomeBannerPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaHomeBannerPayload payload = await loader();
      final WalkaHomeBannerSnapshot snapshot = WalkaHomeBannerSnapshot(
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
        // Valid remote content remains usable even when persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaHomeBannerSnapshot?> _tryCache() async {
    try {
      final WalkaHomeBannerSnapshot? snapshot = await _cache.read();
      if (snapshot == null || snapshot.revision < 1 || snapshot.publishedAt == null) {
        return null;
      }
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }
}
