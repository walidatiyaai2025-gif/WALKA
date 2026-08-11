import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';

import 'walka_home_collection_card.dart';

class WalkaHomeCollectionSection extends StatelessWidget {
  const WalkaHomeCollectionSection({
    required this.lunchSemanticLabel,
    required this.drawerSemanticLabel,
    required this.onLunch,
    required this.onDrawer,
    this.eyebrow = 'OUR COLLECTION',
    this.title = 'Everything in Its Place',
    super.key,
  });

  final String lunchSemanticLabel;
  final String drawerSemanticLabel;
  final VoidCallback onLunch;
  final VoidCallback onDrawer;
  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: WalkaColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontFamily: 'serif',
            fontSize: 27,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          key: const PageStorageKey<String>('home-reference-collection'),
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WalkaHomeCollectionCard(
                key: const ValueKey<String>('home-reference-lunch-card'),
                variantId: 'lunch-box:blue',
                title: 'Stainless Steel\nLunch Boxes',
                subtitle: '1200 ml · SUS304 tray · 4 compartments.',
                kind: WalkaProductVisualKind.lunchBox,
                primaryColor: WalkaLunchVariant.blue.color,
                visualBackground: const Color(0xFFEAF0F5),
                semanticLabel: lunchSemanticLabel,
                onTap: onLunch,
              ),
              const SizedBox(width: 12),
              WalkaHomeCollectionCard(
                key: const ValueKey<String>('home-reference-drawer-card'),
                variantId: 'drawer-organizer:white',
                title: 'Drawer Organizers',
                subtitle: '8 compartments · expands from 13 to 22.4 in.',
                kind: WalkaProductVisualKind.drawerOrganizer,
                primaryColor: const Color(0xFFF7F4EC),
                visualBackground: const Color(0xFFF0E2C7),
                semanticLabel: drawerSemanticLabel,
                onTap: onDrawer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
