import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/accessibility/walka_interactive_region.dart';
import 'package:walka/design_system/components/chrome/walka_desktop_top_bar.dart';
import 'package:walka/design_system/components/layout/walka_content_width.dart';
import 'package:walka/design_system/components/navigation/walka_adaptive_shell_scaffold.dart';
import 'package:walka/design_system/walka_platform_adaptive.dart';
import 'package:walka/design_system/walka_shell.dart';

import 'support/walka_test_harness.dart';

void main() {
  List<Widget> pages() => List<Widget>.generate(
        WalkaShellDestination.values.length,
        (int index) => ColoredBox(
          key: ValueKey<String>('page-$index'),
          color: Colors.white,
        ),
      );

  test('ADAPT-001 preserves compact breakpoint below 360', () {
    expect(
      WalkaPlatformAdaptive.windowClassForWidth(320),
      WalkaWindowClass.compactMobile,
    );
    expect(WalkaPlatformAdaptive.horizontalGutterForWidth(320), 16);
  });

  test('ADAPT-002 preserves comfortable mobile behavior around 430', () {
    expect(
      WalkaPlatformAdaptive.windowClassForWidth(430),
      WalkaWindowClass.mobile,
    );
    expect(WalkaPlatformAdaptive.horizontalGutterForWidth(430), 20);
  });

  test('ADAPT-003 and ADAPT-004 expose tablet and desktop tiers', () {
    expect(
      WalkaPlatformAdaptive.windowClassForWidth(800),
      WalkaWindowClass.tablet,
    );
    expect(
      WalkaPlatformAdaptive.windowClassForWidth(1280),
      WalkaWindowClass.desktop,
    );
    expect(WalkaContentWidthMetrics.tabletBreakpoint, 720);
    expect(WalkaContentWidthMetrics.desktopBreakpoint, 1024);
  });

  testWidgets('ADAPT-005 removes phone-only shell cap for tablet/desktop',
      (WidgetTester tester) async {
    final WalkaShellController controller = WalkaShellController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      WalkaTestHarness(
        device: WalkaTestDevice.tablet,
        child: WalkaAdaptiveShellScaffold(
          controller: controller,
          pages: pages(),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('walka-adaptive-wide-shell')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('walka-adaptive-mobile-shell')),
      findsNothing,
    );
  });

  test('ADAPT-006 preserves desktop max-content and gutter tokens', () {
    expect(WalkaContentWidthMetrics.desktopMaxWidth, 1200);
    expect(
      WalkaContentWidthMetrics.gutterForTier(WalkaContentTier.desktop),
      32,
    );
  });

  testWidgets('ADAPT-007 provides reusable desktop top navigation chrome',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const WalkaTestHarness(
        device: WalkaTestDevice.desktop1280,
        child: Scaffold(
          body: Column(
            children: <Widget>[
              WalkaDesktopTopBar(
                navigation: <Widget>[TextButton(onPressed: null, child: Text('Shop'))],
                actions: <Widget>[Icon(Icons.search_rounded)],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(WalkaWordmark), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    final FocusTraversalGroup group = tester.widget<FocusTraversalGroup>(
      find.byType(FocusTraversalGroup),
    );
    expect(group.policy, isA<OrderedTraversalPolicy>());
  });

  testWidgets('ADAPT-008 keeps iOS notch and home-indicator safe area',
      (WidgetTester tester) async {
    EdgeInsets? insets;
    await tester.pumpWidget(
      WalkaTestHarness(
        device: WalkaTestDevice.iosPhone,
        child: Builder(
          builder: (BuildContext context) {
            insets = WalkaPlatformAdaptive.pageInsets(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(insets!.top, 47);
    expect(insets!.bottom, 34);
    expect(insets!.left, 20);
  });

  testWidgets('ADAPT-009 uses target-platform spacing without dart:io',
      (WidgetTester tester) async {
    EdgeInsets? androidInsets;
    await tester.pumpWidget(
      WalkaTestHarness(
        device: WalkaTestDevice.androidStandard,
        child: Builder(
          builder: (BuildContext context) {
            androidInsets = WalkaPlatformAdaptive.pageInsets(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(androidInsets!.top, 0);
    expect(androidInsets!.bottom, 0);

    EdgeInsets? iosInsets;
    const WalkaTestDevice iosWithoutReportedSafeArea = WalkaTestDevice(
      name: 'ios-no-reported-safe-area',
      size: Size(390, 844),
      platform: TargetPlatform.iOS,
    );
    await tester.pumpWidget(
      WalkaTestHarness(
        device: iosWithoutReportedSafeArea,
        child: Builder(
          builder: (BuildContext context) {
            iosInsets = WalkaPlatformAdaptive.pageInsets(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(iosInsets!.top, 8);
    expect(iosInsets!.bottom, 8);
  });

  testWidgets('ADAPT-010 exposes pointer hover and focus state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      WalkaTestHarness(
        device: WalkaTestDevice.desktop1280,
        child: WalkaInteractiveRegion(
          onActivate: () {},
          builder: (BuildContext context, WalkaInteractionState state) => Text(
            '${state.hovered}:${state.focused}',
          ),
        ),
      ),
    );

    expect(find.text('false:false'), findsOneWidget);
    final FocusableActionDetector detector = tester.widget<FocusableActionDetector>(
      find.byType(FocusableActionDetector),
    );
    detector.onShowHoverHighlight!(true);
    await tester.pump();
    expect(find.text('true:false'), findsOneWidget);

    final FocusableActionDetector focusedDetector =
        tester.widget<FocusableActionDetector>(find.byType(FocusableActionDetector));
    focusedDetector.onShowFocusHighlight!(true);
    await tester.pump();
    expect(find.text('true:true'), findsOneWidget);
  });

  testWidgets('ADAPT-011 provides keyboard activation and ordered traversal',
      (WidgetTester tester) async {
    var activations = 0;
    await tester.pumpWidget(
      WalkaTestHarness(
        device: WalkaTestDevice.desktop1280,
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: WalkaInteractiveRegion(
            autofocus: true,
            onActivate: () => activations += 1,
            builder: (BuildContext context, WalkaInteractionState state) =>
                const Text('Keyboard target'),
          ),
        ),
      ),
    );
    await tester.pump();

    final BuildContext actionContext = tester.element(
      find.byType(FocusableActionDetector),
    );
    Actions.invoke(actionContext, const ActivateIntent());
    expect(activations, 1);
  });

  testWidgets('ADAPT-012 shared harness applies 1.3x text scale',
      (WidgetTester tester) async {
    double? scaled;
    await tester.pumpWidget(
      WalkaTestHarness(
        device: WalkaTestDevice.androidStandard,
        textScale: 1.3,
        child: Builder(
          builder: (BuildContext context) {
            scaled = MediaQuery.textScalerOf(context).scale(10);
            return const Text('Scaled');
          },
        ),
      ),
    );

    expect(scaled, 13);
  });
}
