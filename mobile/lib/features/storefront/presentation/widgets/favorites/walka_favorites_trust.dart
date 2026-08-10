import 'package:flutter/material.dart';

import '../../../../../design_system/components/cards/walka_trust_strip.dart';
import '../../../../../design_system/walka_theme.dart';

class WalkaFavoritesTrust extends StatelessWidget {
  const WalkaFavoritesTrust({super.key});

  static const List<(IconData, String)> _items = <(IconData, String)>[
    (Icons.phone_android_rounded, 'Saved locally'),
    (Icons.verified_outlined, 'Verified details'),
    (Icons.open_in_new_rounded, 'Official Amazon'),
    (Icons.workspace_premium_outlined, 'WALKA quality'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-favorites-trust'),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: WalkaTrustStrip(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        spacing: 4,
        runSpacing: 14,
        radius: 20,
        semanticLabel: 'Favorites trust information',
        children: _items
            .map(
              ((IconData, String) item) => _FavoriteTrustItem(
                icon: item.$1,
                label: item.$2,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _FavoriteTrustItem extends StatelessWidget {
  const _FavoriteTrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: WalkaColors.gold, size: 21),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
