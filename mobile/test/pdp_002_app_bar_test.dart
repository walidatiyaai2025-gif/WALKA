import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/products/presentation/widgets/walka_pdp_app_bar.dart';

void main() {
  Widget app({
    required bool isFavorite,
    required VoidCallback onShare,
    required VoidCallback onFavorite,
  }) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(
        appBar: WalkaPdpAppBar(
          isFavorite: isFavorite,
          onShare: onShare,
          onFavorite: onFavorite,
        ),
        body: const SizedBox.expand(),
      ),
    );
  }

  testWidgets('preserves wordmark share and favorite actions',
      (WidgetTester tester) async {
    var shares = 0;
    var favorites = 0;

    await tester.pumpWidget(
      app(
        isFavorite: false,
        onShare: () => shares += 1,
        onFavorite: () => favorites += 1,
      ),
    );

    expect(find.text('WALKA'), findsOneWidget);
    expect(find.byTooltip('Share product'), findsOneWidget);
    expect(find.byTooltip('Add favorite'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('walka-pdp-share')));
    await tester.tap(find.byKey(const ValueKey<String>('walka-pdp-favorite')));
    await tester.pump();

    expect(shares, 1);
    expect(favorites, 1);
  });

  testWidgets('renders selected favorite state with released motion duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        isFavorite: true,
        onShare: () {},
        onFavorite: () {},
      ),
    );

    expect(find.byTooltip('Remove favorite'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

    final AnimatedSwitcher switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, WalkaPdpAppBar.favoriteSwitchDuration);
  });

  testWidgets('preserves bottom divider and zero-elevation chrome',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        isFavorite: false,
        onShare: () {},
        onFavorite: () {},
      ),
    );

    final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
    expect(bar.elevation, 0);
    expect(bar.scrolledUnderElevation, 0);
    expect(bar.centerTitle, isTrue);

    final Border border = bar.shape! as Border;
    expect(border.bottom.color, WalkaColors.line);
    expect(border.bottom.width, WalkaPdpAppBar.dividerWidth);
  });

  testWidgets('keeps AppBar default back navigation behavior',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => Scaffold(
                        appBar: WalkaPdpAppBar(
                          isFavorite: false,
                          onShare: () {},
                          onFavorite: () {},
                        ),
                        body: const Text('PDP'),
                      ),
                    ),
                  );
                },
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('OPEN'), findsOneWidget);
  });
}
