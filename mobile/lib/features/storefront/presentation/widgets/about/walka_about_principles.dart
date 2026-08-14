import 'package:flutter/material.dart';

import 'package:walka/design_system/components/cards/walka_surface_card.dart';
import 'package:walka/design_system/components/layout/walka_responsive_grid.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/content/domain/walka_information_content.dart';

class WalkaAboutPrinciples extends StatelessWidget {
  const WalkaAboutPrinciples({
    this.eyebrow = 'HOW WE DESIGN',
    this.title = 'Simple choices, made deliberately.',
    this.items,
    super.key,
  });

  final String eyebrow;
  final String title;
  final List<WalkaInformationCopyItem>? items;

  @override
  Widget build(BuildContext context) {
    final List<WalkaInformationCopyItem> resolved = items ??
        WalkaInformationContent.bundled.about.principles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 9),
        Text(title, style: WalkaType.sectionTitle),
        const SizedBox(height: 16),
        WalkaResponsiveGrid(
          minItemWidth: 250,
          maxColumns: 3,
          gap: 10,
          runGap: 10,
          children: List<Widget>.generate(
            resolved.length,
            (int index) => WalkaAboutPrincipleCard(
              number: (index + 1).toString().padLeft(2, '0'),
              title: resolved[index].title,
              body: resolved[index].body,
            ),
            growable: false,
          ),
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
