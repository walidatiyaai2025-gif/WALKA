import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import 'favorites_reference_v131.dart';
import 'secondary_premium_v130.dart';
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Spacer(),
                          _WalkaSplashBrandMark(compact: compact),
                          SizedBox(height: compact ? 12 : 18),
                          Container(width: 54, height: 2, color: WalkaColors.gold),
                          SizedBox(height: compact ? 14 : 20),
                          SizedBox(
                            width: 325,
                            child: Text(
                              'Thoughtful pieces.\nBeautifully organized.',
                              style: TextStyle(
                                fontFamily: 'serif',
                                color: Colors.white,
                                fontSize: compact ? 32 : 39,
                                height: 1.05,
                                fontWeight: FontWeight.w600,
                                letterSpacing: compact ? -0.45 : -0.7,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 12 : 16),
                          SizedBox(
                            width: 320,
                            child: Text(
                              'The complete WALKA experience for discovery, product detail, favorites, support and official Amazon purchase handoff.',
                              style: TextStyle(
                                color: const Color(0xFFB6C5D4),
                                height: compact ? 1.45 : 1.55,
                                fontSize: compact ? 13 : 14,
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(height: compact ? 16 : 22),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const WalkaStorefrontShellV102(),
                                ),
                              );
                            },
                            child: const Text('ENTER WALKA'),
                          ),
                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              'CONNECTED CATALOG · 1.2.0',
                              style: TextStyle(
                                color: Color(0xFF91A5B9),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                        ],
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

class _WalkaSplashBrandMark extends StatelessWidget {
  const _WalkaSplashBrandMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'WALKA For You',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.centerLeft,
              radius: 1.15,
              colors: <Color>[
                WalkaColors.gold.withValues(alpha: 0.12),
                WalkaColors.navy.withValues(alpha: 0),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SvgPicture.asset(
              'assets/branding/walka_logo.svg',
              width: compact ? 214 : 252,
              fit: BoxFit.contain,
            ),
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
        onShopAll: () => _select(2),
        onSearch: () => _select(1),
      ),
      const WalkaSearchPremiumV130(),
      WalkaCategoriesPremiumV130(onSearch: () => _select(1)),
      WalkaFavoritesReferenceV131(onExplore: () => _select(2)),
      const WalkaAccountPremiumV130(),
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