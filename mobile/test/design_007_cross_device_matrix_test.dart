import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/product_experience_v100.dart';
import 'package:walka/features/storefront/account_about_reference_v131.dart';
import 'package:walka/features/storefront/discovery_reference_v123.dart';
import 'package:walka/features/storefront/favorites_reference_v131.dart';
import 'package:walka/features/storefront/home_premium_v122.dart';
import 'package:walka/features/storefront/storefront_v102.dart';

void main() {
  const List<_VisualDevice> devices = <_VisualDevice>[
    _VisualDevice('compact', Size(320, 568), 1.0),
    _VisualDevice('compact-1.3x', Size(320, 568), 1.3),
    _VisualDevice('standard', Size(390, 844), 1.0),
    _VisualDevice('standard-1.3x', Size(390, 844), 1.3),
    _VisualDevice('large', Size(430, 932), 1.0),
  ];

  for (final _VisualDevice device in devices) {
    testWidgets(
      'critical surfaces render and scroll without exceptions on ${device.name}',
      (WidgetTester tester) async {
        _setViewport(tester, device.size);
        final WalkaCatalogController catalog = WalkaCatalogController();
        addTearDown(catalog.dispose);
        final WalkaFavoritesController favorites = WalkaFavoritesController(
          _MemoryFavoritesStore(<String>{
            WalkaFavoritesController.drawerWhiteId,
            WalkaFavoritesController.drawerGrayId,
          }),
        );
        await favorites.load();
        addTearDown(favorites.dispose);

        final List<_SurfaceCase> surfaces = <_SurfaceCase>[
          _SurfaceCase(
            'Home',
            WalkaHomePremiumV122(onShopAll: () {}, onSearch: () {}),
            scrollPasses: 6,
          ),
          const _SurfaceCase(
            'Search',
            WalkaSearchPremiumV123(),
            scrollPasses: 4,
          ),
          const _SurfaceCase(
            'Categories',
            WalkaCategoriesPremiumV123(),
            scrollPasses: 5,
          ),
          _SurfaceCase(
            'Favorites',
            WalkaFavoritesReferenceV131(onExplore: () {}),
            scrollPasses: 4,
          ),
          _SurfaceCase(
            'Account',
            WalkaAccountReferenceV131(onFavorites: () {}),
            scrollPasses: 7,
          ),
          const _SurfaceCase(
            'About',
            WalkaAboutReferenceV131(),
            scrollPasses: 7,
          ),
          const _SurfaceCase(
            'Drawer PDP',
            WalkaDrawerProductDetailV100(initialGray: true),
            scrollPasses: 7,
          ),
          const _SurfaceCase(
            'Lunch PDP',
            WalkaLunchProductDetailV100(
              initialVariant: WalkaLunchVariant.green,
            ),
            scrollPasses: 8,
          ),
        ];

        for (final _SurfaceCase surface in surfaces) {
          await tester.pumpWidget(
            _harness(
              catalog: catalog,
              favorites: favorites,
              textScale: device.textScale,
              child: surface.child,
            ),
          );
          await tester.pump();
          _expectNoVisualException(tester, '${device.name} · ${surface.name}');

          await _sweepPrimaryScroll(
            tester,
            passes: surface.scrollPasses,
            label: '${device.name} · ${surface.name}',
          );
        }
      },
    );
  }

  testWidgets(
    'five-tab shell remains navigable on compact 1.3x text',
    (WidgetTester tester) async {
      _setViewport(tester, const Size(320, 568));
      final WalkaCatalogController catalog = WalkaCatalogController();
      addTearDown(catalog.dispose);
      final WalkaFavoritesController favorites = WalkaFavoritesController(
        _MemoryFavoritesStore(<String>{
          WalkaFavoritesController.drawerWhiteId,
        }),
      );
      await favorites.load();
      addTearDown(favorites.dispose);

      await tester.pumpWidget(
        _harness(
          catalog: catalog,
          favorites: favorites,
          textScale: 1.3,
          child: const WalkaStorefrontShellV102(),
        ),
      );
      await tester.pump();

      const List<String> destinations = <String>[
        'Home',
        'Search',
        'Categories',
        'Favorites',
        'Account',
      ];
      for (final String destination in destinations) {
        final Finder target = find.text(destination).last;
        expect(target, findsOneWidget, reason: 'Missing $destination tab label');
        await tester.tap(target);
        await tester.pumpAndSettle();
        _expectNoVisualException(tester, 'compact shell · $destination');
      }
    },
  );

  testWidgets(
    'safe-area insets do not destabilize primary shell on standard phone',
    (WidgetTester tester) async {
      _setViewport(tester, const Size(390, 844));
      final WalkaCatalogController catalog = WalkaCatalogController();
      addTearDown(catalog.dispose);
      final WalkaFavoritesController favorites = WalkaFavoritesController(
        _MemoryFavoritesStore(),
      );
      await favorites.load();
      addTearDown(favorites.dispose);

      await tester.pumpWidget(
        _harness(
          catalog: catalog,
          favorites: favorites,
          textScale: 1.0,
          safeInsets: const EdgeInsets.only(top: 28, bottom: 24),
          child: const WalkaStorefrontShellV102(),
        ),
      );
      await tester.pump();

      _expectNoVisualException(tester, 'standard shell · safe area');
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    },
  );

  testWidgets(
    'PDP sticky Amazon CTA remains present across compact and large widths',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final Size size in <Size>[
        const Size(320, 568),
        const Size(430, 932),
      ]) {
        _setViewportNow(tester, size);
        final WalkaCatalogController catalog = WalkaCatalogController();
        final WalkaFavoritesController favorites = WalkaFavoritesController(
          _MemoryFavoritesStore(),
        );
        await favorites.load();

        for (final Widget product in <Widget>[
          const WalkaDrawerProductDetailV100(),
          const WalkaLunchProductDetailV100(
            initialVariant: WalkaLunchVariant.pink,
          ),
        ]) {
          await tester.pumpWidget(
            _harness(
              catalog: catalog,
              favorites: favorites,
              textScale: size.width <= 320 ? 1.3 : 1.0,
              child: product,
            ),
          );
          await tester.pump();
          expect(find.text('BUY ON AMAZON'), findsOneWidget);
          _expectNoVisualException(tester, 'PDP CTA · ${size.width.toInt()}');
        }
        favorites.dispose();
        catalog.dispose();
      }
    },
  );
}

