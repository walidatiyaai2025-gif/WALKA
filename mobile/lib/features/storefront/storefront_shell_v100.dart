import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_v10.dart';
import '../home/home_v100.dart';
import '../information/information_v100.dart';
import '../lifestyle/favorites_v10.dart';
import '../search/search_discovery_v9.dart';

class WalkaStorefrontSplashV100 extends StatelessWidget {
  const WalkaStorefrontSplashV100({super.key});

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
                      fontWeight: FontWeight.w900,
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
                  width: 320,
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
                    'The complete WALKA mobile visual experience — from discovery and product details to support and official purchase destinations.',
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
                        builder: (_) => const WalkaStorefrontShellV100(),
                      ),
                    );
                  },
                  child: const Text('ENTER WALKA'),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'VISUAL FREEZE · 1.0.0',
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

class WalkaStorefrontShellV100 extends StatefulWidget {
  const WalkaStorefrontShellV100({super.key});

  @override
  State<WalkaStorefrontShellV100> createState() =>
      _WalkaStorefrontShellV100State();
}

class _WalkaStorefrontShellV100State extends State<WalkaStorefrontShellV100> {
  int _index = 0;

  void _selectTab(int value) {
    if (_index == value) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      WalkaHomeV100(onExploreAll: () => _selectTab(2)),
      const WalkaSearchDiscoveryV9(),
      WalkaCategoriesV10(onSearch: () => _selectTab(1)),
      WalkaFavoritesV10(onExploreCollections: () => _selectTab(2)),
      const WalkaAccountV100(),
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
