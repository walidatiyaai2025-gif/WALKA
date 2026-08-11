import 'dart:convert';

import '../domain/walka_home_layout_content.dart';
import '../domain/walka_mobile_content.dart';
import 'walka_home_layout_cache.dart';

class WalkaHomeLayoutRepository {
  WalkaHomeLayoutRepository({
    required WalkaHomeLayoutCache cache,
    Future<WalkaHomeLayoutPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaHomeLayoutCache _cache;
  final Future<WalkaHomeLayoutPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaHomeLayoutSnapshot> load() async {
    final WalkaHomeLayoutSnapshot? cached = await _tryCache();
    final WalkaHomeLayoutSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaHomeLayoutSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaHomeLayoutSnapshot?> _tryRemote(
    WalkaHomeLayoutSnapshot? cached,
  ) async {
    final Future<WalkaHomeLayoutPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaHomeLayoutPayload payload = await loader();
      final WalkaHomeLayoutSnapshot snapshot = WalkaHomeLayoutSnapshot(
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
        // Valid remote content remains usable even if local persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaHomeLayoutSnapshot?> _tryCache() async {
    try {
      final WalkaHomeLayoutSnapshot? snapshot = await _cache.read();
      if (snapshot == null || snapshot.revision < 1 || snapshot.publishedAt == null) {
        return null;
      }
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }

  bool _sameContent(
    WalkaHomeLayoutContent left,
    WalkaHomeLayoutContent right,
  ) {
    return jsonEncode(left.toJson()) == jsonEncode(right.toJson());
  }
}
