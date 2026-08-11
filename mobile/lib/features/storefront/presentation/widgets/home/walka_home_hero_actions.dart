import 'package:flutter/material.dart';

class WalkaHomeHeroActions extends StatelessWidget {
  const WalkaHomeHeroActions({
    required this.onShopAll,
    required this.onSearch,
    this.shopLabel = 'SHOP PRODUCTS',
    this.searchLabel = 'SEARCH COLLECTION',
    super.key,
  });

  final VoidCallback onShopAll;
  final VoidCallback onSearch;
  final String shopLabel;
  final String searchLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 235),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton.icon(
            key: const ValueKey<String>('home-reference-shop'),
            onPressed: onShopAll,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(shopLabel),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const ValueKey<String>('home-reference-search-cta'),
            onPressed: onSearch,
            child: Text(searchLabel),
          ),
        ],
      ),
    );
  }
}
