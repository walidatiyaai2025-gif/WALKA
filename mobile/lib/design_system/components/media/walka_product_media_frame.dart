import 'package:flutter/material.dart';

import '../../walka_theme.dart';

/// Stable WALKA media viewport with shared aspect ratio, clipping and semantics.
class WalkaProductMediaFrame extends StatelessWidget {
  const WalkaProductMediaFrame({
    required this.semanticLabel,
    super.key,
    this.child,
    this.fallback,
    this.onTap,
    this.aspectRatio = 4 / 3,
    this.backgroundColor = WalkaColors.surface,
    this.radius = WalkaRadius.md,
    this.padding = EdgeInsets.zero,
  }) : assert(aspectRatio > 0);

  final String semanticLabel;
  final Widget? child;
  final Widget? fallback;
  final VoidCallback? onTap;
  final double aspectRatio;
  final Color backgroundColor;
  final double radius;
  final EdgeInsetsGeometry padding;

  Widget get _content => child ??
      fallback ??
      const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: WalkaColors.muted,
          size: 32,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    final Widget surface = Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: SizedBox.expand(child: _content),
        ),
      ),
    );

    return Semantics(
      container: true,
      image: true,
      button: onTap != null,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: surface,
        ),
      ),
    );
  }
}
