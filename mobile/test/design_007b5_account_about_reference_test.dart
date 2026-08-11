import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/information/information_v102.dart';
import 'package:walka/features/storefront/account_about_reference_v131.dart';
import 'package:walka/features/storefront/secondary_premium_v130.dart';

void main() {
  testWidgets(
    'reference Account is truthful and stable at 320x568 with 1.3x text',
    (WidgetTester tester) async {
      _compactViewport(tester);
      int favoritesCount = 0;

      await tester.pumpWidget(
        _app(
          home: WalkaAccountReferenceV131(
            onFavorites: () => favoritesCount += 1,
          ),
          textScale: 1.3,
        ),
      );
      await tester.pump();

      expect(find.text('Your WALKA Space'), findsWidgets);
      expect(find.text('No account or sign-in is required.'), findsOneWidget);

      // Reference-only mock commerce/account data must never become release truth.
      expect(find.text('Waleed Atiya'), findsNothing);
      expect(find.textContaining('VIP Club'), findsNothing);
      expect(find.text('Total Orders'), findsNothing);
      expect(find.text('Total Spent'), findsNothing);
      expect(find.text('Payment Methods'), findsNothing);
      expect(find.text('Sign Out'), findsNothing);
      expect(find.textContaining(r'$287'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -380),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Overview'), findsOneWidget);
      expect(find.text('5 variants'), findsOneWidget);
      expect(find.text('Amazon'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -430),
      );
      await tester.pumpAndSettle();

      final Finder favorites = find.byKey(
        const ValueKey<String>('reference-account-favorites'),
      );
      expect(favorites, findsOneWidget);
      await tester.tap(favorites);
      await tester.pump();
      expect(favoritesCount, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Our Story opens Android-reference About and survives compact scaling',
    (WidgetTester tester) async {
      _compactViewport(tester);

      await tester.pumpWidget(
        _app(
          home: WalkaAccountReferenceV131(onFavorites: () {}),
          textScale: 1.3,
        ),
      );
      await tester.pump();

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      final Finder story = find.byKey(
        const ValueKey<String>('reference-account-our-story'),
      );
      expect(story, findsOneWidget);
      await tester.tap(story);
      await tester.pumpAndSettle();

      expect(find.byType(WalkaAboutReferenceV131), findsOneWidget);
      expect(find.text('OUR STORY'), findsOneWidget);
      expect(find.textContaining('Organized living.'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      expect(tester.takeException(), isNull);

      final Finder howWeDesign = find.text('HOW WE DESIGN');
      await tester.scrollUntilVisible(
        howWeDesign,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(howWeDesign, findsOneWidget);
      expect(find.text('Useful first'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final Finder closing = find.byKey(
        const ValueKey<String>('reference-about-closing'),
      );
      await tester.scrollUntilVisible(
        closing,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(closing, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reference Account preserves support legal and app destinations',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _app(home: WalkaAccountReferenceV131(onFavorites: () {})),
      );
      await tester.pump();

      await _openAndReturn<WalkaFaqV102>(tester, 'reference-account-faq');
      await _openAndReturn<WalkaContactV102>(
        tester,
        'reference-account-contact-us',
      );
      await _openAndReturn<WalkaAmazonStoreV102>(
        tester,
        'reference-account-amazon-store',
      );
      await _openAndReturn<WalkaSocialV102>(
        tester,
        'reference-account-follow-walka',
      );
      await _openAndReturn<WalkaLegalV102>(tester, 'reference-account-privacy');
      await _openAndReturn<WalkaLegalV102>(tester, 'reference-account-terms');
      await _openAndReturn<WalkaAppInfoPremiumV130>(
        tester,
        'reference-account-app-information',
      );

      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _openAndReturn<T extends Widget>(
  WidgetTester tester,
  String key,
) async {
  final Finder action = find.byKey(ValueKey<String>(key));
  await tester.scrollUntilVisible(
    action,
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(action);
  await tester.pumpAndSettle();
  expect(find.byType(T), findsOneWidget);
  await tester.pageBack();
  await tester.pumpAndSettle();
}

MaterialApp _app({required Widget home, double textScale = 1}) {
  return MaterialApp(
    theme: buildWalkaTheme(),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      );
    },
    home: home,
  );
}

void _compactViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
