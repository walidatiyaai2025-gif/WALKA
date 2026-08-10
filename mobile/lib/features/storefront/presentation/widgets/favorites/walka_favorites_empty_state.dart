import 'package:flutter/material.dart';

import 'package:walka/design_system/components/feedback/walka_empty_state.dart';

class WalkaFavoritesEmptyState extends StatelessWidget {
  const WalkaFavoritesEmptyState({required this.onExplore, super.key});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey<String>('reference-favorites-empty'),
      child: WalkaEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Save your favorites',
        body:
            'Save Drawer Organizer variants you love. They stay on this device for quick access anytime.',
        actionLabel: 'CONTINUE SHOPPING',
        onAction: onExplore,
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
      ),
    );
  }
}
