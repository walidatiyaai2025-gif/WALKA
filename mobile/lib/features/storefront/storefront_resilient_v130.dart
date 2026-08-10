import 'package:flutter/material.dart';

import 'catalog_state_surface_v130.dart';
import 'discovery_reference_v123.dart';
import 'home_premium_v121.dart';

/// DESIGN-006 public Home surface. The validated DESIGN-001/007B.1 visual
/// hierarchy remains intact while catalog loading/offline feedback is promoted
/// to the shared V130 state surface.
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
