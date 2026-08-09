import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_theme.dart';
import '../favorites/favorites_state.dart';
import '../information/information_v100.dart';
import '../lifestyle/lifestyle_v4.dart' show WalkaAboutV4;
import '../lunch/lunch_box_v6.dart';
import '../products/product_experience_v100.dart';

class WalkaStorefrontSplashV101 extends StatelessWidget {
  const WalkaStorefrontSplashV101({super.key});

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
                const Text(
                  'WALKA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8.2,
                  ),
                ),
                const SizedBox(height: 18),
                Container(width: 54, height: 2, color: WalkaColors.gold),
                const SizedBox(height: 20),
                const Text('PREMIUM HOME ORGANIZATION', style: WalkaType.eyebrow),
                const SizedBox(height: 16),
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
                    'A complete WALKA mobile experience for discovery, product detail, favorites, support and official Amazon purchase handoff.',
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
                        builder: (_) => const WalkaStorefrontShellV101(),
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

class WalkaStorefrontShellV101 extends StatefulWidget {
  const WalkaStorefrontShellV101({super.key});

  @override
  State<WalkaStorefrontShellV101> createState() => _WalkaStorefrontShellV101State();
}

class _WalkaStorefrontShellV101State extends State<WalkaStorefrontShellV101> {
  int _index = 0;

  void _select(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_index == value) return;
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      WalkaHomeV101(onShopAll: () => _select(2), onSearch: () => _select(1)),
      const WalkaSearchV101(),
      const WalkaCategoriesV101(),
      WalkaFavoritesV101(onExplore: () => _select(2)),
      const WalkaAccountV101(),
    ];

    return Scaffold(
      body: WalkaAdaptiveFrame(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: WalkaAdaptiveNavigationFrame(
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search_rounded),
              label: 'Search',
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
      ),
    );
  }
}

