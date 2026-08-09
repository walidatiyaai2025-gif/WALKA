import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../lunch/lunch_box_v6.dart';
import '../products/product_experience_v100.dart';

class WalkaHomeV120 extends StatelessWidget {
  const WalkaHomeV120({
    required this.onShopAll,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(
      controller.snapshot,
    );
    final WalkaCatalogViewItem hero = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'drawer-organizer:white',
    );
    final WalkaCatalogViewItem lunch = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'lunch-box:blue',
    );

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
          if (controller.isLoading || controller.isOffline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: _CatalogStatus(controller: controller),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _HeroCard(
                onTap: () => openWalkaCatalogItem(context, hero),
              ),
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
                        Text(
                          'Made for everyday order',
                          style: WalkaType.sectionTitle,
                        ),
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final WalkaCatalogViewItem item = items[index];
                  return _HomeProductCard(
                    item: item,
                    onTap: () => openWalkaCatalogItem(context, item),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: _LunchFeature(
                lunch: lunch,
                onTap: () => openWalkaCatalogItem(context, lunch),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 42),
              child: _PromiseCard(release: controller.snapshot.config.release),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkaCategoriesV120 extends StatelessWidget {
  const WalkaCategoriesV120({super.key});

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(
      controller.snapshot,
    );

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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('SHOP WALKA', style: WalkaType.eyebrow),
                  const SizedBox(height: 8),
                  const Text('Collections', style: WalkaType.sectionTitle),
                  const SizedBox(height: 9),
                  Text(
                    '${items.length} current sellable variants across drawer organization and the lunch collection.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          if (controller.isLoading || controller.isOffline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _CatalogStatus(controller: controller),
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
                final WalkaCatalogViewItem item = items[index];
                return _CatalogCard(
                  item: item,
                  onTap: () => openWalkaCatalogItem(context, item),
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

class WalkaSearchV120 extends StatefulWidget {
  const WalkaSearchV120({super.key});

  @override
  State<WalkaSearchV120> createState() => _WalkaSearchV120State();
}

class _WalkaSearchV120State extends State<WalkaSearchV120> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  WalkaCatalogFamily? _family;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController catalog = WalkaCatalogScope.of(context);
    final String query = _query.trim().toLowerCase();
    final List<WalkaCatalogViewItem> results = walkaCatalogViewItems(
      catalog.snapshot,
    ).where((WalkaCatalogViewItem item) {
      if (_family != null && item.family != _family) return false;
      if (query.isEmpty) return true;
      final String haystack = <String>[
        item.title,
        item.variant,
        item.family.name,
        item.searchTerms,
      ].join(' ').toLowerCase();
      return query.split(RegExp(r'\s+')).every(haystack.contains);
    }).toList(growable: false);

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
                selected: _family == WalkaCatalogFamily.drawer,
                onSelected: (_) => setState(
                  () => _family = WalkaCatalogFamily.drawer,
                ),
              ),
              ChoiceChip(
                label: const Text('Lunch'),
                selected: _family == WalkaCatalogFamily.lunch,
                onSelected: (_) => setState(
                  () => _family = WalkaCatalogFamily.lunch,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (catalog.isLoading || catalog.isOffline)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CatalogStatus(controller: catalog),
            ),
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
              Text(
                catalog.snapshot.source == WalkaCatalogSource.remote
                    ? 'REMOTE CATALOG'
                    : 'RESILIENT CATALOG',
                style: const TextStyle(
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
            ...results.map(
              (WalkaCatalogViewItem item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SearchResult(
                  item: item,
                  onTap: () => openWalkaCatalogItem(context, item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum WalkaCatalogFamily { drawer, lunch }

class WalkaCatalogViewItem {
  const WalkaCatalogViewItem({
    required this.productId,
    required this.variantId,
    required this.title,
    required this.variant,
    required this.family,
    required this.tone,
    required this.searchTerms,
    this.gray = false,
    this.lunchVariant,
  });

  final String productId;
  final String variantId;
  final String title;
  final String variant;
  final WalkaCatalogFamily family;
  final Color tone;
  final String searchTerms;
  final bool gray;
  final WalkaLunchVariant? lunchVariant;
}

List<WalkaCatalogViewItem> walkaCatalogViewItems(WalkaCatalogSnapshot snapshot) {
  final List<WalkaCatalogViewItem> items = <WalkaCatalogViewItem>[];
  for (final WalkaCatalogProduct product in snapshot.products) {
    for (final WalkaCatalogVariant variant in product.variants) {
      final bool drawer = product.id == 'drawer-organizer';
      items.add(
        WalkaCatalogViewItem(
          productId: product.id,
          variantId: variant.id,
          title: product.name,
          variant: variant.color,
          family: drawer ? WalkaCatalogFamily.drawer : WalkaCatalogFamily.lunch,
          tone: _toneForVariant(variant.id),
          searchTerms: <String>[
            product.name,
            product.category,
            variant.color,
            variant.pantone ?? '',
            product.features.join(' '),
            product.facts.values.join(' '),
          ].join(' '),
          gray: variant.id == 'drawer-organizer:gray',
          lunchVariant: _lunchVariantForId(variant.id),
        ),
      );
    }
  }
  return List<WalkaCatalogViewItem>.unmodifiable(items);
}

void openWalkaCatalogItem(BuildContext context, WalkaCatalogViewItem item) {
  if (item.family == WalkaCatalogFamily.drawer) {
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

WalkaLunchVariant? _lunchVariantForId(String id) {
  return switch (id) {
    'lunch-box:blue' => WalkaLunchVariant.blue,
    'lunch-box:pink' => WalkaLunchVariant.pink,
    'lunch-box:green' => WalkaLunchVariant.green,
    _ => null,
  };
}

Color _toneForVariant(String id) {
  return switch (id) {
    'drawer-organizer:white' => const Color(0xFFF6F3EC),
    'drawer-organizer:gray' => const Color(0xFFE1E4E7),
    'lunch-box:blue' => WalkaLunchVariant.blue.surface,
    'lunch-box:pink' => WalkaLunchVariant.pink.surface,
    'lunch-box:green' => WalkaLunchVariant.green.surface,
    _ => WalkaColors.surface,
  };
}

class _CatalogStatus extends StatelessWidget {
  const _CatalogStatus({required this.controller});

  final WalkaCatalogController controller;

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;
    if (controller.isLoading) {
      label = 'Updating WALKA catalog…';
      icon = Icons.sync_rounded;
    } else if (controller.isUsingCache) {
      label = 'Offline · showing last saved catalog';
      icon = Icons.cloud_off_outlined;
    } else {
      label = 'Offline · showing built-in WALKA catalog';
      icon = Icons.inventory_2_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: WalkaColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: WalkaColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
                  child: const Icon(
                    Icons.grid_view_rounded,
                    size: 88,
                    color: WalkaColors.navy,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'PREMIUM HOME ORGANIZATION',
                      style: WalkaType.eyebrow,
                    ),
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
                        style: TextStyle(
                          color: Color(0xFFC8D4DF),
                          fontSize: 13,
                          height: 1.5,
                        ),
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
  const _HomeProductCard({required this.item, required this.onTap});

  final WalkaCatalogViewItem item;
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
                    color: item.tone,
                    child: Icon(
                      item.family == WalkaCatalogFamily.drawer
                          ? Icons.grid_view_rounded
                          : Icons.lunch_dining_rounded,
                      color: WalkaColors.navy,
                      size: 78,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
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
      ),
    );
  }
}

class _LunchFeature extends StatelessWidget {
  const _LunchFeature({required this.lunch, required this.onTap});

  final WalkaCatalogViewItem lunch;
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
                  child: Text(
                    'A complete lunch system, refined.',
                    style: WalkaType.sectionTitle,
                  ),
                ),
                const SizedBox(height: 10),
                Text(lunch.searchTerms.split(' ').take(12).join(' '), style: WalkaType.body),
                const Spacer(),
                Row(
                  children: <Widget>[
                    ...WalkaLunchVariant.values.map(
                      (WalkaLunchVariant variant) => Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: variant.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: WalkaColors.navy,
                    ),
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
  const _PromiseCard({required this.release});

  final String release;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('THE WALKA APPROACH', style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          const Text('Useful first. Calm by design.', style: WalkaType.sectionTitle),
          const SizedBox(height: 10),
          const Text(
            'Discovery stays focused while Amazon handles marketplace checkout, delivery, returns and payments.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 12),
          Text(
            'CATALOG RELEASE $release',
            style: const TextStyle(
              color: WalkaColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item, required this.onTap});

  final WalkaCatalogViewItem item;
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19),
                    ),
                  ),
                  child: Icon(
                    item.family == WalkaCatalogFamily.drawer
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

  final WalkaCatalogViewItem item;
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
                  item.family == WalkaCatalogFamily.drawer
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.variant,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 11,
                      ),
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
          Text(
            'Nothing matched that search',
            style: WalkaType.sectionTitle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Try a color, Drawer Organizer, Lunch Box or SUS304.',
            style: WalkaType.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
