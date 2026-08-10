import 'package:flutter/material.dart';

import 'components/layout/walka_content_width.dart';
import 'walka_theme.dart';

enum WalkaWindowClass { compactMobile, mobile, tablet, desktop }

/// Cross-platform sizing policy built on the shared DS-020 content-width tiers.
///
/// This deliberately uses Flutter's target platform rather than `dart:io` so
/// widget tests, web and desktop builds all share the same deterministic policy.
abstract final class WalkaPlatformAdaptive {
  static const double compactBreakpoint = 360;
  static const double comfortableMobileBreakpoint = 430;

  static WalkaWindowClass windowClassForWidth(double width) {
    if (width >= WalkaContentWidthMetrics.desktopBreakpoint) {
      return WalkaWindowClass.desktop;
    }
    if (width >= WalkaContentWidthMetrics.tabletBreakpoint) {
      return WalkaWindowClass.tablet;
    }
    if (width < compactBreakpoint) return WalkaWindowClass.compactMobile;
    return WalkaWindowClass.mobile;
  }

  static WalkaWindowClass windowClassOf(BuildContext context) =>
      windowClassForWidth(MediaQuery.sizeOf(context).width);

  static bool isIOS(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;

  static bool isDesktopClass(BuildContext context) =>
      windowClassOf(context) == WalkaWindowClass.desktop;

  static double horizontalGutterForWidth(double width) {
    final WalkaContentTier tier = WalkaContentWidthMetrics.tierForWidth(width);
    if (tier == WalkaContentTier.mobile) {
      if (width < compactBreakpoint) return WalkaSpacing.md;
      if (width <= comfortableMobileBreakpoint) return 20;
    }
    return WalkaContentWidthMetrics.gutterForTier(tier);
  }

  /// Safe-area-aware page insets. iOS keeps a small breathing floor around
  /// notch/home-indicator areas while Android/desktop use the reported inset.
  static EdgeInsets pageInsets(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    final double horizontal = horizontalGutterForWidth(size.width);
    final bool ios = isIOS(context);
    final double top = ios && safe.top < WalkaSpacing.sm
        ? WalkaSpacing.sm
        : safe.top;
    final double bottom = ios && safe.bottom < WalkaSpacing.sm
        ? WalkaSpacing.sm
        : safe.bottom;
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }
}
