import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/buttons/walka_favorite_button.dart';
import 'package:walka/design_system/walka_motion.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child, {bool disableAnimations = false}) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('renders unselected and selected WALKA heart states',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(WalkaFavoriteButton(isFavorite: false, onPressed: () {})),
    );

    Icon icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border_rounded));
    expect(icon.color, WalkaColors.navy);
    expect(icon.key, const ValueKey<bool>(false));

    await tester.pumpWidget(
      app(WalkaFavoriteButton(isFavorite: true, onPressed: () {})),
    );
    await tester.pumpAndSettle();

    icon = tester.widget<Icon>(find.byIcon(Icons.favorite_rounded));
    expect(icon.color, WalkaColors.gold);
    expect(icon.key, const ValueKey<bool>(true));
  });

  testWidgets('exposes toggled semantics and invokes callback',
      (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      app(
        WalkaFavoriteButton(
          isFavorite: true,
          onPressed: () => taps += 1,
        ),
      ),
    );

    final Finder semanticsFinder = find.descendant(
      of: find.byType(WalkaFavoriteButton),
      matching: find.byType(Semantics),
    );
    final Semantics semantics = tester.widget<Semantics>(semanticsFinder.first);
    expect(semantics.properties.button, isTrue);
    expect(semantics.properties.toggled, isTrue);
    expect(semantics.properties.enabled, isTrue);
    expect(semantics.properties.label, 'Remove favorite');

    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('supports custom tooltips and disabled state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaFavoriteButton(
          isFavorite: false,
          onPressed: null,
          addTooltip: 'Save product',
        ),
      ),
    );

    final IconButton button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    final Icon icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border_rounded));
    expect(icon.color, WalkaColors.muted);

    final Finder semanticsFinder = find.descendant(
      of: find.byType(WalkaFavoriteButton),
      matching: find.byType(Semantics),
    );
    final Semantics semantics = tester.widget<Semantics>(semanticsFinder.first);
    expect(semantics.properties.enabled, isFalse);
    expect(semantics.properties.label, 'Save product');
  });

  testWidgets('respects reduced-motion accessibility setting',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        WalkaFavoriteButton(isFavorite: false, onPressed: () {}),
        disableAnimations: true,
      ),
    );

    final AnimatedSwitcher switcher =
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
    expect(switcher.duration, Duration.zero);

    await tester.pumpWidget(
      app(WalkaFavoriteButton(isFavorite: false, onPressed: () {})),
    );
    final AnimatedSwitcher animated =
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher));
    expect(animated.duration, WalkaMotion.standard);
  });
}
