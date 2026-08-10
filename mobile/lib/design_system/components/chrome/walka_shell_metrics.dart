import 'package:flutter/widgets.dart';

import '../../walka_adaptive.dart';

/// Shared geometry contract for WALKA shell chrome.
abstract final class WalkaShellMetrics {
  static const double navigationHeight = 72;
  static const double headerTop = 16;
  static const double headerBottom = 8;
  static const double sectionGap = 32;
  static const double compactSectionGap = 24;
  static const double minimumTouchTarget = 48;

  static double horizontalGutter(BuildContext context) {
    return WalkaAdaptiveMetrics.horizontalPadding(context);
  }

  static double verticalSectionGap(BuildContext context) {
    return MediaQuery.sizeOf(context).width < WalkaAdaptiveMetrics.compactWidth
        ? compactSectionGap
        : sectionGap;
  }
}
