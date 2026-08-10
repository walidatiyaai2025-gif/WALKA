import 'package:flutter/material.dart';

import 'package:walka/design_system/components/layout/walka_responsive_grid.dart';
import 'package:walka/design_system/walka_theme.dart';

import 'walka_about_value_card.dart';

class WalkaAboutValues extends StatelessWidget {
  const WalkaAboutValues({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-about-values'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'WHAT GUIDES US',
            style: TextStyle(
              color: WalkaColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 16),
          WalkaResponsiveGrid(
            minItemWidth: 220,
            maxColumns: 3,
            gap: 12,
            runGap: 12,
            children: <Widget>[
              WalkaAboutValueCard(
                icon: Icons.tune_rounded,
                title: 'Purposeful',
                body: 'Useful details first, unnecessary complexity removed.',
              ),
              WalkaAboutValueCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Refined',
                body: 'Clean proportions and restrained visual language.',
              ),
              WalkaAboutValueCard(
                icon: Icons.repeat_rounded,
                title: 'Everyday',
                body: 'Designed to support routines again and again.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
