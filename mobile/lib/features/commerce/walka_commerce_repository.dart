import 'walka_commerce_cache.dart';
import 'walka_commerce_map.dart';

class WalkaCommerceRepository {
  WalkaCommerceRepository({
    required WalkaCommerceCache cache,
    Future<WalkaCommerceSnapshot> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaCommerceCache _cache;
  final Future<WalkaCommerceSnapshot> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaCommerceSnapshot> load() async {
    final WalkaCommerceSnapshot? cached = await _tryCache();
    final WalkaCommerceSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaCommerceSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaCommerceSnapshot?> _tryRemote(
    WalkaCommerceSnapshot? cached,
  ) async {
    final Future<WalkaCommerceSnapshot> Function()? loader = _remoteLoader;
    if (loader == null) return null;

    try {
      final WalkaCommerceSnapshot remote = await loader();
      final WalkaCommerceSnapshot snapshot = WalkaCommerceSnapshot(
        revision: remote.revision,
        verificationDigest: remote.verificationDigest,
        mappings: remote.mappings,
        fetchedAt: _clock().toUtc(),
        source: WalkaCommerceSource.remote,
      );
      if (snapshot.revision < 1 || snapshot.verificationDigest == null) {
        return null;
      }

      if (cached != null) {
        if (snapshot.revision < cached.revision) return cached;
        if (snapshot.revision == cached.revision &&
            snapshot.verificationDigest != cached.verificationDigest) {
          return cached;
        }
      }

      try {
        await _cache.write(snapshot);
      } on Object {
        // A verified remote snapshot remains usable even if persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaCommerceSnapshot?> _tryCache() async {
    try {
      final WalkaCommerceSnapshot? snapshot = await _cache.read();
      if (snapshot == null ||
          snapshot.revision < 1 ||
          snapshot.verificationDigest == null) {
        return null;
      }
      return snapshot.asSource(WalkaCommerceSource.cache);
    } on Object {
      return null;
    }
  }
}