class WalkaHomeV101 extends StatelessWidget {
  const WalkaHomeV101({required this.onShopAll, required this.onSearch, super.key});

  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  void _drawer(BuildContext context, {bool gray = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaDrawerProductDetailV100(initialGray: gray),
      ),
    );
  }

  void _lunch(BuildContext context, WalkaLunchVariant variant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaLunchProductDetailV100(initialVariant: variant),
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
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 4),
              child: Row(
                children: <Widget>[
                  const _Wordmark(),
                  const Spacer(),
                  IconButton(
                    onPressed: onSearch,
                    tooltip: 'Search',
                    icon: const Icon(Icons.search_rounded),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _HeroCard(onTap: () => _drawer(context)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('THE WALKA EDIT', style: WalkaType.eyebrow),
                        SizedBox(height: 7),
                        Text('Made for everyday order', style: WalkaType.sectionTitle),
                      ],
                    ),
                  ),
                  TextButton(onPressed: onShopAll, child: const Text('VIEW ALL')),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 310,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  _HomeProductCard(
                    title: 'Expandable Drawer Organizer',
                    variant: 'WHITE',
                    icon: Icons.grid_view_rounded,
                    tone: const Color(0xFFF6F3EC),
                    onTap: () => _drawer(context),
                  ),
                  const SizedBox(width: 12),
                  _HomeProductCard(
                    title: 'Expandable Drawer Organizer',
                    variant: 'GRAY',
                    icon: Icons.grid_view_rounded,
                    tone: const Color(0xFFE1E4E7),
                    onTap: () => _drawer(context, gray: true),
                  ),
                  const SizedBox(width: 12),
                  _HomeProductCard(
                    title: 'Large Stainless Steel Bento Lunch Box',
                    variant: 'BLUE',
                    icon: Icons.lunch_dining_rounded,
                    tone: WalkaLunchVariant.blue.surface,
                    onTap: () => _lunch(context, WalkaLunchVariant.blue),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: _LunchFeature(
                onTap: () => _lunch(context, WalkaLunchVariant.blue),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 42),
              child: _PromiseCard(),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkaCategoriesV101 extends StatelessWidget {
  const WalkaCategoriesV101({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_CatalogItem> items = _finalCatalog;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _Wordmark(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('SHOP WALKA', style: WalkaType.eyebrow),
                  SizedBox(height: 8),
                  Text('Collections', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Five current sellable variants across drawer organization and the lunch collection.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _CatalogCard(
                  item: items[index],
                  onTap: () => _openCatalogItem(context, items[index]),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 42)),
        ],
      ),
    );
  }
}

class WalkaSearchV101 extends StatefulWidget {
  const WalkaSearchV101({super.key});

  @override
  State<WalkaSearchV101> createState() => _WalkaSearchV101State();
}

class _WalkaSearchV101State extends State<WalkaSearchV101> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  _CatalogFamily? _family;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_CatalogItem> get _results {
    final String q = _query.trim().toLowerCase();
    return _finalCatalog.where((_CatalogItem item) {
      if (_family != null && item.family != _family) return false;
      if (q.isEmpty) return true;
      final String haystack = <String>[
        item.title,
        item.variant,
        item.family.name,
        item.searchTerms,
      ].join(' ').toLowerCase();
      return q.split(RegExp(r'\s+')).every(haystack.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<_CatalogItem> results = _results;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
        children: <Widget>[
          const _Wordmark(),
          const SizedBox(height: 24),
          const Text('SEARCH WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          const Text('What are you organizing?', style: WalkaType.sectionTitle),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: (String value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Drawer, lunch box, blue, SUS304…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: WalkaColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: WalkaColors.line),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: const Text('All'),
                selected: _family == null,
                onSelected: (_) => setState(() => _family = null),
              ),
              ChoiceChip(
                label: const Text('Drawer'),
                selected: _family == _CatalogFamily.drawer,
                onSelected: (_) => setState(() => _family = _CatalogFamily.drawer),
              ),
              ChoiceChip(
                label: const Text('Lunch'),
                selected: _family == _CatalogFamily.lunch,
                onSelected: (_) => setState(() => _family = _CatalogFamily.lunch),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              Text(
                '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const Text(
                'LOCAL CATALOG',
                style: TextStyle(
                  color: WalkaColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            const _NoResults()
          else
            ...results.map((_CatalogItem item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SearchResult(
                    item: item,
                    onTap: () => _openCatalogItem(context, item),
                  ),
                )),
        ],
      ),
    );
  }
}

class WalkaFavoritesV101 extends StatelessWidget {
  const WalkaFavoritesV101({required this.onExplore, super.key});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController controller = WalkaFavoritesScope.of(context);
    final List<bool> variants = controller.savedDrawerVariants;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _Wordmark(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('YOUR WALKA EDIT', style: WalkaType.eyebrow),
                  SizedBox(height: 8),
                  Text('Favorites', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Your saved Drawer Organizer variants stay on this device.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          if (variants.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.favorite_border_rounded, size: 54, color: WalkaColors.navy),
                      const SizedBox(height: 18),
                      const Text(
                        'Your edit is ready for something beautiful.',
                        textAlign: TextAlign.center,
                        style: WalkaType.sectionTitle,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: onExplore,
                        child: const Text('EXPLORE COLLECTIONS'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 42),
              sliver: SliverList.separated(
                itemCount: variants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final bool gray = variants[index];
                  return _FavoriteRow(
                    gray: gray,
                    onOpen: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WalkaDrawerProductDetailV100(initialGray: gray),
                        ),
                      );
                    },
                    onRemove: () async {
                      final bool saved = await controller.removeDrawer(gray: gray);
                      if (!context.mounted || saved) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favorite could not be updated.')),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class WalkaAccountV101 extends StatelessWidget {
  const WalkaAccountV101({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
        children: <Widget>[
          const _Wordmark(),
          const SizedBox(height: 24),
          const Text('WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          const Text('Account & information', style: WalkaType.sectionTitle),
          const SizedBox(height: 9),
          const Text(
            'Brand story, product support, legal information and official WALKA destinations.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 24),
          _AccountRow(
            icon: Icons.auto_stories_outlined,
            title: 'Our Story',
            subtitle: 'The thinking behind calmer everyday organization.',
            onTap: () => _push(context, const WalkaAboutV4()),
          ),
          _AccountRow(
            icon: Icons.help_outline_rounded,
            title: 'FAQ',
            subtitle: 'Verified product care, use and purchasing guidance.',
            onTap: () => _push(context, const WalkaFaqV101()),
          ),
          _AccountRow(
            icon: Icons.mail_outline_rounded,
            title: 'Contact Us',
            subtitle: 'Support routes for WALKA and Amazon orders.',
            onTap: () => _push(context, const WalkaContactV100()),
          ),
          _AccountRow(
            icon: Icons.storefront_outlined,
            title: 'Amazon Store',
            subtitle: 'Official WALKA purchase destination.',
            onTap: () => _push(context, const WalkaAmazonStoreV100()),
          ),
          _AccountRow(
            icon: Icons.public_rounded,
            title: 'Follow WALKA',
            subtitle: 'Website and Instagram destinations.',
            onTap: () => _push(context, const WalkaSocialV100()),
          ),
          _AccountRow(
            icon: Icons.shield_outlined,
            title: 'Privacy',
            subtitle: 'Current local-data model and external handoffs.',
            onTap: () => _push(
              context,
              const WalkaLegalV100(type: WalkaLegalType.privacy),
            ),
          ),
          _AccountRow(
            icon: Icons.description_outlined,
            title: 'Terms',
            subtitle: 'Product discovery and marketplace boundaries.',
            onTap: () => _push(
              context,
              const WalkaLegalV100(type: WalkaLegalType.terms),
            ),
          ),
          _AccountRow(
            icon: Icons.info_outline_rounded,
            title: 'App Information',
            subtitle: 'WALKA visual freeze · version 1.0.0',
            onTap: () => _push(context, const WalkaAppInfoV100()),
          ),
        ],
      ),
    );
  }
}

class WalkaFaqV101 extends StatelessWidget {
  const WalkaFaqV101({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _Wordmark()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 42),
        children: const <Widget>[
          Text('HELP', style: WalkaType.eyebrow),
          SizedBox(height: 8),
          Text('Frequently Asked Questions', style: WalkaType.sectionTitle),
          SizedBox(height: 10),
          Text(
            'Answers below follow the verified WALKA product master used by the app.',
            style: WalkaType.body,
          ),
          SizedBox(height: 22),
          _FaqTile(
            question: 'Is the lunch box leakproof?',
            answer:
                'No full leakproof claim is made. Secure Lock helps prevent spills. The lunch box is best for dry & semi-wet foods, is not intended for liquids, and should be carried upright.',
          ),
          _FaqTile(
            question: 'What is the lunch box made from?',
            answer:
                'Food sits in a SUS304 stainless-steel tray. The outer body is BPA-free PP. The lid uses 4 clips with a silicone gasket.',
          ),
          _FaqTile(
            question: 'Can the lunch box go in a microwave?',
            answer:
                'The SUS304 steel tray is not microwave safe. The PP outer body is microwave safe without the stainless-steel tray.',
          ),
          _FaqTile(
            question: 'How should I wash the lunch box?',
            answer:
                'The SUS304 steel tray is dishwasher safe on the top rack. Hand wash the lid and silicone gasket.',
          ),
          _FaqTile(
            question: 'What comes with the lunch box?',
            answer:
                'The set includes the lunch box, insulated carry bag, stainless sauce cup with lid, spoon and fork.',
          ),
          _FaqTile(
            question: 'How wide does the drawer organizer expand?',
            answer:
                'The drawer organizer is 13 × 15 × 2 inches when closed and expands to 22.4 inches wide.',
          ),
          _FaqTile(
            question: 'Where do I purchase WALKA products?',
            answer:
                'Buy on Amazon opens the selected official WALKA listing. The app does not run an in-app cart, checkout or payment flow.',
          ),
        ],
      ),
    );
  }
}

enum _CatalogFamily { drawer, lunch }

class _CatalogItem {
  const _CatalogItem({
    required this.id,
    required this.family,
    required this.title,
    required this.variant,
    required this.tone,
    required this.searchTerms,
    this.gray = false,
    this.lunchVariant,
  });

  final String id;
  final _CatalogFamily family;
  final String title;
  final String variant;
  final Color tone;
  final String searchTerms;
  final bool gray;
  final WalkaLunchVariant? lunchVariant;
}

const List<_CatalogItem> _finalCatalog = <_CatalogItem>[
  _CatalogItem(
    id: 'drawer-white',
    family: _CatalogFamily.drawer,
    title: 'Expandable Drawer Organizer',
    variant: 'White',
    tone: Color(0xFFF6F3EC),
    searchTerms: 'drawer organizer kitchen cutlery utensils expandable white 8 compartments non slip',
  ),
  _CatalogItem(
    id: 'drawer-gray',
    family: _CatalogFamily.drawer,
    title: 'Expandable Drawer Organizer',
    variant: 'Gray',
    tone: Color(0xFFE1E4E7),
    searchTerms: 'drawer organizer kitchen cutlery utensils expandable gray grey 8 compartments non slip',
    gray: true,
  ),
  _CatalogItem(
    id: 'lunch-blue',
    family: _CatalogFamily.lunch,
    title: 'Large Stainless Steel Bento Lunch Box',
    variant: 'Blue',
    tone: Color(0xFFE3EBEF),
    searchTerms: 'lunch box bento sus304 stainless steel bpa free pp 1200 ml 4 compartments blue',
    lunchVariant: WalkaLunchVariant.blue,
  ),
  _CatalogItem(
    id: 'lunch-pink',
    family: _CatalogFamily.lunch,
    title: 'Large Stainless Steel Bento Lunch Box',
    variant: 'Pink',
    tone: Color(0xFFF8E9EC),
    searchTerms: 'lunch box bento sus304 stainless steel bpa free pp 1200 ml 4 compartments pink',
    lunchVariant: WalkaLunchVariant.pink,
  ),
  _CatalogItem(
    id: 'lunch-green',
    family: _CatalogFamily.lunch,
    title: 'Large Stainless Steel Bento Lunch Box',
    variant: 'Green',
    tone: Color(0xFFEEF2EA),
    searchTerms: 'lunch box bento sus304 stainless steel bpa free pp 1200 ml 4 compartments green',
    lunchVariant: WalkaLunchVariant.green,
  ),
];

void _openCatalogItem(BuildContext context, _CatalogItem item) {
  if (item.family == _CatalogFamily.drawer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaDrawerProductDetailV100(initialGray: item.gray),
      ),
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => WalkaLunchProductDetailV100(
        initialVariant: item.lunchVariant ?? WalkaLunchVariant.blue,
      ),
    ),
  );
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WALKA',
      style: TextStyle(
        color: WalkaColors.navy,
        fontSize: 21,
        fontWeight: FontWeight.w900,
        letterSpacing: 4.8,
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.navy,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 420,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -40,
                bottom: 24,
                child: Container(
                  width: 250,
                  height: 170,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EEE5),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.grid_view_rounded, size: 88, color: WalkaColors.navy),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('PREMIUM HOME ORGANIZATION', style: WalkaType.eyebrow),
                    SizedBox(height: 13),
                    SizedBox(
                      width: 270,
                      child: Text(
                        'Order, without the noise.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: Colors.white,
                          fontSize: 40,
                          height: 1.02,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: 260,
                      child: Text(
                        'Thoughtful everyday organization in a calm, refined WALKA language.',
                        style: TextStyle(color: Color(0xFFC8D4DF), fontSize: 13, height: 1.5),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'DISCOVER THE DRAWER EDIT  →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  const _HomeProductCard({
    required this.title,
    required this.variant,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final String title;
  final String variant;
  final IconData icon;
  final Color tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 215,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: WalkaColors.line),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: tone,
                    child: Icon(icon, color: WalkaColors.navy, size: 78),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        variant,
                        style: const TextStyle(
                          color: WalkaColors.gold,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
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

class _LunchFeature extends StatelessWidget {
  const _LunchFeature({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE7EEF4),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('LUNCH COLLECTION', style: WalkaType.eyebrow),
                const SizedBox(height: 9),
                const SizedBox(
                  width: 250,
                  child: Text('A complete lunch system, refined.', style: WalkaType.sectionTitle),
                ),
                const SizedBox(height: 10),
                const Text(
                  '1200 ml · SUS304 tray · insulated bag · 3 colors',
                  style: WalkaType.body,
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    ...WalkaLunchVariant.values.map((WalkaLunchVariant variant) => Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: variant.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        )),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_rounded, color: WalkaColors.navy),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromiseCard extends StatelessWidget {
  const _PromiseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('THE WALKA APPROACH', style: WalkaType.eyebrow),
          SizedBox(height: 8),
          Text('Useful first. Calm by design.', style: WalkaType.sectionTitle),
          SizedBox(height: 10),
          Text(
            'The app keeps discovery focused while Amazon handles marketplace checkout, delivery, returns and payments.',
            style: WalkaType.body,
          ),
        ],
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item, required this.onTap});

  final _CatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: item.tone,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                  ),
                  child: Icon(
                    item.family == _CatalogFamily.drawer
                        ? Icons.grid_view_rounded
                        : Icons.lunch_dining_rounded,
                    color: WalkaColors.navy,
                    size: 58,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.variant.toUpperCase(),
                      style: const TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  const _SearchResult({required this.item, required this.onTap});

  final _CatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: item.tone,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.family == _CatalogFamily.drawer
                      ? Icons.grid_view_rounded
                      : Icons.lunch_dining_rounded,
                  color: WalkaColors.navy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.variant,
                      style: const TextStyle(color: WalkaColors.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: WalkaColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: WalkaColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: <Widget>[
          Icon(Icons.search_off_rounded, color: WalkaColors.navy, size: 42),
          SizedBox(height: 14),
          Text('Nothing matched that search', style: WalkaType.sectionTitle, textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text('Try a color, Drawer Organizer, Lunch Box or SUS304.', style: WalkaType.body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({required this.gray, required this.onOpen, required this.onRemove});

  final bool gray;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: gray ? const Color(0xFFE1E4E7) : const Color(0xFFF6F3EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.grid_view_rounded, color: WalkaColors.navy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Expandable Drawer Organizer',
                      style: TextStyle(color: WalkaColors.navy, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(gray ? 'Gray' : 'White', style: const TextStyle(color: WalkaColors.muted)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: 'Remove favorite',
                icon: const Icon(Icons.favorite_rounded, color: WalkaColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: WalkaColors.line),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: WalkaColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: WalkaColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: WalkaColors.muted,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: WalkaColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          question,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: WalkaType.body),
          ),
        ],
      ),
    );
  }
}
