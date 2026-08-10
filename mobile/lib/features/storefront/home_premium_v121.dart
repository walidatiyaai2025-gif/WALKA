import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../lunch/lunch_box_v6.dart';
import 'storefront_catalog_v120.dart';

/// DESIGN-007B.1 Android-reference Home fidelity pass.
///
/// The composition follows the owner-approved `Images/Home for Android.png`
/// hierarchy while preserving catalog-driven navigation and verified Product
/// Master / Amazon boundaries. Unsupported social-proof or leakproof claims are
/// intentionally not reproduced from visual reference art.
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
            child: _ReferenceHeader(
              onBrowse: onShopAll,
              onSearch: onSearch,
            ),
          ),
          if (controller.isLoading || controller.isOffline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _HomeCatalogStatus(controller: controller),
              ),
            ),
          SliverToBoxAdapter(
            child: _ReferenceHero(
              lunchItem: lunchHero,
              drawerItem: drawerHero,
              onOpenLunch: () => openWalkaCatalogItem(context, lunchHero),
              onShopAll: onShopAll,
              onSearch: onSearch,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _BenefitBand(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: _CollectionSection(
                lunchItem: lunchHero,
                drawerItem: drawerHero,
                onLunch: () => openWalkaCatalogItem(context, lunchHero),
                onDrawer: () => openWalkaCatalogItem(context, drawerHero),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: _SmallChangesBanner(
                drawerItem: drawerHero,
                onTap: () => openWalkaCatalogItem(context, drawerHero),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 42),
              child: _VerifiedTrustStrip(
                itemCount: items.length,
                release: controller.snapshot.config.release,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceHeader extends StatelessWidget {
  const _ReferenceHeader({required this.onBrowse, required this.onSearch});

  final VoidCallback onBrowse;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: WalkaColors.line, width: 0.7)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const ValueKey<String>('home-reference-browse'),
            onPressed: onBrowse,
            tooltip: 'Browse categories',
            icon: const Icon(Icons.menu_rounded, color: WalkaColors.navy),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'WALKA',
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey<String>('home-reference-search'),
            onPressed: onSearch,
            tooltip: 'Search WALKA',
            icon: const Icon(Icons.search_rounded, color: WalkaColors.navy),
          ),
        ],
      ),
    );
  }
}

class _ReferenceHero extends StatelessWidget {
  const _ReferenceHero({
    required this.lunchItem,
    required this.drawerItem,
    required this.onOpenLunch,
    required this.onShopAll,
    required this.onSearch,
  });

