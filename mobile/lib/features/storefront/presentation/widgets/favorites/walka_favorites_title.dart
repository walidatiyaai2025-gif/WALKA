import 'package:flutter/material.dart';

import '../../../../../design_system/walka_theme.dart';

class WalkaFavoritesTitle extends StatelessWidget {
  const WalkaFavoritesTitle({
    required this.count,
    super.key,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('SAVED FOR LATER', style: WalkaType.eyebrow),
              SizedBox(height: 5),
              Text(
                'Favorites',
                key: ValueKey<String>('reference-favorites-title'),
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 32,
                  height: 1.02,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.45,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$count SAVED',
          key: const ValueKey<String>('reference-favorites-count'),
          style: const TextStyle(
            color: WalkaColors.gold,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
