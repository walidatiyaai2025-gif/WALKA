import 'package:flutter/material.dart';

import 'components/layout/walka_content_width.dart';
import 'walka_theme.dart';

abstract final class WalkaAdaptiveMetrics {
  /// Existing compact-phone contract. Widths below this stay on the 16px gutter.
  static const double compactWidth = 360;

  /// Existing comfortable/large-phone contract. Widths above this use 24px.
  static const double comfortableWidth = 430;

  /// Compatibility alias for callers that still refer to the mobile frame cap.
  static const double mobileContentMaxWidth =
      WalkaContentWidthMetrics.mobileMaxWidth;

  /// Shared adaptive tier boundaries. These delegate to the design-system
  /// content-width contract instead of creating a second breakpoint system.
  static const double tabletWidth = WalkaContentWidthMetrics.tabletBreakpoint;
  static const double desktopWidth = WalkaContentWidthMetrics.desktopBreakpoint;
  static const double tabletContentMaxWidth =
      WalkaContentWidthMetrics.tabletMaxWidth;
  static const double desktopContentMaxWidth =
      WalkaContentWidthMetrics.desktopMaxWidth;

  static WalkaContentTier tierForWidth(double width) =>
      WalkaContentWidthMetrics.tierForWidth(width);

  static bool isCompactWidth(double width) => width < compactWidth;

  static bool isDesktopWidth(double width) =>
      tierForWidth(width) == WalkaContentTier.desktop;

  static double maxContentWidthForWidth(double width) =>
      WalkaContentWidthMetrics.maxWidthForTier(tierForWidth(width));

  static double gutterForWidth(double width) =>
      WalkaContentWidthMetrics.gutterForTier(tierForWidth(width));

  static double horizontalPaddingForWidth(double width) {
    if (width < compactWidth) return 16;
    if (width > comfortableWidth && width < tabletWidth) return 24;
    if (width >= tabletWidth) return gutterForWidth(width);
    return 20;
  }

  static double horizontalPadding(BuildContext context) =>
      horizontalPaddingForWidth(MediaQuery.sizeOf(context).width);
}

/// Adaptive primary-content frame.
///
/// Phone rendering remains capped at 560px. Tablet/desktop widths opt into the
/// shared 840/1200px content tiers so wide layouts are no longer silently
/// squeezed into a phone canvas.
class WalkaAdaptiveFrame extends StatelessWidget {
  const WalkaAdaptiveFrame({
    required this.child,
    super.key,
    this.backgroundColor = WalkaColors.ivory,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final WalkaContentTier tier = WalkaAdaptiveMetrics.tierForWidth(width);
    final bool wide = tier != WalkaContentTier.mobile;
    final double maxWidth = WalkaAdaptiveMetrics.maxContentWidthForWidth(width);

    return ColoredBox(
      color: wide ? WalkaColors.surface : backgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ColoredBox(
            color: backgroundColor,
            child: SizedBox.expand(child: child),
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation remains a phone-only chrome primitive. Wide layouts use
/// [WalkaWideShellScaffold], so this compatibility frame deliberately keeps the
/// established 560px cap.
class WalkaAdaptiveNavigationFrame extends StatelessWidget {
  const WalkaAdaptiveNavigationFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WalkaColors.surface,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: WalkaAdaptiveMetrics.mobileContentMaxWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}
