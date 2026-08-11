import 'package:flutter/material.dart';

import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';

class WalkaAboutProductStory extends StatelessWidget {
  const WalkaAboutProductStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 196,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: WalkaResolvedProductMedia(
                variantId: 'drawer-organizer:white',
                kind: WalkaProductVisualKind.drawerOrganizer,
                primaryColor: Color(0xFFF7F4EC),
                backgroundColor: Color(0xFFF2E7D5),
                compact: true,
                mediaSurface: WalkaProductMediaSurface.about,
                semanticLabel: 'WALKA Drawer Organizer story visual',
              ),
            ),
            SizedBox(width: 6),
            Expanded(
              child: WalkaResolvedProductMedia(
                variantId: 'lunch-box:blue',
                kind: WalkaProductVisualKind.lunchBox,
                primaryColor: Color(0xFF7D95AF),
                backgroundColor: Color(0xFFE6EDF4),
                compact: true,
                mediaSurface: WalkaProductMediaSurface.about,
                semanticLabel: 'WALKA Lunch Box story visual',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
