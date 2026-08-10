import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import '../lunch/lunch_box_v6.dart';
import 'storefront_catalog_v120.dart';

/// DESIGN-007B.2 Android-reference Categories fidelity.
///
/// The visual hierarchy follows the approved Android Categories reference while
/// using only the released WALKA catalog. Reference-only categories/counts such
/// as Accessories, Sale, 12 Products and 8 Products are intentionally omitted.
class WalkaCategoriesPremiumV123 extends StatelessWidget {
  const WalkaCategoriesPremiumV123({this.onSearch, super.key});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(
      controller.snapshot,
    );
    final List<WalkaCatalogViewItem> lunch = items
        .where((WalkaCatalogViewItem item) => item.family == WalkaCatalogFamily.lunch)
        .toList(growable: false);
    final List<WalkaCatalogViewItem> drawer = items
        .where((WalkaCatalogViewItem item) => item.family == WalkaCatalogFamily.drawer)
        .toList(growable: false);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-reference-categories-scroll'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _ReferenceDiscoveryHeader(
              trailingIcon: Icons.search_rounded,
              trailingTooltip: 'Search WALKA',
              onTrailing: onSearch,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 42),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                const Text(
                  'Categories',
                  key: ValueKey<String>('reference-categories-title'),
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 34,
                    height: 1.04,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore our premium organization solutions.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (controller.isLoading || controller.isOffline) ...<Widget>[
                  const SizedBox(height: 14),
                  _ReferenceCatalogStatus(controller: controller),
                ],
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double spacing = 12;
                    final double width = (constraints.maxWidth - spacing) / 2;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 12,
                      children: <Widget>[
                        SizedBox(
                          width: width,
                          child: _ReferenceCategoryCard(
                            key: const ValueKey<String>('reference-category-lunch'),
                            title: 'Lunch Boxes',
                            subtitle: '${lunch.length} colors',
                            kind: WalkaProductVisualKind.lunchBox,
                            primaryColor: WalkaLunchVariant.green.color,
                            surface: const Color(0xFFEAF1E8),
                            badge: '1200 ml',
                            onTap: lunch.isEmpty
                                ? null
                                : () => openWalkaCatalogItem(context, lunch.first),
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _ReferenceCategoryCard(
                            key: const ValueKey<String>('reference-category-drawer'),
                            title: 'Drawer Organizers',
                            subtitle: '${drawer.length} finishes',
                            kind: WalkaProductVisualKind.drawerOrganizer,
                            primaryColor: const Color(0xFFF7F4EC),
                            surface: const Color(0xFFF1E6CF),
                            badge: '8 compartments',
                            onTap: drawer.isEmpty
                                ? null
                                : () => openWalkaCatalogItem(context, drawer.first),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('SHOP THE COLLECTION', style: WalkaType.eyebrow),
                          SizedBox(height: 6),
                          Text(
                            'Choose your WALKA piece',
                            style: WalkaType.sectionTitle,
                          ),
                        ],
                      ),
                    ),
                    _ReferenceCountBadge(count: items.length),
                  ],
                ),
                const SizedBox(height: 14),
                ...items.map(
                  (WalkaCatalogViewItem item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReferenceProductRow(
                      key: ValueKey<String>('reference-category-${item.variantId}'),
                      item: item,
                      onTap: () => openWalkaCatalogItem(context, item),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _ReferenceBenefitsStrip(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// DESIGN-007B.2 Search consistency surface.
///
/// There is no dedicated Android Search reference in `Images/`; Search therefore
/// inherits the same white/navy/gold visual grammar as Home and Categories while
/// preserving the released query/family/reset behavior.
class WalkaSearchPremiumV123 extends StatefulWidget {
  const WalkaSearchPremiumV123({super.key});

  @override
  State<WalkaSearchPremiumV123> createState() => _WalkaSearchPremiumV123State();
}

class _WalkaSearchPremiumV123State extends State<WalkaSearchPremiumV123> {
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
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-reference-search-scroll'),
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: _ReferenceDiscoveryHeader(
              trailingIcon: Icons.tune_rounded,
              trailingTooltip: 'Search filters',
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 42),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                const Text(
                  'Search WALKA',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 32,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.45,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find by collection, finish, color or verified product detail.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const ValueKey<String>('premium-discovery-search-field'),
                  controller: _controller,
                  onChanged: (String value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search WALKA…',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: WalkaColors.navy,
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            key: const ValueKey<String>('reference-search-clear'),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: WalkaColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: WalkaColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: WalkaColors.gold,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _ReferenceFamilyChip(
                      label: 'All',
                      selected: _family == null,
                      onSelected: () => setState(() => _family = null),
                    ),
                    _ReferenceFamilyChip(
                      label: 'Drawer',
                      selected: _family == WalkaCatalogFamily.drawer,
                      onSelected: () => setState(
                        () => _family = WalkaCatalogFamily.drawer,
                      ),
                    ),
                    _ReferenceFamilyChip(
                      label: 'Lunch',
                      selected: _family == WalkaCatalogFamily.lunch,
                      onSelected: () => setState(
                        () => _family = WalkaCatalogFamily.lunch,
                      ),
                    ),
                  ],
                ),
                if (catalog.isLoading || catalog.isOffline) ...<Widget>[
                  const SizedBox(height: 14),
                  _ReferenceCatalogStatus(controller: catalog),
                ],
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                        key: const ValueKey<String>('premium-discovery-result-count'),
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _ReferenceSourceBadge(source: catalog.snapshot.source),
                  ],
                ),
                const SizedBox(height: 12),
                if (results.isEmpty)
                  _ReferenceNoResults(
                    onReset: () {
                      _controller.clear();
                      setState(() {
                        _query = '';
                        _family = null;
                      });
                    },
                  )
                else
                  ...results.map(
                    (WalkaCatalogViewItem item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReferenceProductRow(
                        key: ValueKey<String>('discovery-search-${item.variantId}'),
                        item: item,
                        onTap: () => openWalkaCatalogItem(context, item),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceDiscoveryHeader extends StatelessWidget {
  const _ReferenceDiscoveryHeader({
    required this.trailingIcon,
    required this.trailingTooltip,
    this.onTrailing,
  });

  final IconData trailingIcon;
  final String trailingTooltip;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-discovery-header'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: WalkaColors.line, width: 0.7)),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.menu_rounded, color: WalkaColors.navy),
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
          SizedBox(
            width: 48,
            height: 48,
            child: onTrailing == null
                ? Icon(trailingIcon, color: WalkaColors.navy)
                : IconButton(
                    key: const ValueKey<String>('reference-discovery-trailing'),
                    onPressed: onTrailing,
                    tooltip: trailingTooltip,
                    icon: Icon(trailingIcon, color: WalkaColors.navy),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceCategoryCard extends StatelessWidget {
  const _ReferenceCategoryCard({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    required this.badge,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;
  final String badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: WalkaColors.line),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: WalkaColors.navy.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 132,
                width: double.infinity,
                child: ColoredBox(
                  color: surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: WalkaProductVisual(
                      kind: kind,
                      primaryColor: primaryColor,
                      backgroundColor: surface,
                      compact: true,
                      semanticLabel: '$title category visual',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 13.5,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            badge.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: WalkaColors.gold,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: WalkaColors.gold,
                          size: 22,
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
  }
}

class _ReferenceProductRow extends StatelessWidget {
  const _ReferenceProductRow({
    required this.item,
    required this.onTap,
    super.key,
  });

  final WalkaCatalogViewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.tone,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: WalkaProductVisual(
                  kind: _visualKind(item),
                  primaryColor: _productColor(item),
                  backgroundColor: item.tone,
                  compact: true,
                  semanticLabel: '${item.title} ${item.variant}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _familyLabel(item),
                      style: const TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.55,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _productColor(item),
                            border: Border.all(
                              color: WalkaColors.navy.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.variant.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: WalkaColors.muted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: WalkaColors.gold,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceBenefitsStrip extends StatelessWidget {
  const _ReferenceBenefitsStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-categories-benefits'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final List<_ReferenceBenefit> benefits = <_ReferenceBenefit>[
            const _ReferenceBenefit(Icons.workspace_premium_outlined, 'Premium Quality'),
            const _ReferenceBenefit(Icons.inventory_2_outlined, 'Verified Catalog'),
            const _ReferenceBenefit(Icons.open_in_new_rounded, 'Official Amazon'),
            const _ReferenceBenefit(Icons.cleaning_services_outlined, 'Care Guidance'),
          ];
          return Wrap(
            spacing: 4,
            runSpacing: 14,
            children: benefits
                .map(
                  (_ReferenceBenefit benefit) => SizedBox(
                    width: (constraints.maxWidth - 4) / 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(benefit.icon, color: WalkaColors.gold, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          benefit.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _ReferenceBenefit {
  const _ReferenceBenefit(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ReferenceCountBadge extends StatelessWidget {
  const _ReferenceCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: WalkaColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count VARIANTS',
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ReferenceFamilyChip extends StatelessWidget {
  const _ReferenceFamilyChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      key: ValueKey<String>('premium-family-$label'),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: WalkaColors.navy,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? WalkaColors.navy : WalkaColors.line,
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : WalkaColors.navy,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _ReferenceNoResults extends StatelessWidget {
  const _ReferenceNoResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.search_off_rounded, color: WalkaColors.gold, size: 34),
          const SizedBox(height: 12),
          const Text(
            'No WALKA pieces found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: WalkaColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Try another color, collection or verified product detail.',
            textAlign: TextAlign.center,
            style: TextStyle(color: WalkaColors.muted, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            key: const ValueKey<String>('premium-discovery-reset'),
            onPressed: onReset,
            child: const Text('RESET SEARCH'),
          ),
        ],
      ),
    );
  }
}

class _ReferenceSourceBadge extends StatelessWidget {
  const _ReferenceSourceBadge({required this.source});

  final WalkaCatalogSource source;

  @override
  Widget build(BuildContext context) {
    final String label = switch (source) {
      WalkaCatalogSource.remote => 'LIVE CATALOG',
      WalkaCatalogSource.cache => 'SAVED CATALOG',
      WalkaCatalogSource.fallback => 'BUILT-IN CATALOG',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: WalkaColors.muted,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.45,
        ),
      ),
    );
  }
}

class _ReferenceCatalogStatus extends StatelessWidget {
  const _ReferenceCatalogStatus({required this.controller});

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
    return item.variant.toLowerCase() == 'gray'
        ? const Color(0xFF9FA5A8)
        : const Color(0xFFF7F4EC);
  }
  return switch (item.variant.toLowerCase()) {
    'pink' => WalkaLunchVariant.pink.color,
    'green' => WalkaLunchVariant.green.color,
    _ => WalkaLunchVariant.blue.color,
  };
}

String _familyLabel(WalkaCatalogViewItem item) {
  return item.family == WalkaCatalogFamily.drawer
      ? 'DRAWER ORGANIZER'
      : 'LUNCH BOX';
}
