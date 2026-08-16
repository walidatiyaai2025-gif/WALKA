import 'package:flutter/material.dart';

import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../content/content_state.dart';
import '../content/domain/walka_mobile_content.dart';
import '../content/domain/walka_storefront_copy_content.dart';
import '../favorites/favorites_state.dart';
import '../media/presentation/walka_resolved_product_remote_media.dart';
import 'dynamic_catalog_v140.dart';

class WalkaDynamicFavoritesV140 extends StatelessWidget {
  const WalkaDynamicFavoritesV140({required this.onExplore, super.key});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final WalkaContentController? content = WalkaContentScope.maybeOf(context);
    final WalkaStorefrontCopyContent? copy = content != null &&
            (content.storefrontCopy.source == WalkaContentSource.remote ||
                content.storefrontCopy.source == WalkaContentSource.cache)
        ? content.storefrontCopy.content
        : null;
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
        if (copy != null) ...<Widget>[
          Text(copy.favoritesHeading, style: WalkaType.sectionTitle),
          const SizedBox(height: 8),
          Text(copy.favoritesBody, style: WalkaType.body),
          const SizedBox(height: 22),
        ],
        if (items.isEmpty) ...<Widget>[
          const SizedBox(height: 44),
          const Icon(
            Icons.favorite_border_rounded,
            size: 48,
            color: WalkaColors.muted,
          ),
          if (copy != null) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              copy.favoritesEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              copy.favoritesEmptyBody,
              textAlign: TextAlign.center,
              style: WalkaType.body,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onExplore,
              child: Text(copy.favoritesExploreLabel),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 16),
            Center(
              child: IconButton.filled(
                onPressed: onExplore,
                icon: const Icon(Icons.grid_view_rounded),
              ),
            ),
          ],
        ] else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  onTap: () => openWalkaDynamicProduct(context, item.product.id),
                  leading: SizedBox(
                    width: 64,
                    height: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: WalkaResolvedProductRemoteMedia(
                        variantId: item.variant.id,
                        semanticContext: 'favorites:${item.variant.id}',
                        fit: BoxFit.contain,
                        fallback: const ColoredBox(
                          color: WalkaColors.surface,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: WalkaColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(item.variant.color),
                  trailing: IconButton(
                    key: ValueKey<String>('favorite-remove-${item.variant.id}'),
                    tooltip: copy?.favoritesRemoveLabel,
                    onPressed: () => favorites.remove(item.variant.id),
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: WalkaColors.navy,
                    ),
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
