import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../lunch/lunch_box_v6.dart';
import 'storefront_catalog_v120.dart';

/// DESIGN-001 premium Home pass.
///
/// This surface keeps API-002 catalog/navigation behavior intact while making
/// the first owner-visible screen product-led rather than icon-led.
class WalkaHomePremiumV121 extends StatelessWidget {
  const WalkaHomePremiumV121({
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
    final WalkaCatalogViewItem drawerHero = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'drawer-organizer:white',
    );
    final WalkaCatalogViewItem lunchHero = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'lunch-box:blue',
    );

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-premium-home-scroll'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _HomeHeader(onSearch: onSearch),
          ),
          if (controller.isLoading || controller.isOffline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _HomeCatalogStatus(controller: controller),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _PremiumHero(
                item: drawerHero,
                onTap: () => openWalkaCatalogItem(context, drawerHero),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 34, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('THE WALKA EDIT', style: WalkaType.eyebrow),
                        SizedBox(height: 8),
                        Text(
                          'Curated for everyday order',
                          style: WalkaType.sectionTitle,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onShopAll,
                    child: const Text('VIEW ALL'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 326,
              child: ListView.separated(
                key: const PageStorageKey<String>('walka-premium-home-products'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final WalkaCatalogViewItem item = items[index];
                  return _PremiumProductCard(
                    item: item,
                    onTap: () => openWalkaCatalogItem(context, item),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
              child: _LunchEditorialFeature(
                item: lunchHero,
                onTap: () => openWalkaCatalogItem(context, lunchHero),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 34, 20, 42),
              child: _HomePromiseCard(
                release: controller.snapshot.config.release,
              ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 14, 6),
      child: Row(
        children: <Widget>[
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'WALKA',
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5.2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'PREMIUM HOME ORGANIZATION',
                style: TextStyle(
                  color: WalkaColors.muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.35,
                ),
              ),
            ],
          ),
          const Spacer(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(color: WalkaColors.line)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onSearch,
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded, color: WalkaColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumHero extends StatelessWidget {
  const _PremiumHero({required this.item, required this.onTap});

  final WalkaCatalogViewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 350;
        return Material(
          color: WalkaColors.navy,
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: compact ? 424 : 430,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: -70,
                    top: -74,
                    child: Container(
                      width: 225,
                      height: 225,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: WalkaColors.gold.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    right: compact ? -42 : -30,
                    bottom: compact ? 48 : 42,
                    width: compact ? 210 : 250,
                    height: compact ? 145 : 172,
                    child: WalkaProductVisual(
                      key: const ValueKey<String>('home-hero-drawer-visual'),
                      kind: WalkaProductVisualKind.drawerOrganizer,
                      primaryColor: const Color(0xFFF7F4EC),
                      backgroundColor: const Color(0xFFF3E8C3),
                      compact: compact,
                      semanticLabel: 'WALKA White Drawer Organizer hero product',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 21 : 24,
                      compact ? 24 : 28,
                      compact ? 20 : 24,
                      22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'THE DRAWER EDIT',
                          style: TextStyle(
                            color: WalkaColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: compact ? 225 : 270,
                          child: Text(
                            'A place for everything.',
                            style: TextStyle(
                              fontFamily: 'serif',
                              color: Colors.white,
                              fontSize: compact ? 35 : 41,
                              height: 1.01,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        SizedBox(
                          width: compact ? 230 : 275,
                          child: const Text(
                            'Expandable organization with a calm profile, eight compartments and a non-slip base.',
                            style: TextStyle(
                              color: Color(0xFFC5D1DC),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.14),
                                ),
                              ),
                              child: Text(
                                item.variant.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'EXPLORE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(width: 7),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: WalkaColors.gold,
                                ),
                              ],
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
        );
      },
    );
  }
}

class _PremiumProductCard extends StatelessWidget {
  const _PremiumProductCard({required this.item, required this.onTap});

  final WalkaCatalogViewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: WalkaColors.line),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    decoration: BoxDecoration(
                      color: item.tone,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(23),
                      ),
                    ),
                    child: WalkaProductVisual(
                      key: ValueKey<String>('home-product-${item.variantId}'),
                      kind: _visualKind(item),
                      primaryColor: _productColor(item),
                      backgroundColor: item.tone,
                      compact: true,
                      semanticLabel: '${item.title} ${item.variant}',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.family == WalkaCatalogFamily.drawer
                            ? 'DRAWER ORGANIZATION'
                            : 'LUNCH COLLECTION',
                        style: const TextStyle(
                          color: WalkaColors.muted,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _productColor(item),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: WalkaColors.navy.withValues(alpha: 0.10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              item.variant.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: WalkaColors.gold,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: WalkaColors.navy,
                            size: 17,
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

class _LunchEditorialFeature extends StatelessWidget {
  const _LunchEditorialFeature({required this.item, required this.onTap});

  final WalkaCatalogViewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF0F5),
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 370,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('LUNCH, REFINED', style: WalkaType.eyebrow),
                const SizedBox(height: 8),
                const SizedBox(
                  width: 285,
                  child: Text(
                    'A complete lunch system in one calm silhouette.',
                    style: WalkaType.sectionTitle,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1200 ml · SUS304 tray · 4 compartments',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: WalkaProductVisual(
                          key: const ValueKey<String>('home-lunch-editorial-visual'),
                          kind: WalkaProductVisualKind.lunchBox,
                          primaryColor: WalkaLunchVariant.blue.color,
                          backgroundColor: const Color(0xFFEAF0F5),
                          semanticLabel: 'WALKA Blue Lunch Box editorial product',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          ...WalkaLunchVariant.values.map(
                            (WalkaLunchVariant variant) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: variant.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: WalkaColors.navy.withValues(alpha: 0.10),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      item.variant.toUpperCase(),
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'DISCOVER',
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: WalkaColors.gold,
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

class _HomePromiseCard extends StatelessWidget {
  const _HomePromiseCard({required this.release});

  final String release;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9CF),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: WalkaColors.gold.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('THE WALKA APPROACH', style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          const Text(
            'Useful first. Calm by design.',
            style: WalkaType.sectionTitle,
          ),
          const SizedBox(height: 10),
          const Text(
            'Discover the WALKA collection here, then complete your purchase through the official Amazon listing.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 2,
                color: WalkaColors.gold,
              ),
              const SizedBox(width: 10),
              Text(
                'CATALOG $release',
                style: const TextStyle(
                  color: WalkaColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeCatalogStatus extends StatelessWidget {
  const _HomeCatalogStatus({required this.controller});

  final WalkaCatalogController controller;

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;
    if (controller.isLoading) {
      label = 'Updating WALKA catalog…';
      icon = Icons.sync_rounded;
    } else if (controller.snapshot.source == WalkaCatalogSource.cache) {
      label = 'Offline · showing the last saved WALKA catalog';
      icon = Icons.cloud_off_outlined;
    } else {
      label = 'Offline · showing the built-in WALKA catalog';
      icon = Icons.inventory_2_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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

WalkaProductVisualKind _visualKind(WalkaCatalogViewItem item) {
  return item.family == WalkaCatalogFamily.drawer
      ? WalkaProductVisualKind.drawerOrganizer
      : WalkaProductVisualKind.lunchBox;
}

Color _productColor(WalkaCatalogViewItem item) {
  if (item.family == WalkaCatalogFamily.drawer) {
    return item.gray ? const Color(0xFFD3D7D9) : const Color(0xFFF7F4EC);
  }
  return item.lunchVariant?.color ?? WalkaColors.navy;
}
