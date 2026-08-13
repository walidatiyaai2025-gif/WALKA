import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../content/content_state.dart';
import '../content/domain/walka_category_presentation_content.dart';
import '../lunch/lunch_box_v6.dart';
import 'presentation/widgets/discovery/walka_categories_benefits.dart';
import 'presentation/widgets/discovery/walka_category_card.dart';
import 'presentation/widgets/discovery/walka_discovery_header.dart';
import 'presentation/widgets/discovery/walka_discovery_meta.dart';
import 'presentation/widgets/discovery/walka_discovery_product_row.dart';
import 'storefront_catalog_v120.dart';

/// CMS-024 Categories surface. Product/category membership remains derived
/// from the catalog while copy, order and visibility come from typed content.
class WalkaCategoriesCmsV124 extends StatelessWidget {
  const WalkaCategoriesCmsV124({this.onSearch, super.key});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    final WalkaContentController? contentController =
        WalkaContentScope.maybeOf(context);
    final WalkaCategoryPresentationContent presentation =
        contentController?.categories.content ??
            WalkaCategoryPresentationContent.bundled;
    final List<WalkaCatalogViewItem> allItems = walkaCatalogViewItems(
      controller.snapshot,
    );
    final Map<String, String> categoryByProductId = <String, String>{
      for (final product in controller.snapshot.products)
        product.id: product.category,
    };

    List<WalkaCatalogViewItem> itemsForCategory(String categoryId) {
      return allItems
          .where(
            (WalkaCatalogViewItem item) =>
                categoryByProductId[item.productId] == categoryId,
          )
          .toList(growable: false);
    }

    final List<_ResolvedCategory> categories = presentation.visibleCategories
        .map(
          (WalkaCategoryPresentationItem category) => _resolveCategory(
            category,
            itemsForCategory(category.id),
          ),
        )
        .whereType<_ResolvedCategory>()
        .toList(growable: false);

    // A catalog/content mismatch cannot blank discovery. The typed parser
    // already validates IDs; this runtime fallback protects stale catalog
    // transitions and preserves a usable screen.
    final List<_ResolvedCategory> safeCategories = categories.isNotEmpty
        ? categories
        : WalkaCategoryPresentationContent.bundled.visibleCategories
            .map(
              (WalkaCategoryPresentationItem category) => _resolveCategory(
                category,
                itemsForCategory(category.id),
              ),
            )
            .whereType<_ResolvedCategory>()
            .toList(growable: false);

    final List<WalkaCatalogViewItem> visibleItems = safeCategories
        .expand((_ResolvedCategory category) => category.items)
        .toList(growable: false);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-cms-categories-scroll'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: WalkaDiscoveryHeader(
              trailingIcon: Icons.search_rounded,
              trailingTooltip: 'Search WALKA',
              onTrailing: onSearch,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 42),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                const Text(
                  'Categories',
                  key: ValueKey<String>('reference-categories-title'),
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 34,
                    height: 1.04,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore our premium organization solutions.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (controller.isLoading || controller.isOffline) ...<Widget>[
                  const SizedBox(height: 14),
                  WalkaDiscoveryCatalogStatus(controller: controller),
                ],
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    const double spacing = 12;
                    final int columns = constraints.maxWidth >= 700 ? 3 : 2;
                    final double width =
                        (constraints.maxWidth - spacing * (columns - 1)) / columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 12,
                      children: safeCategories
                          .map(
                            (_ResolvedCategory category) => SizedBox(
                              width: width,
                              child: WalkaCategoryCard(
                                key: ValueKey<String>(
                                  'reference-category-${category.content.id}',
                                ),
                                variantId: category.visualVariantId,
                                remoteSlotKey:
                                    'category:${category.content.id}',
                                title: category.content.displayName,
                                subtitle: category.content.description,
                                kind: category.kind,
                                primaryColor: category.primaryColor,
                                surface: category.surface,
                                badge: category.badge,
                                onTap: category.items.isEmpty
                                    ? null
                                    : () => openWalkaCatalogItem(
                                          context,
                                          category.items.first,
                                        ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('SHOP THE COLLECTION', style: WalkaType.eyebrow),
                          SizedBox(height: 6),
                          Text(
                            'Choose your WALKA piece',
                            style: WalkaType.sectionTitle,
                          ),
                        ],
                      ),
                    ),
                    WalkaDiscoveryCountBadge(count: visibleItems.length),
                  ],
                ),
                const SizedBox(height: 14),
                ...visibleItems.map(
                  (WalkaCatalogViewItem item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WalkaDiscoveryProductRow(
                      key: ValueKey<String>(
                        'reference-category-${item.variantId}',
                      ),
                      item: item,
                      onTap: () => openWalkaCatalogItem(context, item),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const WalkaCategoriesBenefits(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

_ResolvedCategory? _resolveCategory(
  WalkaCategoryPresentationItem content,
  List<WalkaCatalogViewItem> items,
) {
  if (items.isEmpty) return null;

  return switch (content.id) {
    'lunch' => _ResolvedCategory(
        content: content,
        items: items,
        visualVariantId: items.any(
          (WalkaCatalogViewItem item) => item.variantId == 'lunch-box:green',
        )
            ? 'lunch-box:green'
            : items.first.variantId,
        kind: WalkaProductVisualKind.lunchBox,
        primaryColor: WalkaLunchVariant.green.color,
        surface: const Color(0xFFEAF1E8),
        badge: '${items.length} colors',
      ),
    'drawer-organization' => _ResolvedCategory(
        content: content,
        items: items,
        visualVariantId: items.any(
          (WalkaCatalogViewItem item) =>
              item.variantId == 'drawer-organizer:white',
        )
            ? 'drawer-organizer:white'
            : items.first.variantId,
        kind: WalkaProductVisualKind.drawerOrganizer,
        primaryColor: const Color(0xFFF7F4EC),
        surface: const Color(0xFFF1E6CF),
        badge: '${items.length} finishes',
      ),
    _ => null,
  };
}

class _ResolvedCategory {
  const _ResolvedCategory({
    required this.content,
    required this.items,
    required this.visualVariantId,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    required this.badge,
  });

  final WalkaCategoryPresentationItem content;
  final List<WalkaCatalogViewItem> items;
  final String visualVariantId;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;
  final String badge;
}