Widget _harness({
  required WalkaCatalogController catalog,
  required WalkaFavoritesController favorites,
  required double textScale,
  required Widget child,
  EdgeInsets safeInsets = EdgeInsets.zero,
}) {
  return WalkaCatalogScope(
    controller: catalog,
    child: WalkaFavoritesScope(
      controller: favorites,
      child: MaterialApp(
        theme: buildWalkaTheme(),
        builder: (BuildContext context, Widget? builtChild) {
          final MediaQueryData media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(textScale),
              padding: safeInsets,
              viewPadding: safeInsets,
            ),
            child: builtChild!,
          );
        },
        home: child,
      ),
    ),
  );
}

Future<void> _sweepPrimaryScroll(
  WidgetTester tester, {
  required int passes,
  required String label,
}) async {
  final Finder primary = find.byType(CustomScrollView);
  if (primary.evaluate().isEmpty) return;

  for (int index = 0; index < passes; index += 1) {
    await tester.drag(primary.first, const Offset(0, -360));
    await tester.pumpAndSettle();
    _expectNoVisualException(tester, '$label · scroll ${index + 1}');
  }
}

void _expectNoVisualException(WidgetTester tester, String label) {
  expect(tester.takeException(), isNull, reason: label);
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _setViewportNow(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
}

class _VisualDevice {
  const _VisualDevice(this.name, this.size, this.textScale);

  final String name;
  final Size size;
  final double textScale;
}

class _SurfaceCase {
  const _SurfaceCase(this.name, this.child, {required this.scrollPasses});

  final String name;
  final Widget child;
  final int scrollPasses;
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  _MemoryFavoritesStore([Set<String>? initialIds])
      : ids = Set<String>.from(initialIds ?? const <String>{});

  Set<String> ids;

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
