import 'package:flutter/material.dart';

class WalkaHomeHeroActions extends StatelessWidget {
  const WalkaHomeHeroActions({
    required this.onShopAll,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onShopAll;
  final VoidCallback onSearch;

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
            label: const Text('SHOP PRODUCTS'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const ValueKey<String>('home-reference-search-cta'),
            onPressed: onSearch,
            child: const Text('SEARCH COLLECTION'),
          ),
        ],
      ),
    );
  }
}
