import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_reference_ui.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../lunch/lunch_box_v6.dart';
import 'storefront_catalog_v120.dart';

/// DESIGN-007 responsive refinement of the approved Android-reference Home.
///
/// V122 keeps the released Home hierarchy and catalog routing while removing
/// fixed-height content areas that could overflow when deeper sections were
/// lazily laid out on compact/large phones or at 1.3x text scale.
class WalkaHomePremiumV122 extends StatelessWidget {
  const WalkaHomePremiumV122({
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
    final WalkaCatalogViewItem drawer = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'drawer-organizer:white',
    );
    final WalkaCatalogViewItem lunch = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'lunch-box:blue',
    );
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return WalkaReferenceViewport(
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-premium-home-scroll'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: WalkaReferenceHeader(
              headerKey: const ValueKey<String>('home-reference-header'),
              leadingIcon: Icons.menu_rounded,
              leadingTooltip: 'Browse categories',
              leadingKey: const ValueKey<String>('home-reference-browse'),
              onLeading: onShopAll,
              trailingIcon: Icons.search_rounded,
              trailingTooltip: 'Search WALKA',
              trailingKey: const ValueKey<String>('home-reference-search'),
              onTrailing: onSearch,
            ),
          ),
          SliverToBoxAdapter(
            child: _ResponsiveHomeHero(
              lunchItem: lunch,
              drawerItem: drawer,
              onOpenLunch: () => openWalkaCatalogItem(context, lunch),
              onShopAll: onShopAll,
              onSearch: onSearch,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
            sliver: const SliverToBoxAdapter(child: _ResponsiveBenefitBand()),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _ResponsiveCollection(
                lunchItem: lunch,
                drawerItem: drawer,
                onLunch: () => openWalkaCatalogItem(context, lunch),
                onDrawer: () => openWalkaCatalogItem(context, drawer),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _ResponsiveLifestyleBanner(
                drawerItem: drawer,
                onTap: () => openWalkaCatalogItem(context, drawer),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 42),
            sliver: SliverToBoxAdapter(
              child: _ResponsiveTrustStrip(
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

class _ResponsiveHomeHero extends StatelessWidget {
  const _ResponsiveHomeHero({
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
        final double scale = MediaQuery.textScalerOf(context).scale(1);
        final bool stackContent = compact || scale > 1.15;

        return Material(
          color: const Color(0xFFFFFCF7),
          child: InkWell(
            onTap: onOpenLunch,
            child: Container(
              key: const ValueKey<String>('home-reference-hero'),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 22,
                compact ? 26 : 30,
                compact ? 18 : 22,
                compact ? 22 : 26,
              ),
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
              child: stackContent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _HeroCopy(
                          compact: compact,
                          onShopAll: onShopAll,
                          onSearch: onSearch,
                        ),
                        const SizedBox(height: 20),
                        _HeroVisualStage(
                          height: compact ? 190 : 210,
                          lunchItem: lunchItem,
                          drawerItem: drawerItem,
                        ),
                        const SizedBox(height: 14),
                        const _HeroDots(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: _HeroCopy(
                            compact: false,
                            onShopAll: onShopAll,
                            onSearch: onSearch,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: <Widget>[
                              _HeroVisualStage(
                                height: 250,
                                lunchItem: lunchItem,
                                drawerItem: drawerItem,
                              ),
                              const SizedBox(height: 12),
                              const _HeroDots(),
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

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.compact,
    required this.onShopAll,
    required this.onSearch,
  });

  final bool compact;
  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Text(
          'Organize Better.\nLive Better.',
          style: TextStyle(
            color: WalkaColors.navy,
            fontFamily: 'serif',
            fontSize: compact ? 35 : 40,
            height: 0.98,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Premium drawer organizers and stainless steel lunch boxes designed for calm, everyday order.',
          style: TextStyle(
            color: Color(0xFF59616A),
            fontSize: 12.5,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 235),
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
      ],
    );
  }
}

class _HeroVisualStage extends StatelessWidget {
  const _HeroVisualStage({
    required this.height,
    required this.lunchItem,
    required this.drawerItem,
  });

  final double height;
  final WalkaCatalogViewItem lunchItem;
  final WalkaCatalogViewItem drawerItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.82,
                heightFactor: 0.92,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WalkaColors.gold.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: 190,
            height: height * 0.70,
            child: WalkaProductVisual(
              key: const ValueKey<String>('home-hero-lunch-visual'),
              kind: WalkaProductVisualKind.lunchBox,
              primaryColor: WalkaLunchVariant.green.color,
              backgroundColor: const Color(0xFFF6F2E8),
              compact: true,
              semanticLabel: '${lunchItem.title} hero product',
            ),
          ),
          Positioned(
            right: 18,
            bottom: 0,
            width: 150,
            height: height * 0.48,
            child: WalkaProductVisual(
              key: const ValueKey<String>('home-hero-drawer-visual'),
              kind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: const Color(0xFFF7F4EC),
              backgroundColor: const Color(0xFFF2E6C9),
              compact: true,
              semanticLabel: '${drawerItem.title} hero product',
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDots extends StatelessWidget {
  const _HeroDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _HeroDot(active: true),
        SizedBox(width: 8),
        _HeroDot(),
        SizedBox(width: 8),
        _HeroDot(),
        SizedBox(width: 8),
        _HeroDot(),
      ],
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

class _ResponsiveBenefitBand extends StatelessWidget {
  const _ResponsiveBenefitBand();

  @override
  Widget build(BuildContext context) {
    const List<_BenefitData> benefits = <_BenefitData>[
      _BenefitData(
        Icons.verified_outlined,
        'Premium Quality',
        'Thoughtful materials and construction.',
      ),
      _BenefitData(
        Icons.eco_outlined,
        'BPA Free',
        'Food-contact materials made for daily use.',
      ),
      _BenefitData(
        Icons.cleaning_services_outlined,
        'Easy to Care For',
        'Clear product-specific care guidance.',
      ),
      _BenefitData(
        Icons.lock_outline_rounded,
        'Secure Lock',
        'Helps prevent spills. Carry upright.',
      ),
    ];

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
          final bool twoColumns = constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.15;
          final double width = twoColumns
              ? (constraints.maxWidth - 8) / 2
              : (constraints.maxWidth - 12) / 4;
          return Wrap(
            spacing: twoColumns ? 8 : 4,
            runSpacing: 16,
            children: benefits
                .map(
                  (_BenefitData data) => SizedBox(
                    width: width,
                    child: _BenefitTile(data: data),
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
  const _BenefitData(this.icon, this.title, this.subtitle);

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

class _ResponsiveCollection extends StatelessWidget {
  const _ResponsiveCollection({
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
        SingleChildScrollView(
          key: const PageStorageKey<String>('home-reference-collection'),
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ResponsiveCollectionCard(
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
              _ResponsiveCollectionCard(
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

class _ResponsiveCollectionCard extends StatelessWidget {
  const _ResponsiveCollectionCard({
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
    final double scale = MediaQuery.textScalerOf(context).scale(1);
    final double bodyMinHeight = scale > 1.15 ? 138 : 116;

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
              mainAxisSize: MainAxisSize.min,
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
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: bodyMinHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 13, 13, 13),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                maxLines: 3,
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
                                maxLines: 3,
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

class _ResponsiveLifestyleBanner extends StatelessWidget {
  const _ResponsiveLifestyleBanner({
    required this.drawerItem,
    required this.onTap,
  });

  final WalkaCatalogViewItem drawerItem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack = constraints.maxWidth < 350 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.15;
        final Widget copy = Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
        );

        final Widget visual = SizedBox(
          height: stack ? 126 : 164,
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
        );

        return Material(
          color: const Color(0xFFF8F2E7),
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: stack
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[copy, visual],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(flex: 5, child: copy),
                        Expanded(flex: 4, child: visual),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _ResponsiveTrustStrip extends StatelessWidget {
  const _ResponsiveTrustStrip({
    required this.itemCount,
    required this.release,
  });

  final int itemCount;
  final String release;

  @override
  Widget build(BuildContext context) {
    final List<_TrustData> data = <_TrustData>[
      _TrustData(
        Icons.inventory_2_outlined,
        '$itemCount variants',
        'Current WALKA catalog',
      ),
      const _TrustData(
        Icons.open_in_new_rounded,
        'Official Amazon',
        'Purchase handoff',
      ),
      _TrustData(
        Icons.verified_user_outlined,
        'Catalog $release',
        'Verified product facts',
      ),
    ];

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
          final bool singleColumn = constraints.maxWidth < 330 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.15;
          final double width = singleColumn
              ? constraints.maxWidth
              : (constraints.maxWidth - 8) / 3;
          return Wrap(
            spacing: singleColumn ? 0 : 4,
            runSpacing: 12,
            children: data
                .map(
                  (_TrustData item) => SizedBox(
                    width: width,
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
  const _TrustData(this.icon, this.label, this.detail);

  final IconData icon;
  final String label;
  final String detail;
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.data});

  final _TrustData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Row(
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.label,
                  maxLines: 2,
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
      ),
    );
  }
}
