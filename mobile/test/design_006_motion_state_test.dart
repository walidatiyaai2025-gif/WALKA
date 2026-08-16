import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_motion.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/catalog/data/walka_catalog_cache.dart';
import 'package:walka/features/catalog/data/walka_catalog_repository.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/storefront/catalog_state_surface_v130.dart';
import 'package:walka/features/storefront/catalog_status_v130.dart';
import 'package:walka/features/storefront/storefront_v102.dart';

void main() {
  testWidgets('WALKA motion collapses to zero when animations are disabled',
      (WidgetTester tester) async {
    Duration? resolved;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (BuildContext context) {
              resolved = WalkaMotion.duration(context, WalkaMotion.standard);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(resolved, Duration.zero);
  });

  testWidgets('loading banner remains static under reduced motion',
      (WidgetTester tester) async {
    final WalkaCatalogController controller = WalkaCatalogController(
      repository: WalkaCatalogRepository(cache: _MemoryCatalogCache()),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        controller: controller,
        disableAnimations: true,
        child: WalkaCatalogStatusBanner(controller: controller),
      ),
    );

    expect(controller.isLoading, isTrue);
    expect(
      find.byKey(const ValueKey<String>('walka-catalog-status-loading')),
      findsOneWidget,
    );
    expect(find.text('Refreshing the WALKA catalog'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byKey(const ValueKey<String>('walka-catalog-retry')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cache and unavailable states expose distinct recovery feedback',
      (WidgetTester tester) async {
    final WalkaCatalogController cached = WalkaCatalogController(
      repository: WalkaCatalogRepository(
        cache: _MemoryCatalogCache(
          snapshot: _dynamicSnapshot().asSource(WalkaCatalogSource.cache),
        ),
      ),
    );
    addTearDown(cached.dispose);
    await cached.load();

    await tester.pumpWidget(
      _app(
        controller: cached,
        child: WalkaCatalogStatusBanner(controller: cached),
      ),
    );

    expect(cached.isUsingCache, isTrue);
    expect(find.text('Offline · saved catalog'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('walka-catalog-retry')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final WalkaCatalogController unavailable = WalkaCatalogController(
      repository: WalkaCatalogRepository(cache: _MemoryCatalogCache()),
    );
    addTearDown(unavailable.dispose);
    await unavailable.load();

    await tester.pumpWidget(
      _app(
        controller: unavailable,
        child: WalkaCatalogStatusBanner(controller: unavailable),
      ),
    );

    expect(unavailable.isUnavailable, isTrue);
    expect(unavailable.isUsingBundledFallback, isFalse);
    expect(find.text('Catalog temporarily unavailable'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('walka-catalog-retry')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('V130 state surface never renders catalog child while unavailable',
      (WidgetTester tester) async {
    final WalkaCatalogController controller = WalkaCatalogController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        controller: controller,
        child: const WalkaCatalogStateSurfaceV130(
          child: _CatalogProbe(),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('walka-catalog-status-unavailable')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('walka-catalog-unavailable')),
      findsOneWidget,
    );
    expect(find.byType(_CatalogProbe), findsNothing);
    expect(controller.isOffline, isTrue);
    expect(controller.snapshot.source, WalkaCatalogSource.unavailable);
    expect(tester.takeException(), isNull);
  });

  testWidgets('public shell stays usable when catalog is unavailable',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaFavoritesController favorites = WalkaFavoritesController(
      _MemoryFavoritesStore(),
    );
    await favorites.load();
    addTearDown(favorites.dispose);

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: favorites,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
                disableAnimations: true,
              ),
              child: child!,
            );
          },
          home: const WalkaStorefrontShellV102(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Catalog temporarily unavailable'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(tester.takeException(), isNull);

    NavigationBar navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 0);

    await tester.tap(find.byIcon(Icons.search_outlined));
    await tester.pumpAndSettle();

    navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 1);
    expect(find.text('Catalog temporarily unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('press feedback transforms without changing layout bounds',
      (WidgetTester tester) async {
    const Key targetKey = ValueKey<String>('press-target');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WalkaPressFeedback(
              child: SizedBox(
                key: targetKey,
                width: 180,
                height: 80,
                child: Material(
                  child: InkWell(onTap: () {}),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Rect before = tester.getRect(find.byKey(targetKey));
    final TestGesture gesture = await tester.startGesture(before.center);
    await tester.pump(const Duration(milliseconds: 60));
    final Rect during = tester.getRect(find.byKey(targetKey));

    expect(during, before);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(targetKey)), before);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({
  required WalkaCatalogController controller,
  required Widget child,
  bool disableAnimations = false,
}) {
  return WalkaCatalogScope(
    controller: controller,
    child: MaterialApp(
      theme: buildWalkaTheme(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: child),
      ),
    ),
  );
}

WalkaCatalogSnapshot _dynamicSnapshot() {
  return WalkaCatalogSnapshot(
    config: const WalkaStorefrontConfig(
      brand: 'WALKA',
      release: 'dynamic-test',
      apiVersion: 'v1',
      purchaseMode: 'amazon_redirect',
    ),
    categories: const <WalkaCatalogCategory>[
      WalkaCatalogCategory(id: 'workspace', name: 'Workspace', sortOrder: 0),
    ],
    products: const <WalkaCatalogProduct>[
      WalkaCatalogProduct(
        id: 'desk-kit',
        name: 'Desk Kit',
        category: 'workspace',
        features: <String>['Dashboard managed'],
        facts: <String, dynamic>{},
        variants: <WalkaCatalogVariant>[
          WalkaCatalogVariant(
            id: 'desk-kit:midnight',
            color: 'Midnight',
            asin: 'B012345678',
            swatchHex: '#102030',
            purchaseUrl: 'https://www.amazon.com/dp/B012345678',
          ),
        ],
      ),
    ],
    source: WalkaCatalogSource.remote,
    fetchedAt: DateTime.utc(2026, 8, 16),
  );
}

class _CatalogProbe extends StatelessWidget {
  const _CatalogProbe();

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    return Text(
      'loading:${controller.isLoading} '
      'offline:${controller.isOffline} '
      'source:${controller.snapshot.source.name}',
    );
  }
}

class _MemoryCatalogCache implements WalkaCatalogCache {
  _MemoryCatalogCache({this.snapshot});

  WalkaCatalogSnapshot? snapshot;

  @override
  Future<void> clear() async {
    snapshot = null;
  }

  @override
  Future<WalkaCatalogSnapshot?> read() async => snapshot;

  @override
  Future<void> write(WalkaCatalogSnapshot value) async {
    snapshot = value.asSource(WalkaCatalogSource.cache);
  }
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  Set<String> ids = <String>{};

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
