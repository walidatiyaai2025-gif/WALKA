import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_shell.dart';

void main() {
  test('typed destinations preserve the released stable order', () {
    expect(
      WalkaShellDestination.values.map((item) => item.label).toList(),
      <String>['Home', 'Search', 'Categories', 'Favorites', 'Account'],
    );
    expect(WalkaShellDestination.categories.index, 2);
    expect(WalkaShellDestination.fromIndex(3), WalkaShellDestination.favorites);
  });

  testWidgets('splash brand mark exposes one image semantic',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: WalkaSplashBrandMark(compact: true),
          ),
        ),
      );
      expect(find.bySemanticsLabel('WALKA For You'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('splash content preserves owner copy and enter callback',
      (WidgetTester tester) async {
    var entered = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            height: 640,
            child: WalkaSplashContent(
              compact: true,
              onEnter: () => entered += 1,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Thoughtful pieces.\nBeautifully organized.'), findsOneWidget);
    expect(find.text('CONNECTED CATALOG · 1.2.0'), findsOneWidget);
    await tester.tap(find.text('ENTER WALKA'));
    expect(entered, 1);
  });

  testWidgets('premium navigation uses typed destinations and selection',
      (WidgetTester tester) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: WalkaPremiumNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (int value) => selected = value,
          ),
        ),
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    await tester.tap(find.text('Search'));
    expect(selected, 1);
  });

  testWidgets('premium navigation collapses owned animation for reduced motion',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            bottomNavigationBar: WalkaPremiumNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      ),
    );
    final NavigationBar bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.animationDuration, Duration.zero);
  });
}
