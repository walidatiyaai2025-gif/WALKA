import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_home_banner_cache.dart';
import 'package:walka/features/content/data/walka_home_banner_repository.dart';
import 'package:walka/features/content/domain/walka_home_banner_content.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_banner.dart';

void main() {
  test('banner parser enforces CTA allowlist and UTC schedule boundaries', () {
    final WalkaHomeBannerContent content = WalkaHomeBannerContent.fromJson(
      <String, dynamic>{
        'enabled': true,
        'eyebrow': 'WALKA WEEK',
        'title': 'A calmer week starts here',
        'body': 'Explore organization while this announcement is active.',
        'cta_label': 'SEARCH WALKA',
        'cta_action': 'search',
        'starts_at': '2026-08-13T10:00:00Z',
        'ends_at': '2026-08-13T12:00:00Z',
      },
    );

    expect(content.ctaAction, WalkaHomeBannerAction.search);
    expect(content.isActiveAt(DateTime.utc(2026, 8, 13, 9, 59, 59)), isFalse);
    expect(content.isActiveAt(DateTime.utc(2026, 8, 13, 10)), isTrue);
    expect(content.isActiveAt(DateTime.utc(2026, 8, 13, 11, 59, 59)), isTrue);
    expect(content.isActiveAt(DateTime.utc(2026, 8, 13, 12)), isFalse);

    expect(
      () => WalkaHomeBannerContent.fromJson(<String, dynamic>{
        'enabled': true,
        'eyebrow': 'BAD',
        'title': 'Unsafe action',
        'body': 'Remote URLs must never become executable behavior.',
        'cta_label': 'OPEN',
        'cta_action': 'https://example.invalid',
        'starts_at': null,
        'ends_at': null,
      }),
      throwsFormatException,
    );
  });

  test('remote banner becomes LKG and offline falls back to cache then bundled', () async {
    final _MemoryBannerCache cache = _MemoryBannerCache();
    final WalkaHomeBannerRepository remoteRepository = WalkaHomeBannerRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 8,
        content: _activeBanner(WalkaHomeBannerAction.browse),
      ),
      clock: () => DateTime.utc(2026, 8, 13, 10, 30),
    );

    final WalkaHomeBannerSnapshot remote = await remoteRepository.load();
    expect(remote.source, WalkaContentSource.remote);
    expect(remote.revision, 8);
    expect(cache.value?.revision, 8);

    final WalkaHomeBannerSnapshot offline = await WalkaHomeBannerRepository(
      cache: cache,
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(offline.source, WalkaContentSource.cache);
    expect(offline.content.title, 'A calmer week starts here');

    final WalkaHomeBannerSnapshot bundled = await WalkaHomeBannerRepository(
      cache: _MemoryBannerCache(),
      remoteLoader: () async => throw StateError('offline'),
    ).load();
    expect(bundled.source, WalkaContentSource.bundled);
    expect(bundled.content.enabled, isFalse);
  });

  test('older and divergent same-revision remote cannot replace cached banner', () async {
    final _MemoryBannerCache cache = _MemoryBannerCache(
      value: _snapshot(
        revision: 9,
        content: _activeBanner(WalkaHomeBannerAction.search),
      ),
    );

    final WalkaHomeBannerSnapshot older = await WalkaHomeBannerRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 8,
        content: _activeBanner(WalkaHomeBannerAction.browse),
      ),
    ).load();
    expect(older.source, WalkaContentSource.cache);
    expect(cache.writeCount, 0);

    final WalkaHomeBannerSnapshot divergent = await WalkaHomeBannerRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        revision: 9,
        content: _activeBanner(WalkaHomeBannerAction.browse),
      ),
    ).load();
    expect(divergent.source, WalkaContentSource.cache);
    expect(divergent.content.ctaAction, WalkaHomeBannerAction.search);
    expect(cache.writeCount, 0);
  });

  testWidgets('scheduled banner flips at start and end boundaries without refetch',
      (WidgetTester tester) async {
    DateTime current = DateTime.utc(2026, 8, 13, 10);
    final WalkaHomeBannerContent content = WalkaHomeBannerContent(
      enabled: true,
      eyebrow: 'TIMED NOTE',
      title: 'Scheduled exactly',
      body: 'This banner is guarded by the client clock when offline.',
      ctaAction: WalkaHomeBannerAction.none,
      startsAt: DateTime.utc(2026, 8, 13, 10, 1),
      endsAt: DateTime.utc(2026, 8, 13, 10, 2),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: Scaffold(
          body: WalkaScheduledHomeBanner(
            content: content,
            onBrowse: () {},
            onSearch: () {},
            horizontalPadding: 16,
            clock: () => current,
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey<String>('home-banner-inactive')), findsOneWidget);

    current = DateTime.utc(2026, 8, 13, 10, 1, 1);
    await tester.pump(const Duration(minutes: 1, milliseconds: 30));
    expect(find.byKey(const ValueKey<String>('home-banner-active')), findsOneWidget);
    expect(find.text('Scheduled exactly'), findsOneWidget);

    current = DateTime.utc(2026, 8, 13, 10, 2, 1);
    await tester.pump(const Duration(minutes: 1));
    expect(find.byKey(const ValueKey<String>('home-banner-inactive')), findsOneWidget);
    expect(find.text('Scheduled exactly'), findsNothing);
  });

  testWidgets('compiled banner routes browse/search actions without remote URLs',
      (WidgetTester tester) async {
    int browseCount = 0;
    int searchCount = 0;

    Future<void> pump(WalkaHomeBannerAction action) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: Scaffold(
            body: WalkaHomeBanner(
              content: _activeBanner(action),
              onBrowse: () => browseCount += 1,
              onSearch: () => searchCount += 1,
            ),
          ),
        ),
      );
    }

    await pump(WalkaHomeBannerAction.browse);
    await tester.tap(find.byKey(const ValueKey<String>('home-banner-cta')));
    expect(browseCount, 1);
    expect(searchCount, 0);

    await pump(WalkaHomeBannerAction.search);
    await tester.tap(find.byKey(const ValueKey<String>('home-banner-cta')));
    expect(browseCount, 1);
    expect(searchCount, 1);

    await pump(WalkaHomeBannerAction.none);
    expect(find.byKey(const ValueKey<String>('home-banner-cta')), findsNothing);
  });

  testWidgets('published active banner renders in the real Home composition',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    await catalog.load();
    final WalkaContentController content = WalkaContentController(
      homeBannerRepository: WalkaHomeBannerRepository(
        cache: _MemoryBannerCache(),
        remoteLoader: () async => _payload(
          revision: 10,
          content: const WalkaHomeBannerContent(
            enabled: true,
            eyebrow: 'LIVE WALKA NOTE',
            title: 'Backend-controlled Home announcement',
            body: 'This text arrived through the typed published banner contract.',
            ctaAction: WalkaHomeBannerAction.browse,
            ctaLabel: 'BROWSE WALKA',
          ),
        ),
      ),
    );
    await content.load();

    await tester.pumpWidget(
      WalkaContentScope(
        controller: content,
        child: WalkaCatalogScope(
          controller: catalog,
          child: MaterialApp(
            theme: buildWalkaTheme(),
            home: Scaffold(
              body: WalkaHomePremiumV122(
                onShopAll: () {},
                onSearch: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Backend-controlled Home announcement'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('home-banner-active')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _MemoryBannerCache implements WalkaHomeBannerCache {
  _MemoryBannerCache({this.value});

  WalkaHomeBannerSnapshot? value;
  int writeCount = 0;

  @override
  Future<WalkaHomeBannerSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaHomeBannerSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}

WalkaHomeBannerContent _activeBanner(WalkaHomeBannerAction action) {
  return WalkaHomeBannerContent(
    enabled: true,
    eyebrow: 'WALKA WEEK',
    title: 'A calmer week starts here',
    body: 'Explore organization while this announcement is active.',
    ctaAction: action,
    ctaLabel: action == WalkaHomeBannerAction.none ? null : 'EXPLORE WALKA',
  );
}

WalkaHomeBannerPayload _payload({
  required int revision,
  required WalkaHomeBannerContent content,
}) {
  return WalkaHomeBannerPayload(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 9),
    serverActive: content.isActiveAt(DateTime.utc(2026, 8, 13, 10, 30)),
    scheduleEvaluatedAt: DateTime.utc(2026, 8, 13, 10, 30),
  );
}

WalkaHomeBannerSnapshot _snapshot({
  required int revision,
  required WalkaHomeBannerContent content,
}) {
  return WalkaHomeBannerSnapshot(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 13, 9),
    fetchedAt: DateTime.utc(2026, 8, 13, 10),
    source: WalkaContentSource.cache,
  );
}
