import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../walka_theme.dart';

/// Owner-approved WALKA splash brand mark extracted from the storefront entry.
class WalkaSplashBrandMark extends StatelessWidget {
  const WalkaSplashBrandMark({required this.compact, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'WALKA For You',
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
              'assets/branding/walka_logo.svg',
              width: compact ? 214 : 252,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