  final WalkaCatalogViewItem lunchItem;
  final WalkaCatalogViewItem drawerItem;
  final VoidCallback onOpenLunch;
  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 360;
        return Material(
          color: const Color(0xFFFFFCF7),
          child: InkWell(
            onTap: onOpenLunch,
            child: Container(
              key: const ValueKey<String>('home-reference-hero'),
              constraints: BoxConstraints(minHeight: compact ? 500 : 470),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFFFFEFC),
                    Color(0xFFF8F4EC),
                    Color(0xFFFFFFFF),
                  ],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: compact ? -52 : -28,
                    top: compact ? 92 : 46,
                    child: Container(
                      width: compact ? 250 : 290,
                      height: compact ? 250 : 290,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    right: compact ? -28 : -10,
                    top: compact ? 120 : 72,
                    width: compact ? 190 : 230,
                    height: compact ? 150 : 175,
                    child: WalkaProductVisual(
                      key: const ValueKey<String>('home-hero-lunch-visual'),
                      kind: WalkaProductVisualKind.lunchBox,
                      primaryColor: WalkaLunchVariant.green.color,
                      backgroundColor: const Color(0xFFF6F2E8),
                      compact: compact,
                      semanticLabel: 'WALKA Lunch Box hero product',
                    ),
                  ),
                  Positioned(
                    right: compact ? 6 : 26,
                    bottom: compact ? 78 : 60,
                    width: compact ? 158 : 190,
                    height: compact ? 118 : 136,
                    child: WalkaProductVisual(
                      key: const ValueKey<String>('home-hero-drawer-visual'),
                      kind: WalkaProductVisualKind.drawerOrganizer,
                      primaryColor: const Color(0xFFF7F4EC),
                      backgroundColor: const Color(0xFFF2E6C9),
                      compact: true,
                      semanticLabel: 'WALKA White Drawer Organizer hero product',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 18 : 22,
                      compact ? 28 : 32,
                      compact ? 18 : 22,
                      compact ? 22 : 26,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'PREMIUM ORGANIZATION\nELEVATED EVERYDAY.',
                          style: TextStyle(
                            color: WalkaColors.gold,
                            fontSize: 10,
                            height: 1.45,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: compact ? 198 : 230,
                          child: Text(
                            'Organize Better.\nLive Better.',
                            style: TextStyle(
                              color: WalkaColors.navy,
                              fontFamily: 'serif',
                              fontSize: compact ? 35 : 42,
                              height: 0.98,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: compact ? 188 : 224,
                          child: const Text(
                            'Premium drawer organizers and stainless steel lunch boxes designed for calm, everyday order.',
                            style: TextStyle(
                              color: Color(0xFF59616A),
                              fontSize: 12.5,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: compact ? 192 : 220,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ElevatedButton.icon(
                                key: const ValueKey<String>('home-reference-shop'),
                                onPressed: onShopAll,
                                iconAlignment: IconAlignment.end,
                                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                label: const Text('SHOP PRODUCTS'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                key: const ValueKey<String>('home-reference-search-cta'),
                                onPressed: onSearch,
                                child: const Text('SEARCH COLLECTION'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            _HeroDot(active: true),
                            const SizedBox(width: 8),
                            const _HeroDot(),
                            const SizedBox(width: 8),
                            const _HeroDot(),
                            const SizedBox(width: 8),
                            const _HeroDot(),
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

class _HeroDot extends StatelessWidget {
  const _HeroDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? WalkaColors.navy : const Color(0xFFD6D6D6),
      ),
    );
  }
}

class _BenefitBand extends StatelessWidget {
  const _BenefitBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('home-reference-benefits'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WalkaColors.navy.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 350;
          final List<_BenefitData> benefits = <_BenefitData>[
            const _BenefitData(
              icon: Icons.verified_outlined,
              title: 'Premium Quality',
              subtitle: 'Thoughtful materials and construction.',
            ),
            const _BenefitData(
              icon: Icons.eco_outlined,
              title: 'BPA Free',
              subtitle: 'Food-contact materials made for daily use.',
            ),
            const _BenefitData(
              icon: Icons.cleaning_services_outlined,
              title: 'Easy to Care For',
              subtitle: 'Clear product-specific care guidance.',
            ),
            const _BenefitData(
              icon: Icons.lock_outline_rounded,
              title: 'Secure Lock',
              subtitle: 'Helps prevent spills. Carry upright.',
            ),
          ];

          if (compact) {
            return Wrap(
              spacing: 8,
              runSpacing: 14,
              children: benefits
                  .map(
                    (_BenefitData benefit) => SizedBox(
                      width: (constraints.maxWidth - 8) / 2,
                      child: _BenefitTile(data: benefit),
                    ),
                  )
                  .toList(growable: false),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: benefits
                .map(
                  (_BenefitData benefit) => Expanded(
                    child: _BenefitTile(data: benefit),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _BenefitData {
  const _BenefitData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.data});

  final _BenefitData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(data.icon, color: WalkaColors.gold, size: 25),
          const SizedBox(height: 8),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD2DDE7),
              fontSize: 8.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  const _CollectionSection({
    required this.lunchItem,
    required this.drawerItem,
    required this.onLunch,
    required this.onDrawer,
  });

  final WalkaCatalogViewItem lunchItem;
  final WalkaCatalogViewItem drawerItem;
  final VoidCallback onLunch;
  final VoidCallback onDrawer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'OUR COLLECTION',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: WalkaColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Everything in Its Place',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: WalkaColors.navy,
            fontFamily: 'serif',
            fontSize: 27,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView(
            key: const PageStorageKey<String>('home-reference-collection'),
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _ReferenceCollectionCard(
                key: const ValueKey<String>('home-reference-lunch-card'),
                item: lunchItem,
                title: 'Stainless Steel\nLunch Boxes',
                subtitle: '1200 ml · SUS304 tray · 4 compartments.',
                kind: WalkaProductVisualKind.lunchBox,
                primaryColor: WalkaLunchVariant.blue.color,
                visualBackground: const Color(0xFFEAF0F5),
                onTap: onLunch,
              ),
              const SizedBox(width: 12),
              _ReferenceCollectionCard(
                key: const ValueKey<String>('home-reference-drawer-card'),
                item: drawerItem,
                title: 'Drawer Organizers',
                subtitle: '8 compartments · expands from 13 to 22.4 in.',
                kind: WalkaProductVisualKind.drawerOrganizer,
                primaryColor: const Color(0xFFF7F4EC),
                visualBackground: const Color(0xFFF0E2C7),
                onTap: onDrawer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferenceCollectionCard extends StatelessWidget {
  const _ReferenceCollectionCard({
    required this.item,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.primaryColor,
    required this.visualBackground,
    required this.onTap,
    super.key,
  });

  final WalkaCatalogViewItem item;
  final String title;
  final String subtitle;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color visualBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 238,
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
                SizedBox(
                  height: 174,
                  width: double.infinity,
                  child: ColoredBox(
                    color: visualBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: WalkaProductVisual(
                        kind: kind,
                        primaryColor: primaryColor,
                        backgroundColor: visualBackground,
                        compact: true,
                        semanticLabel: '${item.title} ${item.variant}',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 13, 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: WalkaColors.navy,
                                  fontSize: 15,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: WalkaColors.muted,
                                  fontSize: 10.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: WalkaColors.gold,
                          size: 28,
                        ),
                      ],
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

class _SmallChangesBanner extends StatelessWidget {
  const _SmallChangesBanner({required this.drawerItem, required this.onTap});

  final WalkaCatalogViewItem drawerItem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F2E7),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 150,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: WalkaColors.gold,
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Small Changes,\nBetter Living',
                              style: TextStyle(
                                color: WalkaColors.navy,
                                fontSize: 17,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Simple solutions that bring order, beauty and peace of mind.',
                        style: TextStyle(
                          color: WalkaColors.muted,
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: ColoredBox(
                  color: const Color(0xFFEDE6DA),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: WalkaProductVisual(
                      kind: WalkaProductVisualKind.drawerOrganizer,
                      primaryColor: const Color(0xFFF7F4EC),
                      backgroundColor: const Color(0xFFEDE6DA),
                      compact: true,
                      semanticLabel:
                          '${drawerItem.title} ${drawerItem.variant} lifestyle visual',
                    ),
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

class _VerifiedTrustStrip extends StatelessWidget {
  const _VerifiedTrustStrip({required this.itemCount, required this.release});

  final int itemCount;
  final String release;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('home-reference-trust-strip'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WalkaColors.navy.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 330;
          final List<_TrustData> data = <_TrustData>[
            _TrustData(
              icon: Icons.inventory_2_outlined,
              label: '$itemCount variants',
              detail: 'Current WALKA catalog',
            ),
            const _TrustData(
              icon: Icons.open_in_new_rounded,
              label: 'Official Amazon',
              detail: 'Purchase handoff',
            ),
            _TrustData(
              icon: Icons.verified_user_outlined,
              label: 'Catalog $release',
              detail: 'Verified product facts',
            ),
          ];

          if (compact) {
            return Column(
              children: data
                  .map(
                    (_TrustData item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _TrustTile(data: item),
                    ),
                  )
                  .toList(growable: false),
            );
          }

          return Row(
            children: data
                .map(
                  (_TrustData item) => Expanded(
                    child: _TrustTile(data: item),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _TrustData {
  const _TrustData({required this.icon, required this.label, required this.detail});

  final IconData icon;
  final String label;
  final String detail;
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.data});

  final _TrustData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: WalkaColors.gold.withValues(alpha: 0.14),
          ),
          child: Icon(data.icon, color: WalkaColors.gold, size: 18),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: WalkaColors.muted,
                  fontSize: 8.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
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
