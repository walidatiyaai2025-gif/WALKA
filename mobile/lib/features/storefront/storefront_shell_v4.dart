import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../catalog/catalog_v3.dart';
import '../lifestyle/lifestyle_v4.dart';
import 'storefront_v2.dart' show WalkaHomeV2;

class WalkaStorefrontSplashV4 extends StatelessWidget {
  const WalkaStorefrontSplashV4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WalkaColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(),
              const Text(
                'WALKA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8.2,
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
                width: 300,
                child: Text(
                  'Explore collections, save favorites and discover the story behind the WALKA approach.',
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
                      builder: (_) => const WalkaStorefrontShellV4(),
                    ),
                  );
                },
                child: const Text('ENTER WALKA'),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'UI PREVIEW · 0.4.0',
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
    );
  }
}

class WalkaStorefrontShellV4 extends StatefulWidget {
  const WalkaStorefrontShellV4({super.key});

  @override
  State<WalkaStorefrontShellV4> createState() =>
      _WalkaStorefrontShellV4State();
}

class _WalkaStorefrontShellV4State extends State<WalkaStorefrontShellV4> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    WalkaHomeV2(),
    WalkaCategoriesV3(),
    WalkaFavoritesV4(),
    WalkaAccountV4(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
