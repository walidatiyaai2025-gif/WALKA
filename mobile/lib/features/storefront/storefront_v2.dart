import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../../screens/walka_screens.dart'
    show AboutScreen, AccountScreen, CategoriesScreen, FavoritesScreen;

class WalkaStorefrontSplash extends StatelessWidget {
  const WalkaStorefrontSplash({super.key});

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
              const _Wordmark(light: true, size: 42),
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
                width: 310,
                child: Text(
                  'A quieter way\nto organize home.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Colors.white,
                    fontSize: 40,
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
                  'Thoughtful essentials with refined form, useful details and less visual noise.',
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
                      builder: (_) => const WalkaStorefrontShell(),
                    ),
                  );
                },
                child: const Text('ENTER WALKA'),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'UI PREVIEW · 0.2.0',
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

class WalkaStorefrontShell extends StatefulWidget {
  const WalkaStorefrontShell({super.key});

  @override
  State<WalkaStorefrontShell> createState() => _WalkaStorefrontShellState();
}

class _WalkaStorefrontShellState extends State<WalkaStorefrontShell> {
  int _index = 0;

  late final List<Widget> _pages = <Widget>[
    const WalkaHomeV2(),
    const CategoriesScreen(),
    const FavoritesScreen(),
    const AccountScreen(),
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

class WalkaHomeV2 extends StatelessWidget {
  const WalkaHomeV2({super.key});

  void _openProduct(BuildContext context, {bool gray = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaProductDetailV2(initialGray: gray),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _HomeHeader(onSearch: () {})),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _EditorialHero(onShop: () => _openProduct(context)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 38)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _SectionTitle(
                eyebrow: 'WALKA ESSENTIALS',
                title: 'Made for everyday order',
                description:
                    'Premium organizers designed to look calm, work hard and stay useful every day.',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 330,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: <Widget>[
                  _ProductCard(
                    title: 'Expandable Drawer Organizer',
                    subtitle: '8 compartments · White',
                    tone: const Color(0xFFF6F3EC),
                    onTap: () => _openProduct(context),
                  ),
                  const SizedBox(width: 14),
                  _ProductCard(
                    title: 'Expandable Drawer Organizer',
                    subtitle: '8 compartments · Gray',
                    tone: const Color(0xFFE5E7EA),
                    gray: true,
                    onTap: () => _openProduct(context, gray: true),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 42)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _SectionTitle(
                eyebrow: 'SHOP BY SPACE',
                title: 'Calm starts with a place for everything',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _SpaceCard(
                      icon: Icons.kitchen_outlined,
                      label: 'DRAWERS',
                      title: 'Kitchen\nessentials',
                      onTap: () => _openProduct(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SpaceCard(
                      icon: Icons.lunch_dining_outlined,
                      label: 'ON THE GO',
                      title: 'Lunch\ncollection',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 42)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StoryPanel(
                onStory: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 42),
              child: _AmazonBand(),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkaProductDetailV2 extends StatefulWidget {
  const WalkaProductDetailV2({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  State<WalkaProductDetailV2> createState() => _WalkaProductDetailV2State();
}

class _WalkaProductDetailV2State extends State<WalkaProductDetailV2> {
  late bool _gray = widget.initialGray;
  int _galleryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Color productTone = _gray
        ? const Color(0xFFD9DCE0)
        : const Color(0xFFF7F4ED);

    return Scaffold(
      appBar: AppBar(
        title: const _Wordmark(),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            tooltip: 'Favorite',
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 42),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: _ProductGallery(
              gray: _gray,
              tone: productTone,
              index: _galleryIndex,
              onChanged: (int index) => setState(() => _galleryIndex = index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('DRAWER ORGANIZATION', style: WalkaType.eyebrow),
                const SizedBox(height: 10),
                const Text(
                  'WALKA Drawer Organizer',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    height: 1.08,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: WalkaColors.navy,
                  ),
                ),
                const SizedBox(height: 11),
                const Text(
                  '8 compartments · Expandable 13″–22.4″ · Non-slip base',
                  style: WalkaType.body,
                ),
                const SizedBox(height: 24),
                _VariantPicker(
                  gray: _gray,
                  onChanged: (bool value) {
                    setState(() {
                      _gray = value;
                      _galleryIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const _FeatureGrid(),
                const SizedBox(height: 26),
                const _AmazonPurchaseCard(),
                const SizedBox(height: 34),
                const Divider(),
                const SizedBox(height: 30),
                const _SectionTitle(
                  eyebrow: 'DESIGNED FOR DAILY LIFE',
                  title: 'More capacity. Less visual clutter.',
                  description:
                      'A generous expandable layout creates a clear home for cutlery, utensils and everyday drawer essentials while keeping everything easy to reach.',
                ),
                const SizedBox(height: 24),
                _EditorialProductPanel(gray: _gray),
                const SizedBox(height: 34),
                const _SpecificationCard(),
                const SizedBox(height: 34),
                const _CareNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
      child: Row(
        children: <Widget>[
          const _Wordmark(),
          const Spacer(),
          IconButton(
            onPressed: onSearch,
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            style: IconButton.styleFrom(
              foregroundColor: WalkaColors.navy,
              backgroundColor: WalkaColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  const _EditorialHero({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 470,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -48,
            top: 72,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: WalkaColors.gold.withValues(alpha: 0.22),
                  width: 44,
                ),
              ),
            ),
          ),
          const Positioned(
            right: 18,
            bottom: 28,
            child: _OrganizerRender(width: 190, gray: false, elevated: true),
          ),
          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('THE WALKA EDIT', style: WalkaType.eyebrow),
                const SizedBox(height: 15),
                const SizedBox(
                  width: 290,
                  child: Text(
                    'Beautiful order,\ndesigned to last.',
                    style: WalkaType.display,
                  ),
                ),
                const SizedBox(height: 14),
                const SizedBox(
                  width: 270,
                  child: Text(
                    'Elevated organization essentials for the spaces you use every day.',
                    style: TextStyle(
                      color: Color(0xFFD5DFE8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 205,
                  child: ElevatedButton(
                    onPressed: onShop,
                    child: const Text('SHOP BESTSELLER'),
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.onTap,
    this.gray = false,
  });

  final String title;
  final String subtitle;
  final Color tone;
  final VoidCallback onTap;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 244,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: WalkaColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: tone,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(23),
                      ),
                    ),
                    child: Center(
                      child: _OrganizerRender(width: 178, gray: gray),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          color: WalkaColors.navy,
                          fontSize: 19,
                          height: 1.08,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: WalkaColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: <Widget>[
                          Text(
                            'VIEW PRODUCT',
                            style: TextStyle(
                              color: WalkaColors.navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: WalkaColors.gold,
                          ),
                        ],
                      ),
                    ],
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

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            height: 154,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, color: WalkaColors.navy),
                const Spacer(),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: WalkaColors.gold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: WalkaColors.navy,
                    fontSize: 21,
                    height: 1.03,
                    fontWeight: FontWeight.w600,
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

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({required this.onStory});

  final VoidCallback onStory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'OUR APPROACH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: WalkaColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Useful by nature.\nRefined by design.',
            style: TextStyle(
              fontFamily: 'serif',
              color: WalkaColors.navy,
              fontSize: 28,
              height: 1.08,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We focus on considered proportions, calm finishes and practical details that make everyday routines feel simpler.',
            style: TextStyle(
              color: Color(0xFF44556A),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onStory,
            icon: const Icon(Icons.arrow_forward_rounded, size: 17),
            label: const Text('READ OUR STORY'),
          ),
        ],
      ),
    );
  }
}

class _AmazonBand extends StatelessWidget {
  const _AmazonBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.storefront_outlined, color: WalkaColors.navy),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'WALKA ON AMAZON',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Purchase flow will open the official Amazon listing.',
                  style: TextStyle(color: WalkaColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.north_east_rounded, color: WalkaColors.gold, size: 20),
        ],
      ),
    );
  }
}

class _ProductGallery extends StatelessWidget {
  const _ProductGallery({
    required this.gray,
    required this.tone,
    required this.index,
    required this.onChanged,
  });

  final bool gray;
  final Color tone;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.02,
          child: Container(
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      index == 0
                          ? 'HERO VIEW'
                          : index == 1
                          ? 'EXPANDED'
                          : 'DETAIL',
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Transform.scale(
                    scale: index == 1 ? 1.08 : index == 2 ? 0.92 : 1,
                    child: _OrganizerRender(
                      width: 292,
                      gray: gray,
                      elevated: true,
                      expanded: index == 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int item) {
            final bool selected = item == index;
            return GestureDetector(
              onTap: () => onChanged(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: selected ? WalkaColors.navy : WalkaColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _VariantPicker extends StatelessWidget {
  const _VariantPicker({required this.gray, required this.onChanged});

  final bool gray;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'COLOR',
              style: TextStyle(
                color: WalkaColors.navy,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const Spacer(),
            Text(
              gray ? 'Gray' : 'White',
              style: const TextStyle(
                color: WalkaColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: <Widget>[
            _SwatchButton(
              selected: !gray,
              color: const Color(0xFFFBFAF7),
              label: 'White',
              onTap: () => onChanged(false),
            ),
            const SizedBox(width: 10),
            _SwatchButton(
              selected: gray,
              color: const Color(0xFF92979E),
              label: 'Gray',
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ],
    );
  }
}

class _SwatchButton extends StatelessWidget {
  const _SwatchButton({
    required this.selected,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? WalkaColors.gold : WalkaColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD5D9DE)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? WalkaColors.navy : WalkaColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _FeatureTile(
            icon: Icons.open_in_full_rounded,
            title: '13″–22.4″',
            caption: 'Expandable',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _FeatureTile(
            icon: Icons.grid_view_rounded,
            title: '8',
            caption: 'Compartments',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _FeatureTile(
            icon: Icons.layers_outlined,
            title: 'Stable',
            caption: 'Non-slip base',
          ),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: WalkaColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: WalkaColors.navy, size: 21),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(color: WalkaColors.muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _AmazonPurchaseCard extends StatelessWidget {
  const _AmazonPurchaseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.verified_outlined, color: WalkaColors.navy, size: 20),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Available from the official WALKA listing on Amazon',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.north_east_rounded, size: 18),
            label: const Text('BUY ON AMAZON'),
          ),
          const SizedBox(height: 9),
          const Center(
            child: Text(
              'External purchase linking is activated after Phase 1 approval.',
              textAlign: TextAlign.center,
              style: TextStyle(color: WalkaColors.muted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialProductPanel extends StatelessWidget {
  const _EditorialProductPanel({required this.gray});

  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -35,
            top: -25,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: WalkaColors.gold.withValues(alpha: 0.24),
                  width: 28,
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: _OrganizerRender(
              width: 150,
              gray: gray,
              elevated: true,
              expanded: true,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(22),
            child: SizedBox(
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('EXPANDS WITH YOUR SPACE', style: WalkaType.eyebrow),
                  SizedBox(height: 12),
                  Text(
                    'One organizer. More room to adapt.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.08,
                      fontWeight: FontWeight.w600,
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

class _SpecificationCard extends StatelessWidget {
  const _SpecificationCard();

  @override
  Widget build(BuildContext context) {
    const List<(String, String)> specs = <(String, String)>[
      ('Compartments', '8'),
      ('Closed width', '13 in'),
      ('Expanded width', '22.4 in'),
      ('Depth', '15 in'),
      ('Height', '2 in'),
      ('Base', 'Non-slip'),
      ('Colors', 'White / Gray'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WalkaColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('PRODUCT DETAILS', style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          const Text('Specifications', style: WalkaType.sectionTitle),
          const SizedBox(height: 18),
          for (int i = 0; i < specs.length; i++) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    specs[i].$1,
                    style: const TextStyle(
                      color: WalkaColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  specs[i].$2,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (i != specs.length - 1) ...<Widget>[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _CareNote extends StatelessWidget {
  const _CareNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.auto_awesome_outlined, color: WalkaColors.navy, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'THE WALKA STANDARD',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'A clean, considered organizer designed for repeat everyday use.',
                  style: TextStyle(
                    color: Color(0xFF39495C),
                    fontSize: 12,
                    height: 1.45,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.eyebrow,
    required this.title,
    this.description,
  });

  final String eyebrow;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 8),
        Text(title, style: WalkaType.sectionTitle),
        if (description != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(description!, style: WalkaType.body),
        ],
      ],
    );
  }
}

class _OrganizerRender extends StatelessWidget {
  const _OrganizerRender({
    required this.width,
    required this.gray,
    this.elevated = false,
    this.expanded = false,
  });

  final double width;
  final bool gray;
  final bool elevated;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Color shell = gray
        ? const Color(0xFF969CA3)
        : const Color(0xFFF8F7F2);
    final Color inside = gray
        ? const Color(0xFFAEB3B9)
        : const Color(0xFFFFFFFF);
    final double renderWidth = expanded ? width * 1.12 : width;

    return Transform.rotate(
      angle: elevated ? -0.035 : 0,
      child: Container(
        width: renderWidth,
        height: width * 0.68,
        padding: EdgeInsets.all(width * 0.045),
        decoration: BoxDecoration(
          color: shell,
          borderRadius: BorderRadius.circular(width * 0.09),
          border: Border.all(
            color: gray ? const Color(0xFF7C8289) : const Color(0xFFDDD9CF),
            width: 1.4,
          ),
          boxShadow: elevated
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x2A0F172A),
                    blurRadius: 24,
                    offset: Offset(0, 14),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: expanded ? 3 : 2,
              child: _Compartment(color: inside),
            ),
            SizedBox(width: width * 0.025),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _Compartment(color: inside)),
                  SizedBox(height: width * 0.022),
                  Expanded(child: _Compartment(color: inside)),
                  SizedBox(height: width * 0.022),
                  Expanded(child: _Compartment(color: inside)),
                ],
              ),
            ),
            SizedBox(width: width * 0.025),
            Expanded(
              flex: expanded ? 3 : 2,
              child: _Compartment(color: inside),
            ),
          ],
        ),
      ),
    );
  }
}

class _Compartment extends StatelessWidget {
  const _Compartment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({this.light = false, this.size = 23});

  final bool light;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'WALKA',
      style: TextStyle(
        color: light ? Colors.white : WalkaColors.navy,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: size > 30 ? 8.2 : 5.2,
      ),
    );
  }
}
