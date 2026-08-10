import 'package:flutter/material.dart';

import 'package:walka/design_system/components/cards/walka_metric_tile.dart';
import 'package:walka/design_system/components/cards/walka_surface_card.dart';
import 'package:walka/design_system/components/layout/walka_responsive_grid.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaAccountOverview extends StatelessWidget {
  const WalkaAccountOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Account Overview', style: WalkaType.sectionTitle),
        const SizedBox(height: 12),
        const WalkaSurfaceCard(
          key: ValueKey<String>('reference-account-overview'),
          radius: 18,
          padding: EdgeInsets.all(12),
          child: WalkaResponsiveGrid(
            minItemWidth: 132,
            maxColumns: 4,
            gap: 8,
            runGap: 12,
            children: <Widget>[
              WalkaMetricTile(
                value: 'Not required',
                label: 'Sign-in',
                semanticLabel: 'Sign-in. Not required.',
              ),
              WalkaMetricTile(
                value: '5 variants',
                label: 'Catalog',
                semanticLabel: 'Catalog. Five released variants.',
              ),
              WalkaMetricTile(
                value: 'On device',
                label: 'Favorites',
                semanticLabel: 'Favorites. Stored on this device.',
              ),
              WalkaMetricTile(
                value: 'Amazon',
                label: 'Purchase',
                semanticLabel: 'Purchase destination. Amazon.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
