import 'package:flutter/material.dart';

import 'package:walka/features/storefront/storefront_catalog_v120.dart';

import 'walka_discovery_product_row.dart';

class WalkaSearchResults extends StatelessWidget {
  const WalkaSearchResults({
    required this.results,
    required this.onOpen,
    super.key,
  });

  final List<WalkaCatalogViewItem> results;
  final ValueChanged<WalkaCatalogViewItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: results
          .map(
            (WalkaCatalogViewItem item) => Padding(
              key: ValueKey<String>('discovery-search-${item.variantId}'),
              padding: const EdgeInsets.only(bottom: 10),
              child: WalkaDiscoveryProductRow(
                item: item,
                onTap: () => onOpen(item),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
