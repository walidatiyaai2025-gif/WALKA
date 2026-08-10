import 'package:flutter/material.dart';

import 'catalog_state_surface_v130.dart';
import 'discovery_reference_v123.dart';
import 'home_premium_v122.dart';

/// DESIGN-007 public Home surface. V122 keeps the approved Android-reference
/// hierarchy while removing fixed-height content areas found by the final
/// cross-device QA matrix.
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
      child: WalkaHomePremiumV122(
        onShopAll: onShopAll,
        onSearch: onSearch,
      ),
    );
  }
}

/// DESIGN-007B.2 public Search surface preserving released query/filter state
/// while using the Home/Categories reference visual language.
class WalkaSearchPremiumV130 extends StatelessWidget {
  const WalkaSearchPremiumV130({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaCatalogStateSurfaceV130(
      child: WalkaSearchPremiumV123(),
    );
  }
}

/// DESIGN-007B.2 public Categories surface based on the approved Android
/// Categories reference. Search navigation remains a shell-level action.
class WalkaCategoriesPremiumV130 extends StatelessWidget {
  const WalkaCategoriesPremiumV130({this.onSearch, super.key});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return WalkaCatalogStateSurfaceV130(
      child: WalkaCategoriesPremiumV123(onSearch: onSearch),
    );
  }
}
