import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaCategoriesBenefits extends StatelessWidget {
  const WalkaCategoriesBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_Benefit> benefits = <_Benefit>[
      _Benefit(Icons.workspace_premium_outlined, 'Premium Quality'),
      _Benefit(Icons.inventory_2_outlined, 'Verified Catalog'),
      _Benefit(Icons.open_in_new_rounded, 'Official Amazon'),
      _Benefit(Icons.cleaning_services_outlined, 'Care Guidance'),
    ];
    return Container(
      key: const ValueKey<String>('reference-categories-benefits'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Wrap(
            spacing: 4,
            runSpacing: 14,
            children: benefits
                .map(
                  (_Benefit benefit) => SizedBox(
                    width: (constraints.maxWidth - 4) / 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(benefit.icon, color: WalkaColors.gold, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          benefit.label,
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

class _Benefit {
  const _Benefit(this.icon, this.label);

  final IconData icon;
  final String label;
}
