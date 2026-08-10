import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_gallery_viewport.dart';

void main() {
  late PageController controller;

  setUp(() {
    controller = PageController();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget app({
    int selectedIndex = 0,
    ValueChanged<int>? onPageChanged,
    ValueChanged<int>? onExpand,
  }) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: WalkaPdpGalleryViewport(
              controller: controller,
              selectedIndex: selectedIndex,
              kind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: const Color(0xFFF7F4EC),
              surface: const Color(0xFFF4EEDF),
              semanticLabel: 'Drawer gallery',
              onPageChanged: onPageChanged ?? (_) {},
              onExpand: onExpand ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('preserves released viewport geometry and page count',
      (WidgetTester tester) async {
    await tester.pumpWidget(app());

    final AspectRatio ratio = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ratio.aspectRatio, WalkaPdpGalleryViewport.aspectRatio);

    final Material material = tester.widget<Material>(
      find.descendant(
        of: find.byType(WalkaPdpGalleryViewport),
        matching: find.byType(Material),
      ).first,
    );
    expect(material.color, const Color(0xFFF4EEDF));
    expect(material.borderRadius, BorderRadius.circular(WalkaPdpGalleryViewport.radius));
    expect(material.clipBehavior, Clip.antiAlias);

    final PageView pageView = tester.widget<PageView>(
      find.byKey(const ValueKey<String>('walka-pdp-gallery-page-view')),
    );
    final SliverChildBuilderDelegate delegate =
        pageView.childrenDelegate as SliverChildBuilderDelegate;
    expect(delegate.childCount, WalkaPdpGalleryViewport.pageCount);
    expect(find.text('1 / 3'), findsOneWidget);
  });

  testWidgets('exposes product semantics and page-change callback',
      (WidgetTester tester) async {
    var changedTo = -1;
    await tester.pumpWidget(app(onPageChanged: (int value) => changedTo = value));

    expect(find.bySemanticsLabel('Drawer gallery view 1'), findsOneWidget);

    final PageView pageView = tester.widget<PageView>(
      find.byKey(const ValueKey<String>('walka-pdp-gallery-page-view')),
    );
    pageView.onPageChanged!(2);
    expect(changedTo, 2);
  });

  testWidgets('tapping a gallery page expands that page',
      (WidgetTester tester) async {
    var expanded = -1;
    await tester.pumpWidget(app(onExpand: (int value) => expanded = value));

    await tester.tap(
      find.byKey(const ValueKey<String>('walka-pdp-gallery-page-0')),
    );
    await tester.pump();

    expect(expanded, 0);
  });

  testWidgets('fullscreen affordance uses selected index and count badge',
      (WidgetTester tester) async {
    var expanded = -1;
    await tester.pumpWidget(
      app(selectedIndex: 2, onExpand: (int value) => expanded = value),
    );

    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.byTooltip('View fullscreen'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('walka-pdp-gallery-fullscreen')),
    );
    await tester.pump();

    expect(expanded, 2);
  });
}
