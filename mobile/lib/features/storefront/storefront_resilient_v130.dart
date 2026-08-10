import 'package:flutter/material.dart';

import 'catalog_state_surface_v130.dart';
import 'discovery_premium_v122.dart';
import 'home_premium_v121.dart';

/// DESIGN-006 public Home surface. The validated DESIGN-001 visual hierarchy
/// remains intact while catalog loading/offline feedback is promoted to the
/// shared V130 state surface.
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
      child: WalkaHomePremiumV121(
        onShopAll: onShopAll,
        onSearch: onSearch,
      ),
    );
  }
}

/// DESIGN-006 public Search surface preserving DESIGN-003 query/filter state.
class WalkaSearchPremiumV130 extends StatelessWidget {
  const WalkaSearchPremiumV130({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaCatalogStateSurfaceV130(
      child: WalkaSearchPremiumV122(),
    );
  }
}

/// DESIGN-006 public Categories surface preserving DESIGN-003 product-led
/// collection presentation.
class WalkaCategoriesPremiumV130 extends StatelessWidget {
  const WalkaCategoriesPremiumV130({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaCatalogStateSurfaceV130(
      child: WalkaCategoriesPremiumV122(),
    );
  }
}
