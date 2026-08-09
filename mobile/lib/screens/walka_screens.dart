import 'package:flutter/material.dart';

import '../design_system/walka_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WalkaColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WalkaSpacing.lg),
          child: Column(
            children: <Widget>[
              const Spacer(),
              const _WalkaWordmark(light: true, large: true),
              const SizedBox(height: WalkaSpacing.md),
              Container(
                width: 42,
                height: 2,
                color: WalkaColors.gold,
              ),
              const SizedBox(height: WalkaSpacing.md),
              const Text(
                'PREMIUM HOME ORGANIZATION',
                style: TextStyle(
                  color: Color(0xFFCFD8E3),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.1,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const WalkaShell(),
                    ),
                  );
                },
                child: const Text('EXPLORE WALKA'),
              ),
              const SizedBox(height: WalkaSpacing.sm),
              const Text(
                'Phase 1 · Visual Prototype',
                style: TextStyle(
                  color: Color(0xFF9FB0C2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalkaShell extends StatefulWidget {
  const WalkaShell({super.key});

  @override
  State<WalkaShell> createState() => _WalkaShellState();
}

class _WalkaShellState extends State<WalkaShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) {
          setState(() => _index = index);
        },
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openProduct(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProductPreviewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: <Widget>[
                  const _WalkaWordmark(),
                  const Spacer(),
                  _RoundIconButton(
                    icon: Icons.search_rounded,
                    semanticLabel: 'Search',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HeroCard(onShop: () => _openProduct(context)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 34)),
          SliverToBoxAdapter(
            child: _SectionHeader(
              eyebrow: 'CURATED FOR CALM',
              title: 'Organize beautifully',
              actionLabel: 'View all',
              onAction: () {},
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 188,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  _CollectionCard(
                    icon: Icons.kitchen_outlined,
                    title: 'Drawer\nEssentials',
                    subtitle: 'Order in every detail',
                    onTap: () => _openProduct(context),
                  ),
                  const SizedBox(width: 12),
                  _CollectionCard(
                    icon: Icons.lunch_dining_outlined,
                    title: 'Lunch\nCollection',
                    subtitle: 'Designed for daily life',
                    onTap: () => _openProduct(context),
                  ),
                  const SizedBox(width: 12),
                  _CollectionCard(
                    icon: Icons.home_outlined,
                    title: 'Home\nEdit',
                    subtitle: 'Simple, considered storage',
                    onTap: () => _openProduct(context),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 34)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _BrandPromise(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('DISCOVER WALKA', style: WalkaType.eyebrow),
                  const SizedBox(height: 10),
                  const Text(
                    'Less clutter.\nMore room to live.',
                    style: WalkaType.sectionTitle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Purposeful organizers made to bring calm, clarity and a refined rhythm to everyday spaces.',
                    style: WalkaType.body,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WalkaColors.navy,
                      side: const BorderSide(color: WalkaColors.navy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(WalkaRadius.pill),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'OUR STORY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: <Widget>[
          const _WalkaWordmark(),
          const SizedBox(height: 34),
          const Text('SHOP', style: WalkaType.eyebrow),
          const SizedBox(height: 10),
          const Text('Collections', style: WalkaType.sectionTitle),
          const SizedBox(height: 8),
          const Text(
            'Thoughtful storage for the spaces you use every day.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 24),
          _CategoryTile(
            number: '01',
            title: 'Drawer Organization',
            subtitle: 'Expandable, composed, effortless.',
            icon: Icons.kitchen_outlined,
            onTap: () => _openProduct(context),
          ),
          const SizedBox(height: 14),
          _CategoryTile(
            number: '02',
            title: 'Lunch Collection',
            subtitle: 'Premium essentials for life on the move.',
            icon: Icons.lunch_dining_outlined,
            onTap: () => _openProduct(context),
          ),
          const SizedBox(height: 14),
          _CategoryTile(
            number: '03',
            title: 'The Home Edit',
            subtitle: 'A growing collection of calm.',
            icon: Icons.home_outlined,
            onTap: () => _openProduct(context),
          ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProductPreviewScreen()),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _WalkaWordmark(),
            const SizedBox(height: 34),
            const Text('YOUR EDIT', style: WalkaType.eyebrow),
            const SizedBox(height: 10),
            const Text('Favorites', style: WalkaType.sectionTitle),
            const Spacer(),
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 86,
                    height: 86,
                    decoration: const BoxDecoration(
                      color: WalkaColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 34,
                      color: WalkaColors.navy,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Your favorites, beautifully kept.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      color: WalkaColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Save the WALKA pieces you want to return to.',
                    textAlign: TextAlign.center,
                    style: WalkaType.body,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProductPreviewScreen(),
                          ),
                        );
                      },
                      child: const Text('DISCOVER PRODUCTS'),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: <Widget>[
          const _WalkaWordmark(),
          const SizedBox(height: 34),
          const Text('WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 10),
          const Text('Account', style: WalkaType.sectionTitle),
          const SizedBox(height: 8),
          const Text(
            'A quiet place for your WALKA preferences and brand information.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 28),
          const _AccountIntroCard(),
          const SizedBox(height: 18),
          _AccountRow(
            icon: Icons.auto_stories_outlined,
            title: 'About WALKA',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              );
            },
          ),
          _AccountRow(
            icon: Icons.storefront_outlined,
            title: 'Amazon Store',
            onTap: () {},
          ),
          _AccountRow(
            icon: Icons.mail_outline_rounded,
            title: 'Contact',
            onTap: () {},
          ),
          _AccountRow(
            icon: Icons.shield_outlined,
            title: 'Privacy & Terms',
            onTap: () {},
          ),
          const SizedBox(height: 28),
          const Text(
            'WALKA · Phase 1 Preview · v0.1.0',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: WalkaColors.muted),
          ),
        ],
      ),
    );
  }
}

class ProductPreviewScreen extends StatelessWidget {
  const ProductPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _WalkaWordmark(),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border_rounded),
            tooltip: 'Favorite',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: <Widget>[
          const _OrganizerIllustration(),
          const SizedBox(height: 24),
          const Text('DRAWER ORGANIZATION', style: WalkaType.eyebrow),
          const SizedBox(height: 9),
          const Text(
            'Expandable Drawer Organizer',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 30,
              height: 1.08,
              fontWeight: FontWeight.w600,
              color: WalkaColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '8 compartments · Expandable · Non-slip base',
            style: WalkaType.body,
          ),
          const SizedBox(height: 22),
          const Text(
            'COLOR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: WalkaColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: <Widget>[
              _ColorSwatch(color: Colors.white, selected: true),
              SizedBox(width: 10),
              _ColorSwatch(color: Color(0xFF8C9198)),
            ],
          ),
          const SizedBox(height: 26),
          const _FeatureStrip(),
          const SizedBox(height: 26),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('BUY ON AMAZON'),
          ),
          const SizedBox(height: 10),
          const Text(
            'Amazon linking will be activated after the visual prototype is approved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: WalkaColors.muted),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 22),
          const Text('Made for everyday order', style: WalkaType.sectionTitle),
          const SizedBox(height: 12),
          const Text(
            'A refined organizer designed to create a clear home for cutlery and everyday essentials while keeping the drawer visually calm.',
            style: WalkaType.body,
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Story')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: WalkaColors.navy,
              borderRadius: BorderRadius.circular(WalkaRadius.lg),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('THE WALKA EDIT', style: WalkaType.eyebrow),
                SizedBox(height: 12),
                Text(
                  'Beautiful spaces begin with thoughtful details.',
                  style: WalkaType.display,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text('Designed for calm', style: WalkaType.sectionTitle),
          const SizedBox(height: 12),
          const Text(
            'WALKA creates premium organization essentials that make daily routines feel clearer, calmer and more considered. The design language is simple: useful forms, refined finishes and less visual noise.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 26),
          const _BrandPromise(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430,
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(WalkaRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -58,
            top: -38,
            child: _DecorativeRing(size: 220),
          ),
          const Positioned(
            right: 26,
            bottom: 32,
            child: _MiniOrganizer(),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('A CALMER HOME, BY DESIGN', style: WalkaType.eyebrow),
                const SizedBox(height: 14),
                const SizedBox(
                  width: 285,
                  child: Text(
                    'Beautifully organized. Effortlessly yours.',
                    style: WalkaType.display,
                  ),
                ),
                const SizedBox(height: 14),
                const SizedBox(
                  width: 260,
                  child: Text(
                    'Premium organization essentials created to bring clarity to everyday spaces.',
                    style: TextStyle(
                      color: Color(0xFFD8E0E8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 210,
                  child: ElevatedButton(
                    onPressed: onShop,
                    child: const Text('SHOP THE COLLECTION'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeRing extends StatelessWidget {
  const _DecorativeRing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: WalkaColors.gold.withValues(alpha: 0.24),
          width: 34,
        ),
      ),
    );
  }
}

class _MiniOrganizer extends StatelessWidget {
  const _MiniOrganizer();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        width: 150,
        height: 112,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F1E9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: _MiniCompartment(heightFactor: 1)),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                children: <Widget>[
                  const Expanded(child: _MiniCompartment(heightFactor: 0.5)),
                  const SizedBox(height: 5),
                  const Expanded(child: _MiniCompartment(heightFactor: 0.5)),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: _MiniCompartment(heightFactor: 1)),
          ],
        ),
      ),
    );
  }
}

class _MiniCompartment extends StatelessWidget {
  const _MiniCompartment({required this.heightFactor});

  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2DED4)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String eyebrow;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(eyebrow, style: WalkaType.eyebrow),
                const SizedBox(height: 7),
                Text(title, style: WalkaType.sectionTitle),
              ],
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(WalkaRadius.md),
      child: Container(
        width: 154,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WalkaColors.surface,
          borderRadius: BorderRadius.circular(WalkaRadius.md),
          border: Border.all(color: WalkaColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: WalkaColors.navy, size: 26),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                height: 1.04,
                fontWeight: FontWeight.w600,
                color: WalkaColors.navy,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              maxLines: 2,
              style: const TextStyle(
                color: WalkaColors.muted,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPromise extends StatelessWidget {
  const _BrandPromise();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E9CF),
        borderRadius: BorderRadius.circular(WalkaRadius.md),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.auto_awesome_outlined, color: WalkaColors.navy),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'THE WALKA STANDARD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: WalkaColors.navy,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Useful by nature. Refined by design.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: WalkaColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.surface,
      borderRadius: BorderRadius.circular(WalkaRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WalkaRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: WalkaColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: WalkaColors.navy),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$number  $title',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: WalkaColors.navy,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WalkaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: WalkaColors.navy),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountIntroCard extends StatelessWidget {
  const _AccountIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(WalkaRadius.md),
      ),
      child: const Row(
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: WalkaColors.gold,
            child: Icon(Icons.person_outline_rounded, color: WalkaColors.navy),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome to WALKA',
                  style: TextStyle(
                    color: WalkaColors.white,
                    fontFamily: 'serif',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Account services arrive after Phase 1.',
                  style: TextStyle(color: Color(0xFFB9C6D3), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: WalkaColors.navy),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _OrganizerIllustration extends StatelessWidget {
  const _OrganizerIllustration();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: WalkaColors.surface,
          borderRadius: BorderRadius.circular(WalkaRadius.lg),
        ),
        child: Transform.rotate(
          angle: -0.035,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDEDAD0), width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1F0F172A),
                  blurRadius: 28,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                const Expanded(flex: 2, child: _ProductCompartment()),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: _ProductCompartment()),
                      const SizedBox(height: 7),
                      const Expanded(child: _ProductCompartment()),
                      const SizedBox(height: 7),
                      const Expanded(child: _ProductCompartment()),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                const Expanded(flex: 2, child: _ProductCompartment()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCompartment extends StatelessWidget {
  const _ProductCompartment();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E4DB)),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, this.selected = false});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? WalkaColors.gold : WalkaColors.line,
          width: selected ? 2 : 1,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: WalkaColors.line),
        ),
      ),
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: WalkaColors.line),
        ),
      ),
      child: const Row(
        children: <Widget>[
          Expanded(child: _Feature(icon: Icons.tune_rounded, label: 'Expandable')),
          Expanded(child: _Feature(icon: Icons.grid_view_rounded, label: '8 sections')),
          Expanded(child: _Feature(icon: Icons.layers_outlined, label: 'Non-slip')),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: WalkaColors.navy, size: 21),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: WalkaColors.navy,
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: semanticLabel,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: WalkaColors.navy,
        backgroundColor: WalkaColors.surface,
      ),
    );
  }
}

class _WalkaWordmark extends StatelessWidget {
  const _WalkaWordmark({this.light = false, this.large = false});

  final bool light;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Text(
      'WALKA',
      style: TextStyle(
        color: light ? WalkaColors.white : WalkaColors.navy,
        fontSize: large ? 38 : 23,
        fontWeight: FontWeight.w800,
        letterSpacing: large ? 9 : 5.2,
      ),
    );
  }
}
