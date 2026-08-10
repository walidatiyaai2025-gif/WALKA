import 'package:flutter/material.dart';

import '../../walka_theme.dart';
import 'walka_splash_brand_mark.dart';

/// Reusable WALKA splash composition. Navigation remains caller-owned.
class WalkaSplashContent extends StatelessWidget {
  const WalkaSplashContent({
    required this.compact,
    required this.onEnter,
    super.key,
  });

  final bool compact;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Spacer(),
        WalkaSplashBrandMark(compact: compact),
        SizedBox(height: compact ? 12 : 18),
        Container(width: 54, height: 2, color: WalkaColors.gold),
        SizedBox(height: compact ? 14 : 20),
        SizedBox(
          width: 325,
          child: Text(
            'Thoughtful pieces.\nBeautifully organized.',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: compact ? 32 : 39,
              height: 1.05,
              fontWeight: FontWeight.w600,
              letterSpacing: compact ? -0.45 : -0.7,
            ),
          ),
        ),
        SizedBox(height: compact ? 12 : 16),
        SizedBox(
          width: 320,
          child: Text(
            'The complete WALKA experience for discovery, product detail, favorites, support and official Amazon purchase handoff.',
            style: TextStyle(
              color: const Color(0xFFB6C5D4),
              height: compact ? 1.45 : 1.55,
              fontSize: compact ? 13 : 14,
            ),
          ),
        ),
        const Spacer(),
        SizedBox(height: compact ? 16 : 22),
        ElevatedButton(
          onPressed: onEnter,
          child: const Text('ENTER WALKA'),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'CONNECTED CATALOG · 1.2.0',
            style: TextStyle(
              color: Color(0xFF91A5B9),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
