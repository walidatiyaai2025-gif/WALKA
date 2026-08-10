import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Wrap(
            spacing: 4,
            runSpacing: 14,
            children: _items
                .map(
                  ((IconData, String) item) => SizedBox(
                    width: (constraints.maxWidth - 4) / 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(item.$1, color: WalkaColors.gold, size: 21),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
