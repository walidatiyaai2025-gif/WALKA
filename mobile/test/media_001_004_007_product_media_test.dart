import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';

void main() {
  WalkaPaintedProductMedia fallback() => const WalkaPaintedProductMedia(
        kind: WalkaProductVisualKind.drawerOrganizer,
        primaryColor: Color(0xFFF7F4EC),
        backgroundColor: Color(0xFFF4EEDF),
        semanticLabel: 'WALKA Drawer Organizer White',
      );

  test('MEDIA-004 resolves unknown/unapproved variants to painted fallback', () {
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver();
    final WalkaPaintedProductMedia painted = fallback();

    final WalkaProductMedia resolved = resolver.resolve(
      variantId: 'drawer-organizer:white',
      fallback: painted,
    );

    expect(identical(resolved, painted), isTrue);
    expect(resolver.hasApprovedAsset('drawer-organizer:white'), isFalse);
  });

  test('MEDIA-004 resolves registered variant to asset-backed media', () {
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver(
      assetsByVariant: <String, WalkaProductMediaAsset>{
        'drawer-organizer:white': WalkaProductMediaAsset(
          variantId: 'drawer-organizer:white',
          assetPath: 'assets/products/drawer/white.png',
        ),
      },
    );

    final WalkaProductMedia resolved = resolver.resolve(
      variantId: 'drawer-organizer:white',
      fallback: fallback(),
    );

    expect(resolved, isA<WalkaAssetProductMedia>());
    expect(resolver.hasApprovedAsset('drawer-organizer:white'), isTrue);
  });

  test('MEDIA-007 provides bounded default decode width', () {
    expect(WalkaProductMediaResolver.defaultCacheWidth, 1200);
    const WalkaProductMediaAsset asset = WalkaProductMediaAsset(
      variantId: 'lunch-box:blue',
      assetPath: 'assets/products/lunch/blue.png',
    );
    expect(asset.cacheWidth, 1200);
  });

  testWidgets('MEDIA-005 painted fallback stays deterministic',
      (WidgetTester tester) async {
    final WalkaProductMedia media = fallback();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: media.build(tester.element(find.byType(MaterialApp)))),
      ),
    );

    expect(find.byType(WalkaProductVisual), findsOneWidget);
  }, skip: true);

  testWidgets('MEDIA-006 missing asset exposes fallback semantics',
      (WidgetTester tester) async {
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver(
      assetsByVariant: <String, WalkaProductMediaAsset>{
        'drawer-organizer:white': WalkaProductMediaAsset(
          variantId: 'drawer-organizer:white',
          assetPath: 'assets/products/not-approved/missing.png',
        ),
      },
    );
    final WalkaProductMedia media = resolver.resolve(
      variantId: 'drawer-organizer:white',
      fallback: fallback(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(builder: (BuildContext context) => media.build(context)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'WALKA Drawer Organizer White. Product visual fallback.',
      ),
      findsOneWidget,
    );
  });
}
