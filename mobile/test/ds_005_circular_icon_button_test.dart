import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/buttons/walka_circular_icon_button.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('keeps exact 48x48 geometry and token defaults',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        WalkaCircularIconButton(
          icon: Icons.favorite_border_rounded,
          tooltip: 'Favorite',
          onPressed: () {},
        ),
      ),
    );

    expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
    final IconButton button = tester.widget(find.byType(IconButton));
    expect(button.tooltip, 'Favorite');
    expect(
      button.style?.backgroundColor?.resolve(<WidgetState>{}),
      WalkaColors.white,
    );
    expect(
      button.style?.foregroundColor?.resolve(<WidgetState>{}),
      WalkaColors.navy,
    );
  });

  testWidgets('invokes callback and exposes tooltip',
      (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        WalkaCircularIconButton(
          icon: Icons.share_outlined,
          tooltip: 'Share product',
          onPressed: () => taps += 1,
        ),
      ),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(taps, 1);
    expect(find.byTooltip('Share product'), findsOneWidget);
  });

  testWidgets('passes disabled state to IconButton',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaCircularIconButton(
          icon: Icons.favorite_border_rounded,
          tooltip: 'Favorite',
          onPressed: null,
        ),
      ),
    );

    final IconButton button = tester.widget(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });
}
