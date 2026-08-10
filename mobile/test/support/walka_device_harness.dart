import 'package:flutter/material.dart';

class WalkaTestDevice {
  const WalkaTestDevice({
    required this.size,
    this.padding = EdgeInsets.zero,
    this.textScale = 1,
  });

  final Size size;
  final EdgeInsets padding;
  final double textScale;

  static const WalkaTestDevice compactAndroid = WalkaTestDevice(
    size: Size(320, 568),
  );

  static const WalkaTestDevice standardAndroid = WalkaTestDevice(
    size: Size(390, 844),
  );

  static const WalkaTestDevice largeAndroid = WalkaTestDevice(
    size: Size(430, 932),
  );

  static const WalkaTestDevice iPhoneNotch = WalkaTestDevice(
    size: Size(393, 852),
    padding: EdgeInsets.fromLTRB(0, 47, 0, 34),
  );

  static const WalkaTestDevice tablet = WalkaTestDevice(
    size: Size(820, 1180),
  );

  static const WalkaTestDevice desktop = WalkaTestDevice(
    size: Size(1440, 960),
  );
}

Widget walkaDeviceHarness({
  required WalkaTestDevice device,
  required Widget child,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: device.size,
      padding: device.padding,
      viewPadding: device.padding,
      textScaler: TextScaler.linear(device.textScale),
    ),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: device.size.width,
        height: device.size.height,
        child: child,
      ),
    ),
  );
}
