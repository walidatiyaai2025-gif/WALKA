import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_benefit_band.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_collection_card.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_header.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_hero_actions.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_small_changes.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_trust_strip.dart';

void main() {
  Widget app(Widget child, {double width = 360, double textScale = 1}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 760),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('Home header preserves browse and search callbacks',
      (WidgetTester tester) async {
    var browse = 0;
    var search = 0;
    await tester.pumpWidget(
      app(
        WalkaHomeHeader(
          onBrowse: () => browse += 1,
          onSearch: () => search += 1,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('home-reference-browse')));
    await tester.tap(find.byKey(const ValueKey<String>('home-reference-search')));
    expect(browse, 1);
    expect(search, 1);
  });

  testWidgets('hero actions preserve labels and callbacks at 1.3x',
      (WidgetTester tester) async {
    var shop = 0;
    var search = 0;
    await tester.pumpWidget(
      app(
        WalkaHomeHeroActions(
          onShopAll: () => shop += 1,
          onSearch: () => search += 1,
        ),
        width: 280,
        textScale: 1.3,
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('SHOP PRODUCTS'));
    await tester.tap(find.text('SEARCH COLLECTION'));
    expect(shop, 1);
    expect(search, 1);
  });

  testWidgets('benefit and trust content stay truthful and compact-safe',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const Column(
          children: <Widget>[
            WalkaHomeBenefitBand(),
            SizedBox(height: 12),
            WalkaHomeTrustStrip(itemCount: 5, release: '1.2.0'),
          ],
        ),
        width: 300,
        textScale: 1.3,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Secure Lock'), findsOneWidget);
    expect(find.text('Helps prevent spills. Carry upright.'), findsOneWidget);
    expect(find.text('5 variants'), findsOneWidget);
    expect(find.text('Official Amazon'), findsOneWidget);
  });

  testWidgets('collection card and Small Changes keep caller actions',
      (WidgetTester tester) async {
    var cardTap = 0;
    var smallTap = 0;
    await tester.pumpWidget(
      app(
        Column(
          children: <Widget>[
            WalkaHomeCollectionCard(
              title: 'Drawer Organizers',
              subtitle: '8 compartments · expands from 13 to 22.4 in.',
              kind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: Colors.white,
              visualBackground: const Color(0xFFF0E2C7),
              semanticLabel: 'Drawer Organizer White',
              onTap: () => cardTap += 1,
            ),
            WalkaHomeSmallChanges(
              drawerSemanticLabel: 'Drawer lifestyle visual',
              onTap: () => smallTap += 1,
            ),
          ],
        ),
        width: 320,
        textScale: 1.3,
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Drawer Organizers'));
    await tester.tap(find.text('Small Changes,\nBetter Living'));
    expect(cardTap, 1);
    expect(smallTap, 1);
  });
}
