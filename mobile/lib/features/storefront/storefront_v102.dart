import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../information/information_v102.dart';
import 'home_premium_v121.dart';
import 'storefront_catalog_v120.dart';
import 'storefront_v101.dart' show WalkaFavoritesV101;

/// API-002 connected storefront entry surface with DESIGN-002 premium chrome.
///
/// Home, Search and Categories consume the typed catalog repository while
/// preserving the WALKA five-destination information architecture. DESIGN-002
/// centralizes the owner-visible wordmark and bottom navigation treatment so
/// all destinations inherit consistent, safe-area-aware premium chrome.
class WalkaStorefrontSplashV102 extends StatelessWidget {
  const WalkaStorefrontSplashV102({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WalkaColors.navy,
      body: WalkaAdaptiveFrame(
        backgroundColor: WalkaColors.navy,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              WalkaShellMetrics.horizontalGutter(context),
              24,
              WalkaShellMetrics.horizontalGutter(context),
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(),
                const WalkaWordmark(onDark: true),
                const SizedBox(height: 18),
                Container(width: 54, height: 2, color: WalkaColors.gold),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 325,
                  child: Text(
                    'Thoughtful pieces.\nBeautifully organized.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 39,
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 320,
                  child: Text(
                    'The complete WALKA experience for discovery, product detail, favorites, support and official Amazon purchase handoff.',
                    style: TextStyle(
                      color: Color(0xFFB6C5D4),
                      height: 1.55,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
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
      WalkaHomePremiumV121(
        onShopAll: () => _select(2),
        onSearch: () => _select(1),
      ),
      const WalkaSearchV120(),
      const WalkaCategoriesV120(),
      WalkaFavoritesV101(onExplore: () => _select(2)),
      const WalkaAccountV102(),
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
