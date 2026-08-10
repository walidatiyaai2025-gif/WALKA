import 'package:flutter/material.dart';

import 'package:walka/design_system/components/chrome/walka_reference_top_bar.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaFavoritesTopBar extends StatelessWidget {
  const WalkaFavoritesTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaReferenceTopBar(
      headerKey: ValueKey<String>('reference-favorites-topbar'),
      trailingIcon: Icons.favorite_rounded,
      trailingColor: WalkaColors.gold,
    );
  }
}

class WalkaFavoritesHeader extends StatelessWidget {
  const WalkaFavoritesHeader({
    required this.count,
    required this.editMode,
    required this.onEdit,
    super.key,
  });

  final int count;
  final bool editMode;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'My Favorites',
                key: ValueKey<String>('reference-favorites-title'),
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 33,
                  height: 1.04,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$count ${count == 1 ? 'item' : 'items'} saved',
                key: const ValueKey<String>('reference-favorites-count'),
                style: const TextStyle(
                  color: WalkaColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          key: const ValueKey<String>('reference-favorites-edit'),
          onPressed: onEdit,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(70, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: Text(editMode ? 'DONE' : 'EDIT'),
        ),
      ],
    );
  }
}
