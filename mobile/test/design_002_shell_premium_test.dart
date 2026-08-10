import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:walka/design_system/walka_shell.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/storefront/storefront_v102.dart';

void main() {
  testWidgets('premium navigation keeps five destinations on 320x568',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: Scaffold(
          bottomNavigationBar: WalkaPremiumNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final Finder navigation = find.byType(NavigationBar);
    expect(navigation, findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(tester.widget<NavigationBar>(navigation).selectedIndex, 0);
    expect(tester.getSize(navigation).height, 72);
    expect(tester.takeException(), isNull);
  });

  testWidgets('premium navigation updates selected destination',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    int selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              bottomNavigationBar: WalkaPremiumNavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (int value) {
                  setState(() => selectedIndex = value);
                },
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(selectedIndex, 1);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared shell icon action preserves 48dp target',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: Scaffold(
          body: Center(
            child: WalkaShellIconButton(
              icon: Icons.search_rounded,
              tooltip: 'Search',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Size target = tester.getSize(find.byType(IconButton));
    expect(target.width, greaterThanOrEqualTo(48));
    expect(target.height, greaterThanOrEqualTo(48));
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('storefront splash uses the owner WALKA brand mark',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaStorefrontSplashV102(),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('WALKA For You'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.text('ENTER WALKA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
