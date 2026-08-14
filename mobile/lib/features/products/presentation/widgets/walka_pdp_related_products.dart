import 'package:flutter/material.dart';

import '../../../catalog/domain/walka_catalog.dart';

List<WalkaCatalogProduct> walkaResolveVisibleRelatedProducts({
  required WalkaCatalogSnapshot catalog,
  required List<String> relatedProductIds,
}) {
  final List<WalkaCatalogProduct> products = <WalkaCatalogProduct>[];
  for (final String productId in relatedProductIds) {
    final WalkaCatalogProduct? product = catalog.productById(productId);
    if (product != null) products.add(product);
  }
  return List<WalkaCatalogProduct>.unmodifiable(products);
}

class WalkaPdpRelatedProducts extends StatelessWidget {
  const WalkaPdpRelatedProducts({
    required this.products,
    required this.onOpen,
    super.key,
  });

  final List<WalkaCatalogProduct> products;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'YOU MAY ALSO LIKE',
          style: TextStyle(
            color: Color(0xFF8A6D31),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'More from WALKA',
          style: TextStyle(
            color: Color(0xFF003366),
            fontFamily: 'serif',
            fontSize: 24,
            height: 1.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        for (int index = 0; index < products.length; index++) ...<Widget>[
          _RelatedProductCard(
            product: products[index],
            onPressed: () => onOpen(products[index].id),
          ),
          if (index != products.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RelatedProductCard extends StatelessWidget {
  const _RelatedProductCard({
    required this.product,
    required this.onPressed,
  });

  final WalkaCatalogProduct product;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String supporting = product.shortDescription ??
        (product.highlights.isNotEmpty
            ? product.highlights.first
            : product.features.isNotEmpty
                ? product.features.first
                : 'Explore this WALKA product family.');

    return Material(
      color: const Color(0xFFF7F9FA),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey<String>('related-product-${product.id}'),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDDE5EB)),
                ),
                child: Icon(
                  product.id == 'stainless-steel-bento-lunch-box'
                      ? Icons.lunch_dining_outlined
                      : Icons.grid_view_rounded,
                  color: const Color(0xFF003366),
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.category.replaceAll('-', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF728395),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF003366),
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supporting,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF637382),
                        fontSize: 10.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF003366),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
