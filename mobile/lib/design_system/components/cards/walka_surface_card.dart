import 'package:flutter/material.dart';

import '../../walka_theme.dart';

/// Shared premium WALKA surface for cards and grouped content.
///
/// The component owns the common surface, border, radius and clipping contract
/// while leaving feature-specific layout/content to callers. When [onTap] is
/// supplied it adds Material ink feedback and button semantics without changing
/// the visual geometry.
class WalkaSurfaceCard extends StatelessWidget {
  const WalkaSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(WalkaSpacing.md),
    this.onTap,
    this.semanticLabel,
    this.surfaceColor = WalkaColors.white,
    this.borderColor = WalkaColors.line,
    this.radius = WalkaRadius.md,
    this.elevation = 0,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color surfaceColor;
  final Color borderColor;
  final double radius;
  final double elevation;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final Widget content = Padding(padding: padding, child: child);

    final Widget surface = Material(
      color: surfaceColor,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: clipBehavior,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: content,
            ),
    );

    if (onTap == null && semanticLabel == null) {
      return surface;
    }

    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: surface,
    );
  }
}
