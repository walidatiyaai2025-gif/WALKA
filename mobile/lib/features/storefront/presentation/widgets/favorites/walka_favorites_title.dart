import 'package:flutter/material.dart';

import '../../../../../design_system/walka_theme.dart';

class WalkaFavoritesTitle extends StatelessWidget {
  const WalkaFavoritesTitle({
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
