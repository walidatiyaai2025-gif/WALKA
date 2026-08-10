import 'package:flutter/material.dart';

import 'package:walka/design_system/components/cards/walka_surface_card.dart';
import 'package:walka/design_system/components/layout/walka_responsive_grid.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaAboutPrinciples extends StatelessWidget {
  const WalkaAboutPrinciples({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('HOW WE DESIGN', style: WalkaType.eyebrow),
        SizedBox(height: 9),
        Text('Simple choices, made deliberately.', style: WalkaType.sectionTitle),
        SizedBox(height: 16),
        WalkaResponsiveGrid(
          minItemWidth: 250,
          maxColumns: 3,
          gap: 10,
          runGap: 10,
          children: <Widget>[
            WalkaAboutPrincipleCard(
              number: '01',
              title: 'Useful first',
              body:
                  'Every WALKA product starts with the routine it needs to improve, then removes unnecessary complexity.',
            ),
            WalkaAboutPrincipleCard(
              number: '02',
              title: 'Calm by design',
              body:
                  'Clean proportions, restrained color and considered details help products sit naturally in the home.',
            ),
            WalkaAboutPrincipleCard(
              number: '03',
              title: 'Made for repetition',
              body:
                  'The best organization products quietly support everyday habits and remain easy to use again and again.',
            ),
          ],
        ),
      ],
    );
  }
}

class WalkaAboutPrincipleCard extends StatelessWidget {
  const WalkaAboutPrincipleCard({
    required this.number,
    required this.title,
    required this.body,
    super.key,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return WalkaSurfaceCard(
      radius: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            number,
            style: const TextStyle(
              color: WalkaColors.gold,
              fontFamily: 'serif',
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
