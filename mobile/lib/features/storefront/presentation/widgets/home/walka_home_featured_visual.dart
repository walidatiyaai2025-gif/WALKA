import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';

class WalkaHomeFeaturedVisualSpec {
  const WalkaHomeFeaturedVisualSpec({
    required this.variantId,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.primaryColor,
    required this.backgroundColor,
  });

  final String variantId;
  final String title;
  final String subtitle;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color backgroundColor;
}

WalkaHomeFeaturedVisualSpec walkaHomeFeaturedVisualFor(String variantId) {
  return switch (variantId) {
    'lunch-box:blue' => _lunchSpec(variantId, WalkaLunchVariant.blue),
    'lunch-box:pink' => _lunchSpec(variantId, WalkaLunchVariant.pink),
    'lunch-box:green' => _lunchSpec(variantId, WalkaLunchVariant.green),
    'drawer-organizer:white' => const WalkaHomeFeaturedVisualSpec(
        variantId: 'drawer-organizer:white',
        title: 'Drawer Organizers',
        subtitle: '8 compartments · expands from 13 to 22.4 in.',
        kind: WalkaProductVisualKind.drawerOrganizer,
        primaryColor: Color(0xFFF7F4EC),
        backgroundColor: Color(0xFFF0E2C7),
      ),
    'drawer-organizer:gray' => const WalkaHomeFeaturedVisualSpec(
        variantId: 'drawer-organizer:gray',
        title: 'Drawer Organizers',
        subtitle: '8 compartments · expands from 13 to 22.4 in.',
        kind: WalkaProductVisualKind.drawerOrganizer,
        primaryColor: Color(0xFFD5D7DA),
        backgroundColor: Color(0xFFE6E8EA),
      ),
    _ => throw FormatException('Unsupported WALKA featured variant: $variantId'),
  };
}

WalkaHomeFeaturedVisualSpec _lunchSpec(
  String variantId,
  WalkaLunchVariant variant,
) {
  return WalkaHomeFeaturedVisualSpec(
    variantId: variantId,
    title: 'Stainless Steel\nLunch Boxes',
    subtitle: '1200 ml · SUS304 tray · 4 compartments.',
    kind: WalkaProductVisualKind.lunchBox,
    primaryColor: variant.color,
    backgroundColor: variant.surface,
  );
}
