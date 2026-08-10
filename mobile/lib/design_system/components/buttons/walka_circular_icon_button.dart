import 'package:flutter/material.dart';

import '../../walka_theme.dart';

/// Shared 48x48 circular WALKA action button.
///
/// Use for compact icon-only actions that need consistent surface, border,
/// tooltip semantics and touch geometry across storefront screens.
class WalkaCircularIconButton extends StatelessWidget {
  const WalkaCircularIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.surfaceColor = WalkaColors.white,
    this.foregroundColor = WalkaColors.navy,
    this.borderColor = WalkaColors.line,
    this.iconSize = 22,
    super.key,
  });

  static const double extent = 48;

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color surfaceColor;
  final Color foregroundColor;
  final Color borderColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: extent,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: iconSize,
        style: IconButton.styleFrom(
          backgroundColor: surfaceColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: surfaceColor,
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.38),
          minimumSize: const Size.square(extent),
          maximumSize: const Size.square(extent),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: CircleBorder(side: BorderSide(color: borderColor)),
        ),
        icon: Icon(icon),
      ),
    );
  }
}
