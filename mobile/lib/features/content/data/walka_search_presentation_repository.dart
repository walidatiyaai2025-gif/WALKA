import 'dart:convert';

import '../domain/walka_mobile_content.dart';
import '../domain/walka_search_presentation_content.dart';
import 'walka_search_presentation_cache.dart';

class WalkaSearchPresentationRepository {
  WalkaSearchPresentationRepository({
    required WalkaSearchPresentationCache cache,
    Future<WalkaSearchPresentationPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaSearchPresentationCache _cache;
  final Future<WalkaSearchPresentationPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaSearchPresentationSnapshot> load() async {
    final WalkaSearchPresentationSnapshot? cached = await _tryCache();
    final WalkaSearchPresentationSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaSearchPresentationSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaSearchPresentationSnapshot?> _tryRemote(
    WalkaSearchPresentationSnapshot? cached,
  ) async {
    final Future<WalkaSearchPresentationPayload> Function()? loader =
        _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaSearchPresentationPayload payload = await loader();
      final WalkaSearchPresentationSnapshot snapshot =
          WalkaSearchPresentationSnapshot(
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
        // Valid remote content remains usable even if persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaSearchPresentationSnapshot?> _tryCache() async {
    try {
      final WalkaSearchPresentationSnapshot? snapshot = await _cache.read();
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
