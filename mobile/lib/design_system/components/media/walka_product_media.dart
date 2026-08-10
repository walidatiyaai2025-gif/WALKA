import 'package:flutter/material.dart';

import '../../walka_product_visual.dart';

/// Presentation interface used by feature widgets instead of depending on a
/// specific product-rendering implementation.
abstract interface class WalkaProductMedia {
  String get semanticLabel;

  Widget build(BuildContext context);
}

/// Adapter preserving the existing deterministic CustomPaint product visual.
class WalkaPaintedProductMedia implements WalkaProductMedia {
  const WalkaPaintedProductMedia({
    required this.kind,
    required this.primaryColor,
    required this.semanticLabel,
    this.backgroundColor = Colors.transparent,
    this.compact = false,
  });

  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color backgroundColor;
  final bool compact;

  @override
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return WalkaProductVisual(
      kind: kind,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      compact: compact,
      semanticLabel: semanticLabel,
    );
  }
}

/// Thin render boundary that lets later asset-backed media replace the painted
/// fallback without changing feature-page composition contracts.
class WalkaProductMediaView extends StatelessWidget {
  const WalkaProductMediaView({required this.media, super.key});

  final WalkaProductMedia media;

  @override
  Widget build(BuildContext context) => media.build(context);
}
