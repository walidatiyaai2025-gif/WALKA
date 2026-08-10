import 'package:flutter/material.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaTestDevice {
  const WalkaTestDevice({
    required this.name,
    required this.size,
    this.platform = TargetPlatform.android,
    this.safePadding = EdgeInsets.zero,
  });

  final String name;
  final Size size;
  final TargetPlatform platform;
  final EdgeInsets safePadding;

  static const WalkaTestDevice androidCompact = WalkaTestDevice(
    name: 'android-compact-320x568',
    size: Size(320, 568),
  );

  static const WalkaTestDevice androidStandard = WalkaTestDevice(
    name: 'android-standard-390x844',
    size: Size(390, 844),
  );

  static const WalkaTestDevice androidComfortable = WalkaTestDevice(
    name: 'android-comfortable-430x932',
    size: Size(430, 932),
  );

  static const WalkaTestDevice iosPhone = WalkaTestDevice(
    name: 'ios-390x844',
    size: Size(390, 844),
    platform: TargetPlatform.iOS,
    safePadding: EdgeInsets.fromLTRB(0, 47, 0, 34),
  );

  static const WalkaTestDevice tablet = WalkaTestDevice(
    name: 'tablet-800x1100',
    size: Size(800, 1100),
  );

  static const WalkaTestDevice desktop1280 = WalkaTestDevice(
    name: 'desktop-1280x800',
    size: Size(1280, 800),
    platform: TargetPlatform.windows,
  );

  static const WalkaTestDevice desktop1440 = WalkaTestDevice(
    name: 'desktop-1440x900',
    size: Size(1440, 900),
    platform: TargetPlatform.windows,
  );
}

/// Deterministic widget-test surface used by adaptive and golden suites.
class WalkaTestHarness extends StatelessWidget {
  const WalkaTestHarness({
    required this.child,
    required this.device,
    super.key,
    this.textScale = 1,
    this.disableAnimations = false,
  });

  final Widget child;
  final WalkaTestDevice device;
  final double textScale;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = buildWalkaTheme().copyWith(platform: device.platform);
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(
          size: device.size,
          padding: device.safePadding,
          viewPadding: device.safePadding,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: device.size.width,
            height: device.size.height,
            child: child,
          ),
        ),
      ),
    );
  }
}
