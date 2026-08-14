import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import 'account_about_cms_v140.dart';
import 'favorites_reference_v131.dart';
import 'storefront_resilient_v130.dart';

/// API-002 connected storefront entry surface with premium reusable shell.
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
        child: WalkaSafeAreaChrome(
          backgroundColor: WalkaColors.navy,
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
  late final WalkaCatalogController _fallbackCatalog = WalkaCatalogController();
  late final WalkaShellController _shellController = WalkaShellController();

  void _select(WalkaShellDestination destination) {
    FocusManager.instance.primaryFocus?.unfocus();
    _shellController.select(destination);
  }

  @override
  void dispose() {
    _shellController.dispose();
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
        onShopAll: () => _select(WalkaShellDestination.categories),
        onSearch: () => _select(WalkaShellDestination.search),
      ),
      const WalkaSearchPremiumV130(),
      WalkaCategoriesPremiumV130(
        onSearch: () => _select(WalkaShellDestination.search),
      ),
      WalkaFavoritesReferenceV131(
        onExplore: () => _select(WalkaShellDestination.categories),
      ),
      WalkaAccountCmsV140(
        onFavorites: () => _select(WalkaShellDestination.favorites),
      ),
    ];

    return WalkaMobileShellScaffold(
      controller: _shellController,
      pages: pages,
    );
  }
}
