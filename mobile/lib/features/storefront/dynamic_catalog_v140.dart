import 'package:flutter/material.dart';

import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../commerce/amazon_purchase.dart';
import '../content/content_state.dart';
import '../content/domain/walka_category_presentation_content.dart';
import '../content/domain/walka_home_banner_content.dart';
import '../content/domain/walka_home_featured_content.dart';
import '../content/domain/walka_home_layout_content.dart';
import '../content/domain/walka_mobile_content.dart';
import '../content/domain/walka_pdp_layout_content.dart';
import '../content/domain/walka_search_presentation_content.dart';
import '../content/domain/walka_storefront_copy_content.dart';
import '../favorites/favorites_state.dart';
import '../media/presentation/walka_resolved_product_remote_media.dart';
import '../media/presentation/walka_resolved_surface_media.dart';

bool _isPublishedContent(WalkaContentSource source) =>
    source == WalkaContentSource.remote || source == WalkaContentSource.cache;

class WalkaDynamicHomeV140 extends StatelessWidget {
  const WalkaDynamicHomeV140({
    required this.onShopAll,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final WalkaContentController? content = WalkaContentScope.maybeOf(context);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    final WalkaHomeHeroContent? hero = content != null &&
            _isPublishedContent(content.home.source)
        ? content.home.content
        : null;
    final WalkaHomeLayoutContent? layout = content != null &&
            _isPublishedContent(content.homeLayout.source)
        ? content.homeLayout.content
        : null;
    final WalkaHomeFeaturedContent? featured = content != null &&
            _isPublishedContent(content.homeFeatured.source)
        ? content.homeFeatured.content
        : null;
    final WalkaHomeBannerContent? banner = content != null &&
            _isPublishedContent(content.homeBanner.source)
        ? content.homeBanner.content
        : null;

    final List<WalkaCatalogProduct> featuredProducts =
        _featuredProducts(catalog, featured);
    final List<WalkaHomeSectionId> sectionOrder = layout == null
        ? const <WalkaHomeSectionId>[]
        : layout.visibleSections
            .map((WalkaHomeSectionConfig section) => section.id)
            .toList(growable: false);

    return ListView(
      key: const PageStorageKey<String>('walka-dynamic-home'),
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 42),
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              catalog.config.brand,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.7,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onSearch,
              tooltip: content != null && _isPublishedContent(content.search.source)
                  ? content.search.content.heading
                  : null,
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
        if (banner != null && banner.isActiveAt(DateTime.now())) ...<Widget>[
          const SizedBox(height: 14),
          _DynamicBanner(
            banner: banner,
            onShopAll: onShopAll,
            onSearch: onSearch,
          ),
        ],
        const SizedBox(height: 10),
        for (final WalkaHomeSectionId section in sectionOrder)
          ..._homeSection(
            context: context,
            section: section,
            catalog: catalog,
            hero: hero,
            layout: layout,
            featuredProducts: featuredProducts,
            onShopAll: onShopAll,
            onSearch: onSearch,
          ),
        if (layout == null && content?.isLoading == true)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  List<Widget> _homeSection({
    required BuildContext context,
    required WalkaHomeSectionId section,
    required WalkaCatalogSnapshot catalog,
    required WalkaHomeHeroContent? hero,
    required WalkaHomeLayoutContent? layout,
    required List<WalkaCatalogProduct> featuredProducts,
    required VoidCallback onShopAll,
    required VoidCallback onSearch,
  }) {
    switch (section) {
      case WalkaHomeSectionId.hero:
        if (hero == null) return const <Widget>[];
        return <Widget>[
          const SizedBox(height: 12),
          WalkaResolvedSurfaceMedia(
            slotKey: 'home.hero',
            semanticContext: 'home.hero',
            fit: BoxFit.cover,
            fallback: const SizedBox.shrink(),
          ),
          Text(hero.eyebrow, style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          Text(hero.title, style: WalkaType.sectionTitle),
          const SizedBox(height: 8),
          Text(hero.body, style: WalkaType.body),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FilledButton(onPressed: onShopAll, child: Text(hero.shopLabel)),
              OutlinedButton(onPressed: onSearch, child: Text(hero.searchLabel)),
            ],
          ),
          const SizedBox(height: 22),
        ];
      case WalkaHomeSectionId.collection:
        final WalkaHomeSectionConfig? config =
            _sectionConfig(layout, WalkaHomeSectionId.collection);
        if (config == null) return const <Widget>[];
        return <Widget>[
          if (config.eyebrow case final String eyebrow)
            Text(eyebrow, style: WalkaType.eyebrow),
          if (config.title case final String title) ...<Widget>[
            const SizedBox(height: 7),
            Text(title, style: WalkaType.sectionTitle),
          ],
          const SizedBox(height: 14),
          ...featuredProducts.map(
            (WalkaCatalogProduct product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DynamicProductCard(
                product: product,
                categoryName: _categoryName(catalog, product.category),
                onTap: () => openWalkaDynamicProduct(context, product.id),
              ),
            ),
          ),
          if (hero != null) ...<Widget>[
            const SizedBox(height: 4),
            FilledButton.icon(
              onPressed: onShopAll,
              icon: const Icon(Icons.grid_view_rounded),
              label: Text(hero.shopLabel),
            ),
          ],
          const SizedBox(height: 22),
        ];
      case WalkaHomeSectionId.smallChanges:
        final WalkaHomeSectionConfig? config =
            _sectionConfig(layout, WalkaHomeSectionId.smallChanges);
        if (config == null) return const <Widget>[];
        return <Widget>[
          WalkaResolvedSurfaceMedia(
            slotKey: 'home.editorial.small_changes',
            semanticContext: 'home.editorial.small_changes',
            fit: BoxFit.cover,
            fallback: const SizedBox.shrink(),
          ),
          if (config.title case final String title)
            Text(title, style: WalkaType.sectionTitle),
          if (config.body case final String body) ...<Widget>[
            const SizedBox(height: 8),
            Text(body, style: WalkaType.body),
          ],
          const SizedBox(height: 22),
        ];
      case WalkaHomeSectionId.benefits:
      case WalkaHomeSectionId.trust:
        return const <Widget>[];
    }
  }
}

class WalkaDynamicCategoriesV140 extends StatelessWidget {
  const WalkaDynamicCategoriesV140({this.onSearch, super.key});
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final WalkaContentController? content = WalkaContentScope.maybeOf(context);
    final WalkaStorefrontCopyContent? copy = content != null &&
            _isPublishedContent(content.storefrontCopy.source)
        ? content.storefrontCopy.content
        : null;
    final WalkaCategoryPresentationContent? presentation = content != null &&
            _isPublishedContent(content.categories.source)
        ? content.categories.content
        : null;
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return ListView(
      key: const PageStorageKey<String>('walka-dynamic-categories'),
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 42),
      children: <Widget>[
        Row(
          children: <Widget>[
            if (copy != null)
              Expanded(child: Text(copy.categoriesHeading, style: WalkaType.sectionTitle))
            else
              const Spacer(),
            if (onSearch != null)
              IconButton(
                onPressed: onSearch,
                tooltip: content != null && _isPublishedContent(content.search.source)
                    ? content.search.content.heading
                    : null,
                icon: const Icon(Icons.search_rounded),
              ),
          ],
        ),
        if (copy != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(copy.categoriesBody, style: WalkaType.body),
        ],
        const SizedBox(height: 22),
        ...catalog.categories.map((WalkaCatalogCategory category) {
          final List<WalkaCatalogProduct> products = catalog.products
              .where((WalkaCatalogProduct product) => product.category == category.id)
              .toList(growable: false);
          if (products.isEmpty) return const SizedBox.shrink();
          final WalkaCategoryPresentationItem? overlay =
              presentation?.itemFor(category.id);
          if (overlay != null && !overlay.visible) return const SizedBox.shrink();
          final String displayName = overlay?.displayName ?? category.name;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                WalkaResolvedSurfaceMedia(
                  slotKey: 'category:${category.id}',
                  semanticContext: 'category:${category.id}',
                  fit: BoxFit.cover,
                  fallback: const SizedBox.shrink(),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${products.length}',
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (overlay != null) ...<Widget>[
                  const SizedBox(height: 5),
                  Text(overlay.description, style: WalkaType.body),
                ],
                const SizedBox(height: 10),
                ...products.map(
                  (WalkaCatalogProduct product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DynamicProductCard(
                      product: product,
                      categoryName: displayName,
                      onTap: () => openWalkaDynamicProduct(context, product.id),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class WalkaDynamicSearchV140 extends StatefulWidget {
  const WalkaDynamicSearchV140({super.key});

  @override
  State<WalkaDynamicSearchV140> createState() => _WalkaDynamicSearchV140State();
}

class _WalkaDynamicSearchV140State extends State<WalkaDynamicSearchV140> {
  String _query = '';
  String? _categoryId;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final WalkaContentController? content = WalkaContentScope.maybeOf(context);
    final WalkaSearchPresentationContent? presentation = content != null &&
            _isPublishedContent(content.search.source)
        ? content.search.content
        : null;
    final String query = _query.trim().toLowerCase();
    final List<WalkaCatalogProduct> candidates =
        _searchOrderedProducts(catalog, presentation);
    final List<WalkaCatalogProduct> results = candidates.where((product) {
      if (_categoryId != null && product.category != _categoryId) return false;
      if (query.isEmpty) return true;
      final String haystack = <String>[
        product.name,
        product.category,
        _categoryName(catalog, product.category),
        product.features.join(' '),
        product.facts.values.join(' '),
        ...product.variants.expand(
          (variant) => <String>[variant.color, variant.pantone ?? '', variant.asin],
        ),
      ].join(' ').toLowerCase();
      return query.split(RegExp(r'\s+')).every(haystack.contains);
    }).toList(growable: false);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return ListView(
      key: const PageStorageKey<String>('walka-dynamic-search'),
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 42),
      children: <Widget>[
        if (presentation != null) ...<Widget>[
          Text(presentation.heading, style: WalkaType.sectionTitle),
          const SizedBox(height: 6),
          Text(presentation.supportingCopy, style: WalkaType.body),
          const SizedBox(height: 14),
        ],
        TextField(
          onChanged: (String value) => setState(() => _query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: presentation?.placeholder,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              ChoiceChip(
                label: Text(
                  presentation?.filterLabel('all') ?? catalog.config.brand,
                ),
                selected: _categoryId == null,
                onSelected: (_) => setState(() => _categoryId = null),
              ),
              ...catalog.categories.map(
                (WalkaCatalogCategory category) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(
                      presentation?.filterLabel(category.id) ?? category.name,
                    ),
                    selected: _categoryId == category.id,
                    onSelected: (_) => setState(() => _categoryId = category.id),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '${results.length}',
          style: const TextStyle(
            color: WalkaColors.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: presentation == null
                  ? const Icon(Icons.search_off_rounded, color: WalkaColors.muted)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(presentation.emptyTitle, style: WalkaType.sectionTitle),
                        const SizedBox(height: 6),
                        Text(
                          presentation.emptyBody,
                          textAlign: TextAlign.center,
                          style: WalkaType.body,
                        ),
                      ],
                    ),
            ),
          )
        else
          ...results.map(
            (WalkaCatalogProduct product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DynamicProductCard(
                product: product,
                categoryName: _categoryName(catalog, product.category),
                onTap: () => openWalkaDynamicProduct(context, product.id),
              ),
            ),
          ),
      ],
    );
  }
}

void openWalkaDynamicProduct(BuildContext context, String productId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => WalkaDynamicProductDetailV140(productId: productId),
    ),
  );
}

class WalkaDynamicProductDetailV140 extends StatefulWidget {
  const WalkaDynamicProductDetailV140({required this.productId, super.key});
  final String productId;

  @override
  State<WalkaDynamicProductDetailV140> createState() =>
      _WalkaDynamicProductDetailV140State();
}

class _WalkaDynamicProductDetailV140State
    extends State<WalkaDynamicProductDetailV140> {
  String? _selectedVariantId;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final WalkaContentController? content = WalkaContentScope.maybeOf(context);
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final WalkaStorefrontCopyContent? copy = content != null &&
            _isPublishedContent(content.storefrontCopy.source)
        ? content.storefrontCopy.content
        : null;
    final WalkaPdpLayoutContent? layout = content != null &&
            _isPublishedContent(content.pdpLayout.source)
        ? content.pdpLayout.content
        : null;
    final WalkaCatalogProduct? product = catalog.productById(widget.productId);

    if (product == null || product.variants.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: copy == null
                ? const Icon(Icons.inventory_2_outlined, color: WalkaColors.muted)
                : Text(copy.pdpUnavailable),
          ),
        ),
      );
    }
    if (layout == null) {
      return Scaffold(
        backgroundColor: WalkaColors.ivory,
        appBar: AppBar(title: Text(product.name)),
        body: Center(
          child: content?.isLoading == true
              ? const CircularProgressIndicator()
              : const Icon(Icons.cloud_off_rounded, color: WalkaColors.muted),
        ),
      );
    }

    final WalkaCatalogVariant selected = product.variants.firstWhere(
      (WalkaCatalogVariant variant) => variant.id == _selectedVariantId,
      orElse: () => product.variants.first,
    );
    final bool isFavorite = favorites.isFavorite(selected.id);
    final Color tone = _swatchColor(selected.swatchHex);
    final List<Widget> sections = <Widget>[];
    for (final WalkaPdpSectionConfig section in layout.visibleSections) {
      sections.addAll(
        _pdpSection(
          section.id,
          context: context,
          catalog: catalog,
          product: product,
          selected: selected,
          isFavorite: isFavorite,
          favorites: favorites,
          copy: copy,
          tone: tone,
        ),
      );
    }

    return Scaffold(
      backgroundColor: WalkaColors.ivory,
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 42),
        children: <Widget>[
          ...sections,
          const SizedBox(height: 28),
          FilledButton.icon(
            key: ValueKey<String>('dynamic-amazon-${selected.id}'),
            onPressed: () => openAmazonPurchaseUri(selected.purchaseUri),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(copy?.pdpBuyLabel ?? selected.purchaseUri.host),
          ),
          const SizedBox(height: 8),
          Text(
            copy == null ? selected.asin : '${copy.pdpAsinLabel} ${selected.asin}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: WalkaColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  List<Widget> _pdpSection(
    WalkaPdpSectionId id, {
    required BuildContext context,
    required WalkaCatalogSnapshot catalog,
    required WalkaCatalogProduct product,
    required WalkaCatalogVariant selected,
    required bool isFavorite,
    required WalkaFavoritesController favorites,
    required WalkaStorefrontCopyContent? copy,
    required Color tone,
  }) {
    switch (id) {
      case WalkaPdpSectionId.gallery:
        return <Widget>[
          SizedBox(
            key: const ValueKey<String>('dynamic-pdp-section-gallery'),
            height: 220,
            child: WalkaResolvedProductRemoteMedia(
              variantId: selected.id,
              semanticContext: 'pdp:${selected.id}',
              fit: BoxFit.contain,
              fallback: Container(
                decoration: BoxDecoration(
                  color: tone,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: WalkaColors.line),
                ),
                alignment: Alignment.center,
                child: Text(
                  selected.color,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ];
      case WalkaPdpSectionId.identity:
        return <Widget>[
          KeyedSubtree(
            key: const ValueKey<String>('dynamic-pdp-section-identity'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_categoryName(catalog, product.category), style: WalkaType.eyebrow),
                const SizedBox(height: 7),
                Text(product.name, style: WalkaType.sectionTitle),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ];
      case WalkaPdpSectionId.variants:
        return <Widget>[
          KeyedSubtree(
            key: const ValueKey<String>('dynamic-pdp-section-variants'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (copy != null) ...<Widget>[
                  Text(
                    copy.pdpColorsLabel,
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.variants.map((WalkaCatalogVariant variant) {
                    return ChoiceChip(
                      selected: variant.id == selected.id,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _swatchColor(variant.swatchHex),
                              shape: BoxShape.circle,
                              border: Border.all(color: WalkaColors.line),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(variant.color),
                        ],
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedVariantId = variant.id),
                    );
                  }).toList(growable: false),
                ),
                if (selected.pantone != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(selected.pantone!, style: WalkaType.body),
                ],
                const SizedBox(height: 14),
                if (copy != null)
                  OutlinedButton.icon(
                    key: ValueKey<String>('dynamic-favorite-${selected.id}'),
                    onPressed: () => favorites.toggle(selected.id),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    label: Text(
                      isFavorite
                          ? copy.pdpFavoriteRemoveLabel
                          : copy.pdpFavoriteAddLabel,
                    ),
                  )
                else
                  Center(
                    child: IconButton.outlined(
                      key: ValueKey<String>('dynamic-favorite-${selected.id}'),
                      onPressed: () => favorites.toggle(selected.id),
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ];
      case WalkaPdpSectionId.usage:
        return const <Widget>[];
      case WalkaPdpSectionId.facts:
        if (product.facts.isEmpty) return const <Widget>[];
        return <Widget>[
          const SizedBox(height: 22),
          KeyedSubtree(
            key: const ValueKey<String>('dynamic-pdp-section-facts'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (copy != null) ...<Widget>[
                  Text(
                    copy.pdpDetailsLabel,
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                ...product.facts.entries.map(
                  (MapEntry<String, dynamic> entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: WalkaColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${entry.value}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: WalkaColors.navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
      case WalkaPdpSectionId.editorial:
        if (product.shortDescription == null && product.features.isEmpty) {
          return const <Widget>[];
        }
        return <Widget>[
          const SizedBox(height: 24),
          KeyedSubtree(
            key: const ValueKey<String>('dynamic-pdp-section-editorial'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (product.shortDescription != null) ...<Widget>[
                  Text(product.shortDescription!, style: WalkaType.body),
                  if (product.features.isNotEmpty) const SizedBox(height: 12),
                ],
                if (product.features.isNotEmpty) ...<Widget>[
                  if (copy != null) ...<Widget>[
                    Text(
                      copy.pdpFeaturesLabel,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...product.features.map(
                    (String feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 7),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: WalkaColors.gold,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(child: Text(feature, style: WalkaType.body)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ];
      case WalkaPdpSectionId.specifications:
      case WalkaPdpSectionId.amazonTrust:
        return const <Widget>[];
    }
  }
}

class _DynamicBanner extends StatelessWidget {
  const _DynamicBanner({
    required this.banner,
    required this.onShopAll,
    required this.onSearch,
  });

  final WalkaHomeBannerContent banner;
  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = switch (banner.ctaAction) {
      WalkaHomeBannerAction.none => null,
      WalkaHomeBannerAction.browse => onShopAll,
      WalkaHomeBannerAction.search => onSearch,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WalkaColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(banner.eyebrow, style: WalkaType.eyebrow),
          const SizedBox(height: 5),
          Text(banner.title, style: WalkaType.sectionTitle),
          const SizedBox(height: 5),
          Text(banner.body, style: WalkaType.body),
          if (action != null && banner.ctaLabel != null) ...<Widget>[
            const SizedBox(height: 10),
            TextButton(onPressed: action, child: Text(banner.ctaLabel!)),
          ],
        ],
      ),
    );
  }
}

class _DynamicProductCard extends StatelessWidget {
  const _DynamicProductCard({
    required this.product,
    required this.categoryName,
    required this.onTap,
  });

  final WalkaCatalogProduct product;
  final String categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<WalkaCatalogVariant> variants = product.variants;
    final WalkaCatalogVariant? first = variants.isEmpty ? null : variants.first;
    final Color tone = _swatchColor(first?.swatchHex);
    return Material(
      color: WalkaColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 66,
                height: 66,
                child: first == null
                    ? const SizedBox.shrink()
                    : WalkaResolvedProductRemoteMedia(
                        variantId: first.id,
                        semanticContext: 'card:${first.id}',
                        fit: BoxFit.contain,
                        fallback: Container(
                          decoration: BoxDecoration(
                            color: tone,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            first.color,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: WalkaColors.navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(categoryName.toUpperCase(), style: WalkaType.eyebrow),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: variants
                          .map(
                            (WalkaCatalogVariant variant) => Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _swatchColor(variant.swatchHex),
                                shape: BoxShape.circle,
                                border: Border.all(color: WalkaColors.line),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: WalkaColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

WalkaHomeSectionConfig? _sectionConfig(
  WalkaHomeLayoutContent? layout,
  WalkaHomeSectionId id,
) {
  if (layout == null) return null;
  for (final WalkaHomeSectionConfig section in layout.sections) {
    if (section.id == id) return section;
  }
  return null;
}

List<WalkaCatalogProduct> _featuredProducts(
  WalkaCatalogSnapshot catalog,
  WalkaHomeFeaturedContent? featured,
) {
  if (featured == null) return const <WalkaCatalogProduct>[];
  final List<WalkaCatalogProduct> products = <WalkaCatalogProduct>[];
  final Set<String> seen = <String>{};
  for (final String variantId in featured.collectionVariantIds) {
    for (final WalkaCatalogProduct product in catalog.products) {
      if (product.variants.any(
            (WalkaCatalogVariant variant) => variant.id == variantId,
          ) &&
          seen.add(product.id)) {
        products.add(product);
        break;
      }
    }
  }
  return List<WalkaCatalogProduct>.unmodifiable(products);
}

List<WalkaCatalogProduct> _searchOrderedProducts(
  WalkaCatalogSnapshot catalog,
  WalkaSearchPresentationContent? presentation,
) {
  if (presentation == null || presentation.featuredVariantIds.isEmpty) {
    return catalog.products;
  }
  final List<WalkaCatalogProduct> ordered = <WalkaCatalogProduct>[];
  final Set<String> seen = <String>{};
  for (final String variantId in presentation.featuredVariantIds) {
    for (final WalkaCatalogProduct product in catalog.products) {
      if (product.variants.any(
            (WalkaCatalogVariant variant) => variant.id == variantId,
          ) &&
          seen.add(product.id)) {
        ordered.add(product);
        break;
      }
    }
  }
  for (final WalkaCatalogProduct product in catalog.products) {
    if (seen.add(product.id)) ordered.add(product);
  }
  return List<WalkaCatalogProduct>.unmodifiable(ordered);
}

String _categoryName(WalkaCatalogSnapshot catalog, String categoryId) {
  return catalog.categoryById(categoryId)?.name ?? categoryId;
}

Color _swatchColor(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return WalkaColors.surface;
  }
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}
