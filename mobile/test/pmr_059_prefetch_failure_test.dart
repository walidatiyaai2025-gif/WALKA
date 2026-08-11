import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';

void main() {
  testWidgets('PMR-059 captures registered missing asset prefetch as failed',
      (WidgetTester tester) async {
    const Key hostKey = ValueKey<String>('pmr-prefetch-failure-host');
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(key: hostKey, width: 12, height: 12),
      ),
    );

    final BuildContext context = tester.element(find.byKey(hostKey));
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver(
      assetsByVariant: <String, WalkaProductMediaAsset>{
        'drawer-organizer:white': WalkaProductMediaAsset(
          variantId: 'drawer-organizer:white',
          assetPath: 'assets/products/not-approved/pmr-prefetch-missing.png',
        ),
      },
    );

    final WalkaProductMediaPrefetchResult result =
        await resolver.prefetchVariant(
      context,
      variantId: 'drawer-organizer:white',
      surface: WalkaProductMediaSurface.discovery,
    );

    expect(result.variantId, 'drawer-organizer:white');
    expect(
      result.assetPath,
      'assets/products/not-approved/pmr-prefetch-missing.png',
    );
    expect(result.surface, WalkaProductMediaSurface.discovery);
    expect(result.failed, isTrue);
    expect(result.prefetched, isFalse);
    expect(result.skipped, isFalse);
    expect(tester.takeException(), isNull);
  });
}
