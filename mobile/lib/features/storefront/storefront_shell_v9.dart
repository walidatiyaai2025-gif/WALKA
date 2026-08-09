import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_v6.dart';
import '../lifestyle/favorites_v5.dart';
import '../lifestyle/lifestyle_v4.dart' show WalkaAccountV4;
import '../search/search_discovery_v9.dart';
import 'storefront_v2.dart' show WalkaHomeV2;

class WalkaStorefrontSplashV9 extends StatelessWidget {
  const WalkaStorefrontSplashV9({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WalkaColors.navy,
      body: WalkaAdaptiveFrame(
        backgroundColor: WalkaColors.navy,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              WalkaAdaptiveMetrics.horizontalPadding(context),
              24,
              WalkaAdaptiveMetrics.horizontalPadding(context),
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(),
                Semantics(
                  header: true,
                  label: 'WALKA',
                  child: const Text(
                    'WALKA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 8.2,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(width: 54, height: 2, color: WalkaColors.gold),
                const SizedBox(height: 20),
                const Text(
                  'PREMIUM HOME ORGANIZATION',
                  style: TextStyle(
                    color: Color(0xFFC9D4DF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.1,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 315,
                  child: Text(
                    'Find the right piece.\nKeep the calm.',
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
                  width: 315,
                  child: Text(
                    'Browse the full WALKA storefront, search every available variant, and continue into a complete product experience.',
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
                        builder: (_) => const WalkaStorefrontShellV9(),
                      ),
                    );
                  },
                  child: const Text('ENTER WALKA'),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'UI PREVIEW · 0.9.0',
                    style: TextStyle(
                      color: Color(0xFF91A5B9),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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

class WalkaStorefrontShellV9 extends StatefulWidget {
  const WalkaStorefrontShellV9({super.key});

  @override
  State<WalkaStorefrontShellV9> createState() => _WalkaStorefrontShellV9State();
}

class _WalkaStorefrontShellV9State extends State<WalkaStorefrontShellV9> {
  int _index = 0;

  void _selectTab(int value) {
    if (_index == value) {
      return;
    }
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const WalkaHomeV2(),
      const WalkaSearchDiscoveryV9(),
      WalkaCategoriesV6(onSearch: () => _selectTab(1)),
      WalkaFavoritesV5(onExploreCollections: () => _selectTab(2)),
      const WalkaAccountV4(),
    ];

    return Scaffold(
      body: WalkaAdaptiveFrame(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: WalkaAdaptiveNavigationFrame(
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _selectTab,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
              tooltip: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Search',
              tooltip: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Categories',
              tooltip: 'Categories',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Favorites',
              tooltip: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Account',
              tooltip: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
