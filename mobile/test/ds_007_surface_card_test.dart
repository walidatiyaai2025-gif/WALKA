import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/cards/walka_surface_card.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 240, child: child),
        ),
      ),
    );
  }

  Finder surfaceMaterial() {
    return find.descendant(
      of: find.byType(WalkaSurfaceCard),
      matching: find.byType(Material),
    );
  }

  testWidgets('uses WALKA surface tokens by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(const WalkaSurfaceCard(child: Text('Premium surface'))),
    );

    final Material material = tester.widget<Material>(surfaceMaterial());
    final RoundedRectangleBorder shape =
        material.shape! as RoundedRectangleBorder;

    expect(material.color, WalkaColors.white);
    expect(material.elevation, 0);
    expect(material.clipBehavior, Clip.antiAlias);
    expect(shape.borderRadius, BorderRadius.circular(WalkaRadius.md));
    expect(shape.side.color, WalkaColors.line);

    final Padding padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(WalkaSurfaceCard),
        matching: find.byType(Padding),
      ),
    );
    expect(padding.padding, const EdgeInsets.all(WalkaSpacing.md));
  });

  testWidgets('supports custom surface border radius and padding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaSurfaceCard(
          surfaceColor: WalkaColors.surface,
          borderColor: WalkaColors.gold,
          radius: WalkaRadius.lg,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text('Custom surface'),
        ),
      ),
    );

    final Material material = tester.widget<Material>(surfaceMaterial());
    final RoundedRectangleBorder shape =
        material.shape! as RoundedRectangleBorder;

    expect(material.color, WalkaColors.surface);
    expect(shape.borderRadius, BorderRadius.circular(WalkaRadius.lg));
    expect(shape.side.color, WalkaColors.gold);

    final Padding padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(WalkaSurfaceCard),
        matching: find.byType(Padding),
      ),
    );
    expect(
      padding.padding,
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  });

  testWidgets('adds ink interaction only when callback is supplied',
      (WidgetTester tester) async {
    var taps = 0;

    await tester.pumpWidget(
      app(
        WalkaSurfaceCard(
          onTap: () => taps += 1,
          semanticLabel: 'Open premium card',
          child: const Text('Open'),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(WalkaSurfaceCard),
        matching: find.byType(InkWell),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(taps, 1);

    await tester.pumpWidget(
      app(const WalkaSurfaceCard(child: Text('Static'))),
    );

    expect(
      find.descendant(
        of: find.byType(WalkaSurfaceCard),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
  });
}
