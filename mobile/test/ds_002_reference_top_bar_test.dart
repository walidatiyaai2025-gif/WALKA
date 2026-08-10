import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/chrome/walka_reference_top_bar.dart';
import 'package:walka/design_system/walka_reference_ui.dart' show WalkaReferenceHeader;
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('keeps wordmark centered with deterministic slots',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(const WalkaReferenceTopBar()));

    final Finder bar = find.byType(WalkaReferenceTopBar);
    expect(find.text('WALKA'), findsOneWidget);
    expect(tester.getSize(bar).height, WalkaReferenceTopBar.extent);

    final Rect barRect = tester.getRect(bar);
    final Rect wordmarkRect = tester.getRect(find.text('WALKA'));
    expect((barRect.center.dx - wordmarkRect.center.dx).abs(), lessThan(0.1));
  });

  testWidgets('supports action and decorative slots',
      (WidgetTester tester) async {
    var taps = 0;
    const Key leadingKey = ValueKey<String>('leading-action');

    await tester.pumpWidget(
      app(
        WalkaReferenceTopBar(
          leadingIcon: Icons.menu_rounded,
          leadingTooltip: 'Browse',
          leadingKey: leadingKey,
          onLeading: () => taps += 1,
          trailingIcon: Icons.search_rounded,
        ),
      ),
    );

    expect(tester.getSize(find.byKey(leadingKey)), const Size(48, 48));
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);

    await tester.tap(find.byKey(leadingKey));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('legacy header delegates to extracted component',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaReferenceHeader(
          leadingIcon: Icons.menu_rounded,
          trailingIcon: Icons.search_rounded,
        ),
      ),
    );

    expect(find.byType(WalkaReferenceTopBar), findsOneWidget);
    expect(find.text('WALKA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
