import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/favorites/favorites_state.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/products/product_experience_v100.dart';

void main() {
  testWidgets(
    'Drawer PDP stays conversion-ready on 320x568 at 1.3x text scale',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final WalkaFavoritesController favorites = _favorites();
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
                ),
                child: child!,
              );
            },
            home: const WalkaDrawerProductDetailV100(initialGray: true),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('WALKA Drawer Organizer'), findsOneWidget);
      expect(find.text('BUY ON AMAZON'), findsOneWidget);
      expect(find.text('GRAY'), findsOneWidget);
      expect(find.byTooltip('View fullscreen'), findsOneWidget);
      expect(find.bySemanticsLabel('Gallery view 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Lunch PDP stays accurate on 320x568 at 1.3x text scale',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            );
          },
          home: const WalkaLunchProductDetailV100(
            initialVariant: WalkaLunchVariant.green,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Large Stainless Steel Bento Lunch Box'), findsOneWidget);
      expect(find.text('BUY ON AMAZON'), findsOneWidget);
      expect(find.textContaining('Green · PANTONE 6198 U'), findsOneWidget);
      expect(find.byTooltip('Share product'), findsOneWidget);
      expect(find.byTooltip('View fullscreen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'PDP gallery remains discoverable and opens zoomable fullscreen view',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final WalkaFavoritesController favorites = _favorites();
      await favorites.load();
      addTearDown(favorites.dispose);

      await tester.pumpWidget(
        WalkaFavoritesScope(
          controller: favorites,
          child: MaterialApp(
            theme: buildWalkaTheme(),
            home: const WalkaDrawerProductDetailV100(),
          ),
        ),
      );
      await tester.pump();

      expect(find.bySemanticsLabel('Gallery view 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Gallery view 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Gallery view 3'), findsOneWidget);

      final Finder fullscreenButton = find.ancestor(
        of: find.byIcon(Icons.fullscreen_rounded),
        matching: find.byType(IconButton),
      );
      expect(fullscreenButton, findsOneWidget);
      final IconButton fullscreenControl = tester.widget<IconButton>(
        fullscreenButton,
      );
      expect(fullscreenControl.onPressed, isNotNull);
      fullscreenControl.onPressed!();
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsWidgets);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Lunch variant choice updates the selected commerce identity',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaLunchProductDetailV100(),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Blue · PANTONE 4155 U'), findsOneWidget);
      final Finder pinkVariant = find.byKey(
        const ValueKey<String>('premium-lunch-pink'),
      );
      expect(pinkVariant, findsOneWidget);
      final Finder pinkControl = find.descendant(
        of: pinkVariant,
        matching: find.byType(InkWell),
      );
      expect(pinkControl, findsOneWidget);
      final InkWell pinkInkWell = tester.widget<InkWell>(pinkControl);
      expect(pinkInkWell.onTap, isNotNull);
      pinkInkWell.onTap!();
      await tester.pumpAndSettle();

      expect(find.textContaining('Pink · PANTONE 9242 U'), findsOneWidget);
      expect(find.text('PINK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('premium PDP keeps share handoff discoverable',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaLunchProductDetailV100(
          initialVariant: WalkaLunchVariant.green,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Share product'));
    await tester.pumpAndSettle();

    expect(find.text('SHARE WALKA'), findsOneWidget);
    expect(find.text('COPY PRODUCT LINK'), findsOneWidget);
    expect(find.text('WALKA Large Bento Lunch Box · Green'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

WalkaFavoritesController _favorites() {
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
