import 'package:flutter/material.dart';

import 'package:walka/design_system/components/layout/walka_responsive_grid.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/content/domain/walka_information_content.dart';

import 'walka_about_value_card.dart';

class WalkaAboutValues extends StatelessWidget {
  const WalkaAboutValues({
    this.eyebrow = 'WHAT GUIDES US',
    this.items,
    super.key,
  });

  final String eyebrow;
  final List<WalkaInformationCopyItem>? items;

  @override
  Widget build(BuildContext context) {
    final List<WalkaInformationCopyItem> resolved = items ??
        WalkaInformationContent.bundled.about.values;
    final List<IconData> icons = <IconData>[
      Icons.tune_rounded,
      Icons.auto_awesome_outlined,
      Icons.repeat_rounded,
    ];

    return Container(
      key: const ValueKey<String>('reference-about-values'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            eyebrow,
            style: const TextStyle(
              color: WalkaColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          WalkaResponsiveGrid(
            minItemWidth: 220,
            maxColumns: 3,
            gap: 12,
            runGap: 12,
            children: List<Widget>.generate(
              resolved.length,
              (int index) => WalkaAboutValueCard(
                icon: icons[index],
                title: resolved[index].title,
                body: resolved[index].body,
              ),
              growable: false,
            ),
          ),
        ],
      ),
    );
  }
}
