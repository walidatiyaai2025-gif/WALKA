import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/accessibility/walka_accessibility.dart';
import 'package:walka/design_system/components/navigation/walka_adaptive_shell_scaffold.dart';
import 'package:walka/design_system/walka_motion.dart';
import 'package:walka/design_system/walka_shell.dart';

import 'support/walka_golden_harness.dart';
import 'support/walka_test_harness.dart';

void main() {
  List<Widget> pages() => List<Widget>.generate(
        WalkaShellDestination.values.length,
        (int index) => ColoredBox(
          key: ValueKey<String>('qa-page-$index'),
          color: Colors.white,
        ),
      );

  testWidgets('QA-001 golden harness fixes capture boundary and surface',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const WalkaGoldenHarness(
        device: WalkaTestDevice.androidStandard,
        child: Text('Golden candidate'),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('walka-golden-boundary')),
      findsOneWidget,
    );
    expect(find.text('Golden candidate'), findsOneWidget);
    expect(MediaQuery.sizeOf(tester.element(find.text('Golden candidate'))),
        WalkaTestDevice.androidStandard.size);
  });

  const List<(String, WalkaTestDevice, bool)> deviceCases =
      <(String, WalkaTestDevice, bool)>[
    ('QA-002 compact Android 320x568', WalkaTestDevice.androidCompact, false),
    ('QA-003 standard Android', WalkaTestDevice.androidStandard, false),
    ('QA-004 large Android', WalkaTestDevice.androidComfortable, false),
    ('QA-006 iOS safe-area phone', WalkaTestDevice.iosPhone, false),
    ('QA-007 desktop 1280', WalkaTestDevice.desktop1280, true),
    ('QA-008 desktop 1440', WalkaTestDevice.desktop1440, true),
  ];

  for (final (String, WalkaTestDevice, bool) deviceCase in deviceCases) {
    testWidgets('${deviceCase.$1} selects the correct shell without overflow',
        (WidgetTester tester) async {
      final WalkaShellController controller = WalkaShellController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        WalkaGoldenHarness(
          device: deviceCase.$2,
          child: WalkaAdaptiveShellScaffold(
            controller: controller,
            pages: pages(),
          ),
        ),
      );
      await tester.pump();

      final String expectedKey = deviceCase.$3
          ? 'walka-adaptive-wide-shell'
          : 'walka-adaptive-mobile-shell';
      expect(find.byKey(ValueKey<String>(expectedKey)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('QA-005 1.3x text scale is deterministic on compact Android',
      (WidgetTester tester) async {
    double? scaled;
    await tester.pumpWidget(
      WalkaGoldenHarness(
        device: WalkaTestDevice.androidCompact,
        textScale: 1.3,
        child: Builder(
          builder: (BuildContext context) {
            scaled = MediaQuery.textScalerOf(context).scale(10);
            return const Text('Scaled capture');
          },
        ),
      ),
    );

    expect(scaled, 13);
    expect(tester.takeException(), isNull);
  });

  testWidgets('QA-006 iOS harness carries notch and home-indicator insets',
      (WidgetTester tester) async {
    EdgeInsets? padding;
    TargetPlatform? platform;
    await tester.pumpWidget(
      WalkaGoldenHarness(
        device: WalkaTestDevice.iosPhone,
        child: Builder(
          builder: (BuildContext context) {
            padding = MediaQuery.paddingOf(context);
            platform = Theme.of(context).platform;
            return const Text('iOS safe area');
          },
        ),
      ),
    );

    expect(platform, TargetPlatform.iOS);
    expect(padding, const EdgeInsets.fromLTRB(0, 47, 0, 34));
  });

  testWidgets('QA-009 reduced-motion harness collapses WALKA motion to zero',
      (WidgetTester tester) async {
    Duration? duration;
    await tester.pumpWidget(
      WalkaGoldenHarness(
        device: WalkaTestDevice.androidStandard,
        disableAnimations: true,
        child: Builder(
          builder: (BuildContext context) {
            duration = WalkaMotion.duration(context, WalkaMotion.emphasis);
            return const Text('Reduced motion');
          },
        ),
      ),
    );

    expect(duration, Duration.zero);
  });

  testWidgets('QA-010 touch target and semantics contract stays >= 48px',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const WalkaGoldenHarness(
        device: WalkaTestDevice.androidCompact,
        child: Center(
          child: WalkaTouchTarget(
            semanticLabel: 'QA action',
            button: true,
            child: Icon(Icons.check_rounded, size: 16),
          ),
        ),
      ),
    );

    final Size size = tester.getSize(find.byType(WalkaTouchTarget));
    expect(size.width, greaterThanOrEqualTo(WalkaA11y.minimumTouchTarget));
    expect(size.height, greaterThanOrEqualTo(WalkaA11y.minimumTouchTarget));
    expect(find.bySemanticsLabel('QA action'), findsOneWidget);
  });
}
