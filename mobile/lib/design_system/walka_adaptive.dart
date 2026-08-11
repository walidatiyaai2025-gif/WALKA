import 'package:flutter/material.dart';

import 'walka_theme.dart';

abstract final class WalkaAdaptiveMetrics {
  static const double compactWidth = 360;
  static const double comfortableWidth = 430;
  static const double mobileContentMaxWidth = 560;

  static double horizontalPadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < compactWidth) {
      return 16;
    }
    if (width > comfortableWidth) {
      return 24;
    }
    return 20;
  }
}

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
    final bool wide = width > WalkaAdaptiveMetrics.mobileContentMaxWidth;

    return ColoredBox(
      color: wide ? WalkaColors.surface : backgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: WalkaAdaptiveMetrics.mobileContentMaxWidth,
          ),
          child: ColoredBox(
            color: backgroundColor,
            child: SizedBox.expand(child: child),
          ),
        ),
      ),
    );
  }
}

class WalkaAdaptiveNavigationFrame extends StatelessWidget {
  const WalkaAdaptiveNavigationFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WalkaColors.surface,
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
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
