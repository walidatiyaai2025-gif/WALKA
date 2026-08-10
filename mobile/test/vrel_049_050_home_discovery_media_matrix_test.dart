import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/features/storefront/presentation/widgets/discovery/walka_category_card.dart';
import 'package:walka/features/storefront/presentation/widgets/home/walka_home_hero.dart';

void main() {
  for (final Size size in <Size>[
    const Size(320, 760),
    const Size(430, 900),
    const Size(1280, 900),
  ]) {
    testWidgets('Home production-media boundary is resilient at ${size.width}', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WalkaHomeHero(
              lunchSemanticLabel: 'WALKA Lunch Box hero',
              drawerSemanticLabel: 'WALKA Drawer Organizer hero',
              onOpenLunch: () {},
              onShopAll: () {},
              onSearch: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const ValueKey<String>('home-reference-hero')), findsOneWidget);
      expect(find.byType(WalkaResolvedProductMedia), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Discovery category media boundary is resilient at ${size.width}', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: size.width < 500 ? size.width - 32 : 420,
                child: WalkaCategoryCard(
                  variantId: 'drawer-organizer:white',
                  title: 'Drawer Organizers',
                  subtitle: 'Everyday organization',
                  kind: WalkaProductVisualKind.drawerOrganizer,
                  primaryColor: const Color(0xFFF7F4EC),
                  surface: const Color(0xFFF4EEDF),
                  badge: 'Explore',
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(WalkaResolvedProductMedia), findsOneWidget);
      expect(find.text('Drawer Organizers'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
