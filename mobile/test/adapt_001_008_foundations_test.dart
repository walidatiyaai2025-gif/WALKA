import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/layout/walka_content_width.dart';
import 'package:walka/design_system/walka_adaptive.dart';
import 'package:walka/design_system/walka_shell.dart';

import 'support/walka_device_harness.dart';

void main() {
  test('phone, tablet and desktop tiers keep one breakpoint contract', () {
    expect(WalkaAdaptiveMetrics.isCompactWidth(320), isTrue);
    expect(WalkaAdaptiveMetrics.horizontalPaddingForWidth(320), 16);
    expect(WalkaAdaptiveMetrics.horizontalPaddingForWidth(390), 20);
    expect(WalkaAdaptiveMetrics.horizontalPaddingForWidth(430), 20);
    expect(WalkaAdaptiveMetrics.horizontalPaddingForWidth(431), 24);

    expect(
      WalkaAdaptiveMetrics.tierForWidth(719),
      WalkaContentTier.mobile,
    );
    expect(
      WalkaAdaptiveMetrics.tierForWidth(720),
      WalkaContentTier.tablet,
    );
    expect(
      WalkaAdaptiveMetrics.tierForWidth(1024),
      WalkaContentTier.desktop,
    );
    expect(WalkaAdaptiveMetrics.maxContentWidthForWidth(719), 560);
    expect(WalkaAdaptiveMetrics.maxContentWidthForWidth(720), 840);
    expect(WalkaAdaptiveMetrics.maxContentWidthForWidth(1440), 1200);
    expect(WalkaAdaptiveMetrics.gutterForWidth(1440), 32);
  });

  testWidgets('mobile frame preserves 560 cap before tablet breakpoint',
      (WidgetTester tester) async {
    const WalkaTestDevice device = WalkaTestDevice(size: Size(600, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: walkaDeviceHarness(
          device: device,
          child: const WalkaAdaptiveFrame(
            child: ColoredBox(
              key: ValueKey<String>('adaptive-content'),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey<String>('adaptive-content'))).width,
      560,
    );
  });

  testWidgets('tablet and desktop frame are no longer squeezed to 560',
      (WidgetTester tester) async {
    Future<double> renderWidth(WalkaTestDevice device) async {
      await tester.pumpWidget(
        MaterialApp(
          home: walkaDeviceHarness(
            device: device,
            child: const WalkaAdaptiveFrame(
              child: ColoredBox(
                key: ValueKey<String>('adaptive-content'),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
      return tester
          .getSize(find.byKey(const ValueKey<String>('adaptive-content')))
          .width;
    }

    expect(await renderWidth(WalkaTestDevice.tablet), 820);
    expect(await renderWidth(WalkaTestDevice.desktop), 1200);
  });

  testWidgets('wide shell exposes desktop header and typed destinations',
      (WidgetTester tester) async {
    final WalkaShellController controller = WalkaShellController();
    final List<Widget> pages = WalkaShellDestination.values
        .map(
          (WalkaShellDestination destination) => Center(
            child: Text('page-${destination.name}'),
          ),
        )
        .toList(growable: false);

    await tester.pumpWidget(
      MaterialApp(
        home: walkaDeviceHarness(
          device: WalkaTestDevice.desktop,
          child: WalkaWideShellScaffold(
            controller: controller,
            pages: pages,
          ),
        ),
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('WALKA'), findsOneWidget);
    expect(find.text('PREMIUM HOME ORGANIZATION'), findsOneWidget);
    expect(find.text('page-home'), findsOneWidget);

    controller.select(WalkaShellDestination.account);
    await tester.pump();
    expect(find.text('page-account'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('iOS harness preserves notch and home-indicator safe areas',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: walkaDeviceHarness(
          device: WalkaTestDevice.iPhoneNotch,
          child: const WalkaSafeAreaChrome(
            child: ColoredBox(
              key: ValueKey<String>('safe-content'),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    final Finder safeContent =
        find.byKey(const ValueKey<String>('safe-content'));
    expect(tester.getTopLeft(safeContent).dy, 47);
    expect(tester.getBottomRight(safeContent).dy, 852 - 34);
    expect(tester.takeException(), isNull);
  });
}
