import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/cards/walka_destination_tile.dart';
import 'package:walka/design_system/components/feedback/walka_catalog_feedback.dart';
import 'package:walka/design_system/components/typography/walka_divider_label.dart';

void main() {
  Widget app(Widget child, {double width = 360, double textScale = 1}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 640),
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

  testWidgets('catalog feedback renders loading and caller retry',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const WalkaCatalogFeedback(kind: WalkaCatalogFeedbackKind.loading)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Refreshing catalog'), findsOneWidget);

    var retries = 0;
    await tester.pumpWidget(
      app(
        WalkaCatalogFeedback(
          kind: WalkaCatalogFeedbackKind.cached,
          onRetry: () => retries += 1,
        ),
      ),
    );
    await tester.tap(find.text('TRY AGAIN'));
    expect(retries, 1);
  });

  testWidgets('divider label is a heading and wraps safely',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        app(
          const WalkaDividerLabel(
            label: 'Official destinations and support',
            showLeadingRule: true,
          ),
          width: 280,
          textScale: 1.3,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.text('OFFICIAL DESTINATIONS AND SUPPORT'))
            .flagsCollection
            .isHeader,
        isTrue,
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets('destination tile keeps 48px contract and semantic button',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    var taps = 0;
    try {
      await tester.pumpWidget(
        app(
          WalkaDestinationTile(
            icon: Icons.help_outline_rounded,
            title: 'FAQ',
            subtitle: 'Common questions',
            onTap: () => taps += 1,
          ),
          width: 280,
          textScale: 1.3,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(WalkaDestinationTile)).height, greaterThanOrEqualTo(48));
      final SemanticsNode node = tester.getSemantics(find.byType(WalkaDestinationTile));
      expect(node.flagsCollection.isButton, isTrue);
      await tester.tap(find.text('FAQ'));
      expect(taps, 1);
    } finally {
      handle.dispose();
    }
  });
}
