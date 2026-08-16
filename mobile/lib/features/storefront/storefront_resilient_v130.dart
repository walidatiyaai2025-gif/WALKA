import 'package:flutter/material.dart';

import 'catalog_state_surface_v130.dart';
import 'dynamic_catalog_v140.dart';

/// Production Home reads catalog membership, product names and colors from the
/// validated Dashboard/DB/API snapshot only.
class WalkaHomePremiumV130 extends StatelessWidget {
  const WalkaHomePremiumV130({
    required this.onShopAll,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return WalkaCatalogStateSurfaceV130(
      child: WalkaDynamicHomeV140(
        onShopAll: onShopAll,
        onSearch: onSearch,
      ),
    );
  }
}

class WalkaSearchPremiumV130 extends StatelessWidget {
  const WalkaSearchPremiumV130({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaCatalogStateSurfaceV130(
      child: WalkaDynamicSearchV140(),
    );
  }
}

class WalkaCategoriesPremiumV130 extends StatelessWidget {
  const WalkaCategoriesPremiumV130({this.onSearch, super.key});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return WalkaCatalogStateSurfaceV130(
      child: WalkaDynamicCategoriesV140(onSearch: onSearch),
    );
  }
}
