import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../lunch/lunch_box_v6.dart';
import 'storefront_catalog_v120.dart';

/// DESIGN-003 product-led Categories experience.
///
/// Keeps the released catalog/navigation behavior while replacing generic
/// product-family icons with reusable WALKA product visuals and a more
/// editorial discovery hierarchy.
class WalkaCategoriesPremiumV122 extends StatelessWidget {
  const WalkaCategoriesPremiumV122({super.key});

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(
      controller.snapshot,
    );
    final List<WalkaCatalogViewItem> drawerItems = items
        .where((WalkaCatalogViewItem item) => item.family == WalkaCatalogFamily.drawer)
        .toList(growable: false);
    final List<WalkaCatalogViewItem> lunchItems = items
        .where((WalkaCatalogViewItem item) => item.family == WalkaCatalogFamily.lunch)
        .toList(growable: false);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-premium-categories-scroll'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                WalkaShellMetrics.headerTop,
                gutter,
                0,
              ),
              child: const WalkaWordmark(compact: true),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 18),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('SHOP WALKA', style: WalkaType.eyebrow),
                  SizedBox(height: 8),
                  Text('Two collections. One calm system.', style: WalkaType.sectionTitle),
                  SizedBox(height: 10),
                  Text(
                    'Explore drawer organization and the WALKA lunch collection through their real product forms, then choose the variant that fits your space or routine.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          if (controller.isLoading || controller.isOffline)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 16),
                child: _DiscoveryCatalogStatus(controller: controller),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: Column(
                children: <Widget>[
                  _FamilyEditorialCard(
                    key: const ValueKey<String>('discovery-family-drawer'),
                    eyebrow: 'THE DRAWER EDIT',
                    title: 'Order for the everyday drawer.',
                    detail: '${drawerItems.length} finishes · expandable · 8 compartments',
                    kind: WalkaProductVisualKind.drawerOrganizer,
                    primaryColor: const Color(0xFFF7F4EC),
                    surface: const Color(0xFFF2E9CF),
                  ),
                  const SizedBox(height: 14),
                  _FamilyEditorialCard(
                    key: const ValueKey<String>('discovery-family-lunch'),
                    eyebrow: 'LUNCH, REFINED',
                    title: 'A complete lunch system in color.',
                    detail: '${lunchItems.length} colors · 1200 ml · SUS304 tray',
                    kind: WalkaProductVisualKind.lunchBox,
                    primaryColor: WalkaLunchVariant.blue.color,
                    surface: const Color(0xFFEAF0F5),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('CURRENT COLLECTION', style: WalkaType.eyebrow),
                        SizedBox(height: 7),
                        Text('Choose your variant', style: WalkaType.sectionTitle),
                      ],
                    ),
                  ),
                  _CountBadge(label: '${items.length} VARIANTS'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            sliver: SliverGrid.builder(
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.70,
              ),
              itemBuilder: (BuildContext context, int index) {
                final WalkaCatalogViewItem item = items[index];
                return _DiscoveryVariantCard(
                  key: ValueKey<String>('discovery-category-${item.variantId}'),
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

/// DESIGN-003 search surface preserving API-002 query/family semantics.
class WalkaSearchPremiumV122 extends StatefulWidget {
  const WalkaSearchPremiumV122({super.key});

  @override
  State<WalkaSearchPremiumV122> createState() => _WalkaSearchPremiumV122State();
}

class _WalkaSearchPremiumV122State extends State<WalkaSearchPremiumV122> {
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
      child: ListView(
        key: const PageStorageKey<String>('walka-premium-search-scroll'),
        padding: EdgeInsets.fromLTRB(
          gutter,
          WalkaShellMetrics.headerTop,
          gutter,
          42,
        ),
        children: <Widget>[
          const WalkaWordmark(compact: true),
          const SizedBox(height: 28),
          const Text('SEARCH WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          const Text('Find the piece that fits.', style: WalkaType.sectionTitle),
          const SizedBox(height: 9),
          const Text(
            'Search by collection, finish, color or a verified product detail.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 18),
          TextField(
            key: const ValueKey<String>('premium-discovery-search-field'),
            controller: _controller,
            onChanged: (String value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Drawer, lunch box, blue, SUS304…',
              prefixIcon: const Icon(Icons.search_rounded, color: WalkaColors.navy),
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
              fillColor: WalkaColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: WalkaColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: WalkaColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: WalkaColors.gold, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _FamilyChoiceChip(
                label: 'All',
                selected: _family == null,
                onSelected: () => setState(() => _family = null),
              ),
              _FamilyChoiceChip(
                label: 'Drawer',
                selected: _family == WalkaCatalogFamily.drawer,
                onSelected: () => setState(() => _family = WalkaCatalogFamily.drawer),
              ),
              _FamilyChoiceChip(
                label: 'Lunch',
                selected: _family == WalkaCatalogFamily.lunch,
                onSelected: () => setState(() => _family = WalkaCatalogFamily.lunch),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (catalog.isLoading || catalog.isOffline)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DiscoveryCatalogStatus(controller: catalog),
            ),
          Row(
            children: <Widget>[
              Text(
                '${results.length} ${results.length == 1 ? 'result' : 'results'}',
                key: const ValueKey<String>('premium-discovery-result-count'),
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              _CatalogSourceBadge(source: catalog.snapshot.source),
            ],
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            _NoDiscoveryResults(
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
                child: _PremiumSearchResult(
                  key: ValueKey<String>('discovery-search-${item.variantId}'),
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

class _FamilyEditorialCard extends StatelessWidget {
  const _FamilyEditorialCard({
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: WalkaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 8, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(eyebrow, style: WalkaType.eyebrow),
                  const SizedBox(height: 9),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: WalkaColors.navy,
                      fontSize: 24,
                      height: 1.08,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: WalkaColors.muted,
                      fontSize: 10,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 10, 12),
              child: WalkaProductVisual(
                kind: kind,
                primaryColor: primaryColor,
                backgroundColor: surface,
                compact: true,
                semanticLabel: kind == WalkaProductVisualKind.drawerOrganizer
                    ? 'WALKA Drawer Organizer collection'
                    : 'WALKA Lunch Box collection',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryVariantCard extends StatelessWidget {
  const _DiscoveryVariantCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final WalkaCatalogViewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
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
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: item.tone,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                  ),
                  child: WalkaProductVisual(
                    kind: _visualKind(item),
                    primaryColor: _productColor(item),
                    backgroundColor: item.tone,
                    compact: true,
                    semanticLabel: '${item.title} ${item.variant}',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.family == WalkaCatalogFamily.drawer
                          ? 'DRAWER ORGANIZATION'
                          : 'LUNCH COLLECTION',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 12,
                        height: 1.22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
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
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.variant.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: WalkaColors.gold,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: WalkaColors.navy,
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

class _PremiumSearchResult extends StatelessWidget {
  const _PremiumSearchResult({
    required this.item,
    required this.onTap,
    super.key,
  });

  final WalkaCatalogViewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: WalkaColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: item.tone,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: WalkaProductVisual(
                  kind: _visualKind(item),
                  primaryColor: _productColor(item),
                  backgroundColor: item.tone,
                  compact: true,
                  semanticLabel: '${item.title} ${item.variant} search result',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.family == WalkaCatalogFamily.drawer
                          ? 'DRAWER ORGANIZATION'
                          : 'LUNCH COLLECTION',
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
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
                        height: 1.22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: _productColor(item),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: WalkaColors.navy.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.variant,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: WalkaColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: WalkaColors.gold, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyChoiceChip extends StatelessWidget {
  const _FamilyChoiceChip({
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
      showCheckmark: false,
      selectedColor: WalkaColors.navy,
      backgroundColor: WalkaColors.white,
      side: BorderSide(
        color: selected ? WalkaColors.navy : WalkaColors.line,
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : WalkaColors.navy,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: WalkaColors.white,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: WalkaColors.muted,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _CatalogSourceBadge extends StatelessWidget {
  const _CatalogSourceBadge({required this.source});

  final WalkaCatalogSource source;

  @override
  Widget build(BuildContext context) {
    final String label = source == WalkaCatalogSource.remote
        ? 'LIVE CATALOG'
        : 'RESILIENT CATALOG';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9CF),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _DiscoveryCatalogStatus extends StatelessWidget {
  const _DiscoveryCatalogStatus({required this.controller});

  final WalkaCatalogController controller;

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;
    if (controller.isLoading) {
      label = 'Updating WALKA catalog…';
      icon = Icons.sync_rounded;
    } else if (controller.isUsingCache) {
      label = 'Offline · showing the last saved WALKA catalog';
      icon = Icons.cloud_off_outlined;
    } else {
      label = 'Offline · showing the built-in WALKA catalog';
      icon = Icons.inventory_2_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: WalkaColors.white,
        borderRadius: BorderRadius.circular(16),
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

class _NoDiscoveryResults extends StatelessWidget {
  const _NoDiscoveryResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9CF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: WalkaColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, color: WalkaColors.navy),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nothing matched that search',
            style: WalkaType.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a color, Drawer Organizer, Lunch Box or SUS304.',
            style: WalkaType.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            key: const ValueKey<String>('premium-discovery-reset'),
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('RESET SEARCH'),
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
