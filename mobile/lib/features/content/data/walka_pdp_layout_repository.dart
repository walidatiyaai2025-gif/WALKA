import 'dart:convert';

import '../domain/walka_mobile_content.dart';
import '../domain/walka_pdp_layout_content.dart';
import 'walka_pdp_layout_cache.dart';

class WalkaPdpLayoutRepository {
  WalkaPdpLayoutRepository({
    required WalkaPdpLayoutCache cache,
    Future<WalkaPdpLayoutPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaPdpLayoutCache _cache;
  final Future<WalkaPdpLayoutPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaPdpLayoutSnapshot> load() async {
    final WalkaPdpLayoutSnapshot? cached = await _tryCache();
    final WalkaPdpLayoutSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaPdpLayoutSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaPdpLayoutSnapshot?> _tryRemote(WalkaPdpLayoutSnapshot? cached) async {
    final Future<WalkaPdpLayoutPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;
    try {
      final WalkaPdpLayoutPayload payload = await loader();
      final WalkaPdpLayoutSnapshot snapshot = WalkaPdpLayoutSnapshot(
        content: payload.content,
        revision: payload.revision,
        publishedAt: payload.publishedAt,
        fetchedAt: _clock().toUtc(),
        source: WalkaContentSource.remote,
      );
      if (cached != null) {
        if (snapshot.revision < cached.revision) return cached;
        if (snapshot.revision == cached.revision && !_sameContent(snapshot.content, cached.content)) return cached;
      }
      try { await _cache.write(snapshot); } on Object { /* remote remains usable */ }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaPdpLayoutSnapshot?> _tryCache() async {
    try {
      final WalkaPdpLayoutSnapshot? snapshot = await _cache.read();
      if (snapshot == null || snapshot.revision < 1 || snapshot.publishedAt == null) return null;
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }

  bool _sameContent(WalkaPdpLayoutContent left, WalkaPdpLayoutContent right) =>
      jsonEncode(left.toJson()) == jsonEncode(right.toJson());
}
