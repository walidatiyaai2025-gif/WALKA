import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/data/walka_search_presentation_cache.dart';
import 'package:walka/features/content/data/walka_search_presentation_repository.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/content/domain/walka_search_presentation_content.dart';

class _MemorySearchCache implements WalkaSearchPresentationCache {
  WalkaSearchPresentationSnapshot? value;

  @override
  Future<WalkaSearchPresentationSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaSearchPresentationSnapshot snapshot) async {
    value = snapshot;
  }
}

WalkaSearchPresentationPayload _payload({
  required int revision,
  String heading = 'Remote Search',
}) {
  return WalkaSearchPresentationPayload(
    content: WalkaSearchPresentationContent.fromJson(<String, dynamic>{
      ...WalkaSearchPresentationContent.bundled.toJson(),
      'heading': heading,
    }),
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 4),
  );
}

WalkaSearchPresentationSnapshot _cached({
  required int revision,
  String heading = 'Cached Search',
}) {
  return WalkaSearchPresentationSnapshot(
    content: WalkaSearchPresentationContent.fromJson(<String, dynamic>{
      ...WalkaSearchPresentationContent.bundled.toJson(),
      'heading': heading,
    }),
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 3),
    fetchedAt: DateTime.utc(2026, 8, 13, 3, 30),
    source: WalkaContentSource.cache,
  );
}

void main() {
  test('valid remote Search content wins and becomes last-known-good', () async {
    final _MemorySearchCache cache = _MemorySearchCache();
    final WalkaSearchPresentationRepository repository =
        WalkaSearchPresentationRepository(
      cache: cache,
      remoteLoader: () async => _payload(revision: 4),
      clock: () => DateTime.utc(2026, 8, 13, 5),
    );

    final WalkaSearchPresentationSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.remote);
    expect(snapshot.revision, 4);
    expect(snapshot.content.heading, 'Remote Search');
    expect(cache.value?.revision, 4);
  });

  test('remote failure falls back to last-known-good cache', () async {
    final _MemorySearchCache cache = _MemorySearchCache()
      ..value = _cached(revision: 5);
    final WalkaSearchPresentationRepository repository =
        WalkaSearchPresentationRepository(
      cache: cache,
      remoteLoader: () async => throw StateError('offline'),
    );

    final WalkaSearchPresentationSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.revision, 5);
    expect(snapshot.content.heading, 'Cached Search');
  });

  test('older remote revision cannot roll back cached Search content', () async {
    final _MemorySearchCache cache = _MemorySearchCache()
      ..value = _cached(revision: 8, heading: 'Newer cached Search');
    final WalkaSearchPresentationRepository repository =
        WalkaSearchPresentationRepository(
      cache: cache,
      remoteLoader: () async => _payload(revision: 7, heading: 'Older remote'),
    );

    final WalkaSearchPresentationSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.revision, 8);
    expect(snapshot.content.heading, 'Newer cached Search');
  });

  test('same revision with divergent payload keeps cached truth', () async {
    final _MemorySearchCache cache = _MemorySearchCache()
      ..value = _cached(revision: 9, heading: 'Cached truth');
    final WalkaSearchPresentationRepository repository =
        WalkaSearchPresentationRepository(
      cache: cache,
      remoteLoader: () async => _payload(revision: 9, heading: 'Divergent remote'),
    );

    final WalkaSearchPresentationSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.cache);
    expect(snapshot.content.heading, 'Cached truth');
  });

  test('no remote and no cache uses bundled complete Search defaults', () async {
    final WalkaSearchPresentationRepository repository =
        WalkaSearchPresentationRepository(cache: _MemorySearchCache());

    final WalkaSearchPresentationSnapshot snapshot = await repository.load();

    expect(snapshot.source, WalkaContentSource.bundled);
    expect(snapshot.revision, 0);
    expect(snapshot.content.featuredVariantIds, hasLength(5));
  });
}
