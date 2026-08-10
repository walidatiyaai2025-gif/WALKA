import 'package:flutter/material.dart';

import '../../walka_theme.dart';

enum WalkaContentTier { mobile, tablet, desktop }

abstract final class WalkaContentWidthMetrics {
  static const double tabletBreakpoint = 720;
  static const double desktopBreakpoint = 1024;
  static const double mobileMaxWidth = 560;
  static const double tabletMaxWidth = 840;
  static const double desktopMaxWidth = 1200;

  static WalkaContentTier tierForWidth(double width) {
    if (width >= desktopBreakpoint) return WalkaContentTier.desktop;
    if (width >= tabletBreakpoint) return WalkaContentTier.tablet;
    return WalkaContentTier.mobile;
  }

  static double maxWidthForTier(WalkaContentTier tier) => switch (tier) {
        WalkaContentTier.mobile => mobileMaxWidth,
        WalkaContentTier.tablet => tabletMaxWidth,
        WalkaContentTier.desktop => desktopMaxWidth,
      };

  static double gutterForTier(WalkaContentTier tier) => switch (tier) {
        WalkaContentTier.mobile => WalkaSpacing.md,
        WalkaContentTier.tablet => WalkaSpacing.lg,
        WalkaContentTier.desktop => WalkaSpacing.xl,
      };
}

/// Shared width/gutter policy. Existing mobile frames are intentionally not
/// replaced by this primitive until the dedicated adaptive tasks integrate it.
class WalkaContentWidth extends StatelessWidget {
  const WalkaContentWidth({
    required this.child,
    super.key,
    this.alignment = Alignment.topCenter,
    this.backgroundColor,
    this.includeGutter = true,
  });

  final Widget child;
  final AlignmentGeometry alignment;
  final Color? backgroundColor;
  final bool includeGutter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final WalkaContentTier tier = WalkaContentWidthMetrics.tierForWidth(available);
        final double gutter = includeGutter
            ? WalkaContentWidthMetrics.gutterForTier(tier)
            : 0;
        final double maxWidth = WalkaContentWidthMetrics.maxWidthForTier(tier);

        Widget result = Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: child,
            ),
          ),
        );

        if (backgroundColor != null) {
          result = ColoredBox(color: backgroundColor!, child: result);
        }
        return result;
      },
    );
  }
}
