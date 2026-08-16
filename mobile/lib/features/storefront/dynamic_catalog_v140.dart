import 'package:flutter/material.dart';

import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../commerce/amazon_purchase.dart';

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
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return ListView(
      key: const PageStorageKey<String>('walka-dynamic-home'),
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 42),
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text('WALKA', style: TextStyle(color: WalkaColors.navy, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.7)),
            const Spacer(),
            IconButton(onPressed: onSearch, tooltip: 'Search', icon: const Icon(Icons.search_rounded)),
          ],
        ),
        const SizedBox(height: 22),
        const Text('DASHBOARD CATALOG', style: WalkaType.eyebrow),
        const SizedBox(height: 8),
        const Text('Products managed in one place', style: WalkaType.sectionTitle),
        const SizedBox(height: 8),
        Text(
          '${catalog.products.length} products · ${catalog.categories.length} categories · ${catalog.variants.length} colors',
          style: WalkaType.body,
        ),
        const SizedBox(height: 24),
        ...catalog.products.take(3).map(
          (WalkaCatalogProduct product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DynamicProductCard(
              product: product,
              categoryName: _categoryName(catalog, product.category),
              onTap: () => openWalkaDynamicProduct(context, product.id),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onShopAll,
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Browse all products'),
        ),
      ],
    );
  }
}

