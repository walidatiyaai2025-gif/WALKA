import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/storefront/home_premium_v121.dart';

void main() {
  testWidgets('diagnose compact Home overflow tree', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaCatalogController catalog = WalkaCatalogController();
    addTearDown(catalog.dispose);
    final WalkaFavoritesController favorites = WalkaFavoritesController(
      _MemoryFavoritesStore(),
    );
    await favorites.load();
    addTearDown(favorites.dispose);

    await tester.pumpWidget(
      WalkaCatalogScope(
        controller: catalog,
        child: WalkaFavoritesScope(
          controller: favorites,
          child: MaterialApp(
            theme: buildWalkaTheme(),
            home: WalkaHomePremiumV121(
              onShopAll: () {},
              onSearch: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final FlutterExceptionHandler? previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('=== DESIGN-007 LIVE HOME RENDER ERROR ===');
      debugPrint(details.toString());
      debugPrint('=== END DESIGN-007 LIVE HOME RENDER ERROR ===');
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    final Finder scroll = find.byType(CustomScrollView);
    for (int index = 0; index < 3; index += 1) {
      await tester.drag(scroll, const Offset(0, -360));
      await tester.pumpAndSettle();
    }

    final Object? exception = tester.takeException();
    expect(exception, isNotNull);
  });
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
