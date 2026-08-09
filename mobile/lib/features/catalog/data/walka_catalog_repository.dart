import '../../../core/api/walka_api_client.dart';
import '../domain/walka_catalog.dart';
import 'walka_bundled_catalog.dart';
import 'walka_catalog_cache.dart';

class WalkaCatalogRepository {
  WalkaCatalogRepository({
    required WalkaCatalogCache cache,
    WalkaCatalogRemoteDataSource? remote,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remote = remote,
        _clock = clock ?? DateTime.now;

  final WalkaCatalogCache _cache;
  final WalkaCatalogRemoteDataSource? _remote;
  final DateTime Function() _clock;

  Future<WalkaCatalogSnapshot> load() async {
    final WalkaCatalogSnapshot? remoteSnapshot = await _tryRemote();
    if (remoteSnapshot != null) return remoteSnapshot;

    final WalkaCatalogSnapshot? cachedSnapshot = await _tryCache();
    if (cachedSnapshot != null) return cachedSnapshot;

    return WalkaBundledCatalog.snapshot(fetchedAt: _clock());
  }

  Future<WalkaCatalogSnapshot?> _tryRemote() async {
    final WalkaCatalogRemoteDataSource? remote = _remote;
    if (remote == null) return null;

    try {
      final WalkaStorefrontConfig config = await remote.fetchConfig();
      final WalkaCatalogPayload payload = await remote.fetchCatalog();

      if (config.release != payload.release ||
          config.apiVersion != payload.apiVersion ||
          config.purchaseMode != payload.purchaseMode) {
        throw const FormatException(
          'WALKA config and catalog metadata do not match.',
        );
      }

      final WalkaCatalogSnapshot snapshot = WalkaCatalogSnapshot(
        config: config,
        products: payload.products,
        source: WalkaCatalogSource.remote,
        fetchedAt: _clock().toUtc(),
      );
      WalkaCatalogContract.validate(snapshot);

      try {
        await _cache.write(snapshot);
      } on Object {
        // A cache write failure must never discard a valid remote response.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaCatalogSnapshot?> _tryCache() async {
    try {
      final WalkaCatalogSnapshot? snapshot = await _cache.read();
      if (snapshot == null) return null;
      WalkaCatalogContract.validate(snapshot);
      return snapshot.asSource(WalkaCatalogSource.cache);
    } on Object {
      return null;
    }
  }
}
