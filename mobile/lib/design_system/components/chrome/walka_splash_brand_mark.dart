import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../walka_theme.dart';

/// Shared WALKA splash brand mark.
///
/// Preserves the released official SVG, subtle gold radial glow and accessible
/// image semantics while keeping feature-level splash composition out of this
/// design-system atom.
class WalkaSplashBrandMark extends StatelessWidget {
  const WalkaSplashBrandMark({
    required this.compact,
    super.key,
  });

  final bool compact;

  static const String semanticLabel = 'WALKA For You';
  static const String assetPath = 'assets/branding/walka_logo.svg';
  static const double compactWidth = 214;
  static const double standardWidth = 252;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.centerLeft,
              radius: 1.15,
              colors: <Color>[
                WalkaColors.gold.withValues(alpha: 0.12),
                WalkaColors.navy.withValues(alpha: 0),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SvgPicture.asset(
              assetPath,
              width: compact ? compactWidth : standardWidth,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
