import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/storefront/account_about_reference_v131.dart';

void main() {
  Future<void> pumpDevice(
    WidgetTester tester,
    Widget child, {
    required Size size,
    double textScale = 1,
    TargetPlatform platform = TargetPlatform.android,
    EdgeInsets padding = EdgeInsets.zero,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: padding,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(body: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Account is truthful and compact-safe at 320x568 / 1.3x',
      (WidgetTester tester) async {
    var favorites = 0;
    await pumpDevice(
      tester,
      WalkaAccountReferenceV131(onFavorites: () => favorites += 1),
      size: const Size(320, 568),
      textScale: 1.3,
    );

    expect(find.text('Your WALKA Space'), findsOneWidget);
    expect(find.text('No account or sign-in is required.'), findsOneWidget);
    expect(find.text('5 variants'), findsOneWidget);
    expect(find.text('Amazon'), findsOneWidget);
    expect(find.textContaining('VIP'), findsNothing);
    expect(find.textContaining('Payment method'), findsNothing);
    expect(tester.takeException(), isNull);

    final Finder favoritesTile = find.text('Favorites').last;
    await tester.ensureVisible(favoritesTile);
    await tester.pumpAndSettle();
    await tester.tap(favoritesTile);
    expect(favorites, 1);
  });

  testWidgets('Account respects representative iOS safe-area insets',
      (WidgetTester tester) async {
    await pumpDevice(
      tester,
      WalkaAccountReferenceV131(onFavorites: () {}),
      size: const Size(390, 844),
      platform: TargetPlatform.iOS,
      padding: const EdgeInsets.fromLTRB(0, 47, 0, 34),
    );

    final Rect topBar = tester.getRect(
      find.byKey(const ValueKey<String>('reference-account-topbar')),
    );
    expect(topBar.top, greaterThanOrEqualTo(47));
    expect(tester.takeException(), isNull);
  });

  for (final double width in <double>[1280, 1440]) {
    testWidgets('Account desktop composition is stable at ${width.toInt()}px',
        (WidgetTester tester) async {
      await pumpDevice(
        tester,
        WalkaAccountReferenceV131(onFavorites: () {}),
        size: Size(width, 900),
      );

      // The desktop composition is intentionally finite-height/non-scrollable;
      // all destination groups are laid out in the wide grid at once.
      expect(find.text('Product & Support'), findsOneWidget);
      expect(find.text('Official Destinations'), findsOneWidget);
      expect(find.text('Legal & App'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('About keeps truthful story and Amazon boundary on compact iOS',
      (WidgetTester tester) async {
    await pumpDevice(
      tester,
      const WalkaAboutReferenceV131(),
      size: const Size(390, 844),
      textScale: 1.3,
      platform: TargetPlatform.iOS,
      padding: const EdgeInsets.fromLTRB(0, 47, 0, 34),
    );

    expect(find.text('Organized living.\nElevated everyday.'), findsOneWidget);
    expect(find.text('A calmer home begins with thoughtful details.'), findsOneWidget);
    expect(find.text('Purposeful'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('reference-about-closing')),
      300,
    );
    expect(
      find.textContaining('official Amazon listing'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final double width in <double>[1280, 1440]) {
    testWidgets('About desktop grids are stable at ${width.toInt()}px',
        (WidgetTester tester) async {
      await pumpDevice(
        tester,
        const WalkaAboutReferenceV131(),
        size: Size(width, 1000),
      );

      expect(find.text('Purposeful'), findsOneWidget);
      expect(find.text('Refined'), findsOneWidget);
      expect(find.text('Everyday'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
