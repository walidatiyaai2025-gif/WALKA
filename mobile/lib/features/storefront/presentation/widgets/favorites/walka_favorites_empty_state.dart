import 'package:flutter/material.dart';

import '../../../../../design_system/components/feedback/walka_empty_state.dart';
import '../../../../../design_system/walka_theme.dart';

class WalkaFavoritesEmptyState extends StatelessWidget {
  const WalkaFavoritesEmptyState({
    required this.onExplore,
    super.key,
  });

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey<String>('reference-favorites-empty'),
      child: WalkaEmptyState(
        title: 'Save your favorites',
        body:
            'Save Drawer Organizer variants you love. They stay on this device for quick access anytime.',
        visual: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9ED),
            shape: BoxShape.circle,
            border: Border.all(
              color: WalkaColors.gold.withValues(alpha: 0.35),
            ),
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            size: 34,
            color: WalkaColors.navy,
          ),
        ),
        radius: 22,
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
        visualTitleSpacing: 18,
        titleBodySpacing: 9,
        bodyActionSpacing: 20,
        titleStyle: const TextStyle(
          color: WalkaColors.navy,
          fontFamily: 'serif',
          fontSize: 23,
          height: 1.1,
          fontWeight: FontWeight.w600,
        ),
        bodyStyle: const TextStyle(
          color: WalkaColors.muted,
          fontSize: 12,
          height: 1.5,
        ),
        actionKey: const ValueKey<String>('reference-favorites-explore'),
        actionLabel: 'CONTINUE SHOPPING',
        onAction: onExplore,
      ),
    );
  }
}
