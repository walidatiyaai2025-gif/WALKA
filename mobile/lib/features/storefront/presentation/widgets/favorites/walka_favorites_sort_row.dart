import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaFavoritesSortRow extends StatelessWidget {
  const WalkaFavoritesSortRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-favorites-sort'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: WalkaColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: <Widget>[
          Text(
            'Sort by:',
            style: TextStyle(
              color: WalkaColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saved variants',
              style: TextStyle(
                color: WalkaColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Icon(Icons.view_module_outlined, color: WalkaColors.gold, size: 20),
        ],
      ),
    );
  }
}
