import '../domain/walka_mobile_content.dart';
import 'walka_home_hero_cache.dart';

class WalkaHomeHeroRepository {
  WalkaHomeHeroRepository({
    required WalkaHomeHeroCache cache,
    Future<WalkaHomeHeroPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaHomeHeroCache _cache;
  final Future<WalkaHomeHeroPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaHomeHeroSnapshot> load() async {
    final WalkaHomeHeroSnapshot? cached = await _tryCache();
    final WalkaHomeHeroSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaHomeHeroSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaHomeHeroSnapshot?> _tryRemote(
    WalkaHomeHeroSnapshot? cached,
  ) async {
    final Future<WalkaHomeHeroPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaHomeHeroPayload payload = await loader();
      final WalkaHomeHeroSnapshot snapshot = WalkaHomeHeroSnapshot(
        content: payload.content,
        revision: payload.revision,
        publishedAt: payload.publishedAt,
        fetchedAt: _clock().toUtc(),
        source: WalkaContentSource.remote,
      );

      if (cached != null) {
        if (snapshot.revision < cached.revision) {
          return cached;
        }
        if (snapshot.revision == cached.revision &&
            !_sameContent(snapshot.content, cached.content)) {
          return cached;
        }
      }

      try {
        await _cache.write(snapshot);
      } on Object {
        // A valid remote response remains usable even if local persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaHomeHeroSnapshot?> _tryCache() async {
    try {
      final WalkaHomeHeroSnapshot? snapshot = await _cache.read();
      if (snapshot == null || snapshot.revision < 1 || snapshot.publishedAt == null) {
        return null;
      }
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }

  bool _sameContent(WalkaHomeHeroContent left, WalkaHomeHeroContent right) {
    return left.eyebrow == right.eyebrow &&
        left.title == right.title &&
        left.body == right.body &&
        left.shopLabel == right.shopLabel &&
        left.searchLabel == right.searchLabel;
  }
}
