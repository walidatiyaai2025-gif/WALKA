import 'package:flutter/material.dart';

import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';
import 'package:walka/features/storefront/storefront_catalog_v120.dart';

class WalkaDiscoveryProductRow extends StatelessWidget {
  const WalkaDiscoveryProductRow({
    required this.item,
    required this.onTap,
    super.key,
  });

  final WalkaCatalogViewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.tone,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: WalkaResolvedProductMedia(
                  variantId: item.variantId,
                  kind: walkaDiscoveryVisualKind(item),
                  primaryColor: walkaDiscoveryProductColor(item),
                  backgroundColor: item.tone,
                  compact: true,
                  semanticLabel: '${item.title} ${item.variant}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      walkaDiscoveryFamilyLabel(item),
                      style: const TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.55,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: walkaDiscoveryProductColor(item),
                            border: Border.all(
                              color: WalkaColors.navy.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.variant.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: WalkaColors.muted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: WalkaColors.gold,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

WalkaProductVisualKind walkaDiscoveryVisualKind(WalkaCatalogViewItem item) {
  return item.family == WalkaCatalogFamily.drawer
      ? WalkaProductVisualKind.drawerOrganizer
      : WalkaProductVisualKind.lunchBox;
}

Color walkaDiscoveryProductColor(WalkaCatalogViewItem item) {
  if (item.family == WalkaCatalogFamily.drawer) {
    return item.variant.toLowerCase() == 'gray'
        ? const Color(0xFF9FA5A8)
        : const Color(0xFFF7F4EC);
  }
  return switch (item.variant.toLowerCase()) {
    'pink' => WalkaLunchVariant.pink.color,
    'green' => WalkaLunchVariant.green.color,
    _ => WalkaLunchVariant.blue.color,
  };
}

String walkaDiscoveryFamilyLabel(WalkaCatalogViewItem item) {
  return item.family == WalkaCatalogFamily.drawer
      ? 'DRAWER ORGANIZER'
      : 'LUNCH BOX';
}
