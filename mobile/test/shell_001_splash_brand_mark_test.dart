import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/chrome/walka_splash_brand_mark.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app({required bool compact}) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        backgroundColor: WalkaColors.navy,
        body: Center(child: WalkaSplashBrandMark(compact: compact)),
      ),
    );
  }

  testWidgets('preserves official SVG and compact width',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(compact: true));

    final SvgPicture logo = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(logo.width, WalkaSplashBrandMark.compactWidth);
    expect(logo.fit, BoxFit.contain);
    expect(find.bySemanticsLabel(WalkaSplashBrandMark.semanticLabel), findsOneWidget);
  });

  testWidgets('uses released standard width', (WidgetTester tester) async {
    await tester.pumpWidget(app(compact: false));

    final SvgPicture logo = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(logo.width, WalkaSplashBrandMark.standardWidth);
  });

  testWidgets('exposes one image semantic and hides SVG internals',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(app(compact: false));

      final SemanticsNode node = tester.getSemantics(
        find.bySemanticsLabel(WalkaSplashBrandMark.semanticLabel),
      );
      expect(node.flagsCollection.isImage, isTrue);
      expect(node.label, WalkaSplashBrandMark.semanticLabel);
    } finally {
      handle.dispose();
    }
  });
}