class WalkaDynamicCategoriesV140 extends StatelessWidget {
  const WalkaDynamicCategoriesV140({this.onSearch, super.key});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return ListView(
      key: const PageStorageKey<String>('walka-dynamic-categories'),
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 42),
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: Text('Categories', style: WalkaType.sectionTitle)),
            if (onSearch != null)
              IconButton(onPressed: onSearch, tooltip: 'Search', icon: const Icon(Icons.search_rounded)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Created, ordered and published from the WALKA Dashboard.', style: WalkaType.body),
        const SizedBox(height: 22),
        ...catalog.categories.map((WalkaCatalogCategory category) {
          final List<WalkaCatalogProduct> products = catalog.products
              .where((WalkaCatalogProduct product) => product.category == category.id)
              .toList(growable: false);
          if (products.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(child: Text(category.name, style: const TextStyle(color: WalkaColors.navy, fontSize: 20, fontWeight: FontWeight.w900))),
                    Text('${products.length}', style: const TextStyle(color: WalkaColors.muted, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 10),
                ...products.map(
                  (WalkaCatalogProduct product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DynamicProductCard(
                      product: product,
                      categoryName: category.name,
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
    final String query = _query.trim().toLowerCase();
    final List<WalkaCatalogProduct> results = catalog.products.where((product) {
      if (_categoryId != null && product.category != _categoryId) return false;
      if (query.isEmpty) return true;
      final String haystack = <String>[
        product.name,
        product.category,
        _categoryName(catalog, product.category),
        product.features.join(' '),
        product.facts.values.join(' '),
        ...product.variants.expand((variant) => <String>[variant.color, variant.pantone ?? '', variant.asin]),
      ].join(' ').toLowerCase();
      return query.split(RegExp(r'\s+')).every(haystack.contains);
    }).toList(growable: false);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return ListView(
      key: const PageStorageKey<String>('walka-dynamic-search'),
      padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 42),
      children: <Widget>[
        const Text('Search', style: WalkaType.sectionTitle),
        const SizedBox(height: 14),
        TextField(
          onChanged: (String value) => setState(() => _query = value),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Product, category, color, feature…'),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              ChoiceChip(label: const Text('All'), selected: _categoryId == null, onSelected: (_) => setState(() => _categoryId = null)),
              ...catalog.categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: _categoryId == category.id,
                    onSelected: (_) => setState(() => _categoryId = category.id),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('${results.length} ${results.length == 1 ? 'product' : 'products'}', style: const TextStyle(color: WalkaColors.muted, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No Dashboard products match this search.', style: WalkaType.body)),
          )
        else
          ...results.map(
            (product) => Padding(
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
  State<WalkaDynamicProductDetailV140> createState() => _WalkaDynamicProductDetailV140State();
}

class _WalkaDynamicProductDetailV140State extends State<WalkaDynamicProductDetailV140> {
  String? _selectedVariantId;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogSnapshot catalog = WalkaCatalogScope.of(context).snapshot;
    final WalkaCatalogProduct? product = catalog.productById(widget.productId);
    if (product == null || product.variants.isEmpty) {
      return const Scaffold(body: SafeArea(child: Center(child: Text('This Dashboard product is no longer available.'))));
    }

    final WalkaCatalogVariant selected = product.variants.firstWhere(
      (variant) => variant.id == _selectedVariantId,
      orElse: () => product.variants.first,
    );
    final Color tone = _swatchColor(selected.swatchHex);

    return Scaffold(
      backgroundColor: WalkaColors.ivory,
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 42),
        children: <Widget>[
          Container(
            height: 190,
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: WalkaColors.line),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.inventory_2_outlined, size: 54, color: WalkaColors.navy),
                  const SizedBox(height: 10),
                  Text(selected.color, style: const TextStyle(color: WalkaColors.navy, fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_categoryName(catalog, product.category), style: WalkaType.eyebrow),
          const SizedBox(height: 7),
          Text(product.name, style: WalkaType.sectionTitle),
          const SizedBox(height: 18),
          const Text('Colors', style: TextStyle(color: WalkaColors.navy, fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.variants.map((variant) {
              final bool active = variant.id == selected.id;
              return ChoiceChip(
                selected: active,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: _swatchColor(variant.swatchHex), shape: BoxShape.circle, border: Border.all(color: WalkaColors.line))),
                    const SizedBox(width: 6),
                    Text(variant.color),
                  ],
                ),
                onSelected: (_) => setState(() => _selectedVariantId = variant.id),
              );
            }).toList(growable: false),
          ),
          if (selected.pantone != null) ...<Widget>[
            const SizedBox(height: 10),
            Text('Pantone: ${selected.pantone}', style: WalkaType.body),
          ],
          if (product.features.isNotEmpty) ...<Widget>[
            const SizedBox(height: 24),
            const Text('Features', style: TextStyle(color: WalkaColors.navy, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...product.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                const Padding(padding: EdgeInsets.only(top: 7), child: Icon(Icons.circle, size: 6, color: WalkaColors.gold)),
                const SizedBox(width: 9),
                Expanded(child: Text(feature, style: WalkaType.body)),
              ]),
            )),
          ],
          if (product.facts.isNotEmpty) ...<Widget>[
            const SizedBox(height: 22),
            const Text('Details', style: TextStyle(color: WalkaColors.navy, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            ...product.facts.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Expanded(child: Text(entry.key, style: const TextStyle(color: WalkaColors.muted, fontWeight: FontWeight.w700))),
                const SizedBox(width: 12),
                Expanded(child: Text('${entry.value}', textAlign: TextAlign.right, style: const TextStyle(color: WalkaColors.navy, fontWeight: FontWeight.w800))),
              ]),
            )),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => openAmazonPurchaseUri(selected.purchaseUri),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text('Buy ${selected.color} on Amazon'),
          ),
          const SizedBox(height: 8),
          Text('ASIN ${selected.asin}', textAlign: TextAlign.center, style: const TextStyle(color: WalkaColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _DynamicProductCard extends StatelessWidget {
  const _DynamicProductCard({required this.product, required this.categoryName, required this.onTap});

  final WalkaCatalogProduct product;
  final String categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<WalkaCatalogVariant> variants = product.variants;
    final Color tone = variants.isEmpty ? WalkaColors.surface : _swatchColor(variants.first.swatchHex);
    return Material(
      color: WalkaColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: WalkaColors.line)),
          child: Row(
            children: <Widget>[
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.inventory_2_outlined, color: WalkaColors.navy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(categoryName.toUpperCase(), style: WalkaType.eyebrow),
                    const SizedBox(height: 4),
                    Text(product.name, style: const TextStyle(color: WalkaColors.navy, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: variants.map((variant) => Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(color: _swatchColor(variant.swatchHex), shape: BoxShape.circle, border: Border.all(color: WalkaColors.line)),
                      )).toList(growable: false),
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

String _categoryName(WalkaCatalogSnapshot catalog, String categoryId) {
  return catalog.categoryById(categoryId)?.name ?? categoryId;
}

Color _swatchColor(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex)) {
    return WalkaColors.surface;
  }
  return Color(int.parse('FF${hex.substring(1)}', radix: 16));
}
