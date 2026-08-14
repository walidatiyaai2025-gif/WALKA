import 'dart:convert';

import '../domain/walka_information_content.dart';
import '../domain/walka_mobile_content.dart';
import 'walka_information_cache.dart';

class WalkaInformationRepository {
  WalkaInformationRepository({
    required WalkaInformationCache cache,
    Future<WalkaInformationPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaInformationCache _cache;
  final Future<WalkaInformationPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaInformationSnapshot> load() async {
    final WalkaInformationSnapshot? cached = await _tryCache();
    final WalkaInformationSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaInformationSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaInformationSnapshot?> _tryRemote(
    WalkaInformationSnapshot? cached,
  ) async {
    final Future<WalkaInformationPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaInformationPayload payload = await loader();
      final WalkaInformationSnapshot snapshot = WalkaInformationSnapshot(
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
        // A valid remote snapshot remains usable even when persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaInformationSnapshot?> _tryCache() async {
    try {
      final WalkaInformationSnapshot? snapshot = await _cache.read();
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
    WalkaInformationContent left,
    WalkaInformationContent right,
  ) {
    return jsonEncode(left.toJson()) == jsonEncode(right.toJson());
  }
}
