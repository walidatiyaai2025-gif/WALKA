import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import 'account_about_reference_v131.dart';
import 'favorites_reference_v131.dart';
import 'storefront_resilient_v130.dart';

/// API-002 connected storefront entry surface with DESIGN-002 premium chrome,
/// DESIGN-005 secondary screens and DESIGN-006 resilient state feedback.
///
/// Home, Search, Categories, Favorites and Account preserve the released
/// catalog/state/navigation contracts while sharing one premium WALKA visual
/// language.
class WalkaStorefrontSplashV102 extends StatelessWidget {
  const WalkaStorefrontSplashV102({super.key});

  @override
  Widget build(BuildContext context) {
    final bool compact =
        MediaQuery.sizeOf(context).width < WalkaAdaptiveMetrics.compactWidth;

    return Scaffold(
      backgroundColor: WalkaColors.navy,
      body: WalkaAdaptiveFrame(
        backgroundColor: WalkaColors.navy,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        WalkaShellMetrics.horizontalGutter(context),
                        compact ? 18 : 24,
                        WalkaShellMetrics.horizontalGutter(context),
                        compact ? 20 : 28,
                      ),
                      child: WalkaSplashContent(
                        compact: compact,
                        onEnter: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const WalkaStorefrontShellV102(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class WalkaStorefrontShellV102 extends StatefulWidget {
  const WalkaStorefrontShellV102({super.key});

  @override
  State<WalkaStorefrontShellV102> createState() =>
      _WalkaStorefrontShellV102State();
}

class _WalkaStorefrontShellV102State extends State<WalkaStorefrontShellV102> {
  int _index = 0;
  late final WalkaCatalogController _fallbackCatalog = WalkaCatalogController();

  void _select(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_index == value) return;
    setState(() => _index = value);
  }

  @override
  void dispose() {
    _fallbackCatalog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (WalkaCatalogScope.maybeOf(context) == null) {
      return WalkaCatalogScope(
        controller: _fallbackCatalog,
        child: Builder(builder: _buildShell),
      );
    }
    return _buildShell(context);
  }

  Widget _buildShell(BuildContext context) {
    final List<Widget> pages = <Widget>[
      WalkaHomePremiumV130(
        onShopAll: () => _select(WalkaShellDestination.categories.index),
        onSearch: () => _select(WalkaShellDestination.search.index),
      ),
      const WalkaSearchPremiumV130(),
      WalkaCategoriesPremiumV130(
        onSearch: () => _select(WalkaShellDestination.search.index),
      ),
      WalkaFavoritesReferenceV131(
        onExplore: () => _select(WalkaShellDestination.categories.index),
      ),
      WalkaAccountReferenceV131(
        onFavorites: () => _select(WalkaShellDestination.favorites.index),
      ),
    ];

    return Scaffold(
      body: WalkaAdaptiveFrame(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: WalkaAdaptiveNavigationFrame(
        child: WalkaPremiumNavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
        ),
      ),
    );
  }
}
