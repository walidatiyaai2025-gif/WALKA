import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_shell.dart';

void main() {
  List<Widget> pages() => WalkaShellDestination.values
      .map(
        (WalkaShellDestination item) => ColoredBox(
          color: Colors.white,
          child: SizedBox.expand(
            key: ValueKey<String>('page-${item.name}'),
            child: Center(child: Text(item.label)),
          ),
        ),
      )
      .toList(growable: false);

  test('shell controller exposes named destination + stable index', () {
    final WalkaShellController controller = WalkaShellController();
    expect(controller.destination, WalkaShellDestination.home);
    expect(controller.selectedIndex, 0);
    expect(controller.select(WalkaShellDestination.categories), isTrue);
    expect(controller.selectedIndex, 2);
    expect(controller.select(WalkaShellDestination.categories), isFalse);
    controller.dispose();
  });

  testWidgets('mobile scaffold preserves pages while switching tabs',
      (WidgetTester tester) async {
    final WalkaShellController controller = WalkaShellController();
    await tester.pumpWidget(
      MaterialApp(
        home: WalkaMobileShellScaffold(
          controller: controller,
          pages: pages(),
        ),
      ),
    );
    expect(find.byKey(const ValueKey<String>('page-home')), findsOneWidget);
    controller.select(WalkaShellDestination.favorites);
    await tester.pump();
    expect(
      find.byKey(
        const ValueKey<String>('page-home'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('Favorites'), findsWidgets);
    controller.dispose();
  });

  testWidgets('wide shell provides desktop-width content beyond mobile cap',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final WalkaShellController controller = WalkaShellController();
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1440, 900)),
          child: WalkaWideShellScaffold(
            controller: controller,
            pages: pages(),
          ),
        ),
      ),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    final Size homeSize = tester.getSize(
      find.byKey(const ValueKey<String>('page-home')),
    );
    expect(homeSize.width, greaterThan(560));
    controller.dispose();
  });

  testWidgets('safe-area chrome honors notch and home-indicator insets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 47, bottom: 34),
          ),
          child: Scaffold(
            body: WalkaSafeAreaChrome(
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  key: ValueKey<String>('safe-child'),
                  width: 10,
                  height: 10,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('safe-child'))).dy,
      greaterThanOrEqualTo(47),
    );
  });
}
