import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/layout/walka_responsive_grid.dart';
import 'package:walka/design_system/components/media/walka_product_media.dart';
import 'package:walka/design_system/components/media/walka_product_media_frame.dart';
import 'package:walka/design_system/walka_product_visual.dart';

void main() {
  Widget app(Widget child, {double width = 360}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 700)),
          child: Scaffold(body: SizedBox(width: width, child: child)),
        ),
      );

  testWidgets('media frame keeps aspect ratio, semantics and callback',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    var taps = 0;
    try {
      await tester.pumpWidget(
        app(
          WalkaProductMediaFrame(
            semanticLabel: 'Product media',
            aspectRatio: 2,
            onTap: () => taps += 1,
            child: const ColoredBox(color: Colors.white),
          ),
          width: 300,
        ),
      );
      final Size size = tester.getSize(find.byType(WalkaProductMediaFrame));
      expect(size.width / size.height, closeTo(2, 0.01));
      final SemanticsNode node = tester.getSemantics(find.byType(WalkaProductMediaFrame));
      expect(node.label, 'Product media');
      expect(node.flagsCollection.isImage, isTrue);
      expect(node.flagsCollection.isButton, isTrue);
      await tester.tap(find.byType(WalkaProductMediaFrame));
      expect(taps, 1);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('painted adapter preserves WalkaProductVisual',
      (WidgetTester tester) async {
    const WalkaPaintedProductMedia media = WalkaPaintedProductMedia(
      kind: WalkaProductVisualKind.drawerOrganizer,
      primaryColor: Colors.white,
      semanticLabel: 'Drawer visual',
    );
    await tester.pumpWidget(
      app(
        const SizedBox(
          height: 180,
          child: WalkaProductMediaView(media: media),
        ),
      ),
    );
    expect(find.byType(WalkaProductVisual), findsOneWidget);
  });

  testWidgets('responsive grid changes columns without reordering children',
      (WidgetTester tester) async {
    Widget grid(double width) => app(
          WalkaResponsiveGrid(
            minItemWidth: 180,
            gap: 16,
            children: List<Widget>.generate(
              4,
              (int index) => SizedBox(
                key: ValueKey<int>(index),
                height: 40,
                child: Text('Item $index'),
              ),
            ),
          ),
          width: width,
        );

    await tester.pumpWidget(grid(320));
    final double y0 = tester.getTopLeft(find.byKey(const ValueKey<int>(0))).dy;
    final double y1 = tester.getTopLeft(find.byKey(const ValueKey<int>(1))).dy;
    expect(y1, greaterThan(y0));

    await tester.pumpWidget(grid(820));
    final double wideY0 = tester.getTopLeft(find.byKey(const ValueKey<int>(0))).dy;
    final double wideY1 = tester.getTopLeft(find.byKey(const ValueKey<int>(1))).dy;
    expect(wideY1, wideY0);
    expect(find.text('Item 3'), findsOneWidget);
  });
}
