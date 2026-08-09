import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_v3.dart';
import '../lifestyle/favorites_v5.dart';
import '../lifestyle/lifestyle_v4.dart' show WalkaAccountV4;
import 'storefront_v2.dart' show WalkaHomeV2;

class WalkaStorefrontSplashV5 extends StatelessWidget {
  const WalkaStorefrontSplashV5({super.key});

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
                  width: 310,
                  child: Text(
                    'A polished mobile-first WALKA experience for discovering premium organization essentials and continuing to Amazon to purchase.',
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
                        builder: (_) => const WalkaStorefrontShellV5(),
                      ),
                    );
                  },
                  child: const Text('ENTER WALKA'),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'PHASE 2 FUNCTIONAL PREVIEW · 0.7.0',
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

class WalkaStorefrontShellV5 extends StatefulWidget {
  const WalkaStorefrontShellV5({super.key});

  @override
  State<WalkaStorefrontShellV5> createState() =>
      _WalkaStorefrontShellV5State();
}

class _WalkaStorefrontShellV5State extends State<WalkaStorefrontShellV5> {
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
      const WalkaCategoriesV3(),
      WalkaFavoritesV5(onExploreCollections: () => _selectTab(1)),
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
