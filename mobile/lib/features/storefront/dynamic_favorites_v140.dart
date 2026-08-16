import 'package:flutter/material.dart';

import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../favorites/favorites_state.dart';
import 'dynamic_catalog_v140.dart';

class WalkaDynamicFavoritesV140 extends StatelessWidget {
  const WalkaDynamicFavoritesV140({required this.onExplore, super.key});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final List<_FavoriteVariant> items = <_FavoriteVariant>[];

    for (final WalkaCatalogProduct product in catalog.products) {
      for (final WalkaCatalogVariant variant in product.variants) {
        if (favorites.isFavorite(variant.id)) {
          items.add(_FavoriteVariant(product: product, variant: variant));
        }
      }
    }

    final double gutter = WalkaShellMetrics.horizontalGutter(context);
    return ListView(
      key: const PageStorageKey<String>('walka-dynamic-favorites'),
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 42),
      children: <Widget>[
        const Text('Favorites', style: WalkaType.sectionTitle),
        const SizedBox(height: 8),
        const Text('Saved variants are resolved against the current Dashboard catalog.', style: WalkaType.body),
        const SizedBox(height: 22),
        if (items.isEmpty) ...<Widget>[
          const SizedBox(height: 44),
          const Icon(Icons.favorite_border_rounded, size: 48, color: WalkaColors.muted),
          const SizedBox(height: 14),
          const Text('No current catalog favorites', textAlign: TextAlign.center, style: TextStyle(color: WalkaColors.navy, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('If a product or color is removed from the Dashboard it will not be resurrected here.', textAlign: TextAlign.center, style: WalkaType.body),
          const SizedBox(height: 18),
          FilledButton(onPressed: onExplore, child: const Text('Explore products')),
        ] else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  onTap: () => openWalkaDynamicProduct(context, item.product.id),
                  leading: CircleAvatar(backgroundColor: _swatch(item.variant.swatchHex)),
                  title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(item.variant.color),
                  trailing: IconButton(
                    tooltip: 'Remove favorite',
                    onPressed: () => favorites.remove(item.variant.id),
                    icon: const Icon(Icons.favorite_rounded, color: WalkaColors.navy),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FavoriteVariant {
  const _FavoriteVariant({required this.product, required this.variant});
  final WalkaCatalogProduct product;
  final WalkaCatalogVariant variant;
}

Color _swatch(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) return WalkaColors.surface;
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}
