import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/products/product_experience_v100.dart';
import 'package:walka/features/storefront/storefront_v101.dart';

void main() {
  testWidgets('final Drawer PDP is stable on compact 320 by 568 phones',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaFavoritesController controller = _controller();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaDrawerProductDetailV100(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('BUY ON AMAZON'), findsOneWidget);
    expect(find.byTooltip('View fullscreen'), findsOneWidget);
    expect(find.byTooltip('Add favorite'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('final shell tolerates 130 percent text scaling',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaFavoritesController controller = _controller();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          builder: (BuildContext context, Widget? child) {
            final MediaQueryData media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            );
          },
          home: const WalkaStorefrontShellV101(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('final shell remains stable on a 900px large mobile viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final WalkaFavoritesController controller = _controller();
    await controller.load();

    await tester.pumpWidget(
      WalkaFavoritesScope(
        controller: controller,
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaStorefrontShellV101(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

WalkaFavoritesController _controller() {
  return WalkaFavoritesController(_MemoryFavoritesStore());
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
