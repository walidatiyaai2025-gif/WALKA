import 'dart:convert';

import '../domain/walka_category_presentation_content.dart';
import '../domain/walka_mobile_content.dart';
import 'walka_category_presentation_cache.dart';

class WalkaCategoryPresentationRepository {
  WalkaCategoryPresentationRepository({
    required WalkaCategoryPresentationCache cache,
    Future<WalkaCategoryPresentationPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaCategoryPresentationCache _cache;
  final Future<WalkaCategoryPresentationPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaCategoryPresentationSnapshot> load() async {
    final WalkaCategoryPresentationSnapshot? cached = await _tryCache();
    final WalkaCategoryPresentationSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaCategoryPresentationSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaCategoryPresentationSnapshot?> _tryRemote(
    WalkaCategoryPresentationSnapshot? cached,
  ) async {
    final Future<WalkaCategoryPresentationPayload> Function()? loader =
        _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaCategoryPresentationPayload payload = await loader();
      final WalkaCategoryPresentationSnapshot snapshot =
          WalkaCategoryPresentationSnapshot(
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

  Future<WalkaCategoryPresentationSnapshot?> _tryCache() async {
    try {
      final WalkaCategoryPresentationSnapshot? snapshot = await _cache.read();
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
