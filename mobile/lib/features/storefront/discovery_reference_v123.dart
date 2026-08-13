import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../content/content_state.dart';
import '../content/domain/walka_search_presentation_content.dart';
import '../lunch/lunch_box_v6.dart';
import 'presentation/widgets/discovery/walka_categories_benefits.dart';
import 'presentation/widgets/discovery/walka_category_card.dart';
import 'presentation/widgets/discovery/walka_discovery_header.dart';
import 'presentation/widgets/discovery/walka_discovery_meta.dart';
import 'presentation/widgets/discovery/walka_discovery_product_row.dart';
import 'presentation/widgets/discovery/walka_search_empty_state.dart';
import 'presentation/widgets/discovery/walka_search_field.dart';
import 'presentation/widgets/discovery/walka_search_filters.dart';
import 'presentation/widgets/discovery/walka_search_results.dart';
import 'storefront_catalog_v120.dart';

/// DESIGN-007B.2 Android-reference Categories fidelity with extracted visuals.
class WalkaCategoriesPremiumV123 extends StatelessWidget {
  const WalkaCategoriesPremiumV123({this.onSearch, super.key});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(controller.snapshot);
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
            child: WalkaDiscoveryHeader(
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
                  WalkaDiscoveryCatalogStatus(controller: controller),
                ],
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    const double spacing = 12;
                    final double width = (constraints.maxWidth - spacing) / 2;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 12,
                      children: <Widget>[
                        SizedBox(
                          width: width,
                          child: WalkaCategoryCard(
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
                          child: WalkaCategoryCard(
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
                          Text('Choose your WALKA piece', style: WalkaType.sectionTitle),
                        ],
                      ),
                    ),
                    WalkaDiscoveryCountBadge(count: items.length),
                  ],
                ),
                const SizedBox(height: 14),
                ...items.map(
                  (WalkaCatalogViewItem item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WalkaDiscoveryProductRow(
                      key: ValueKey<String>('reference-category-${item.variantId}'),
                      item: item,
                      onTap: () => openWalkaCatalogItem(context, item),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const WalkaCategoriesBenefits(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// CMS-025 Search keeps query matching and complete catalog truth compiled,
/// while typed CMS content controls safe copy, filter labels and default
/// Featured ordering only.
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

  void _clearQuery() {
    _controller.clear();
    setState(() => _query = '');
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _query = '';
      _family = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController catalog = WalkaCatalogScope.of(context);
    final WalkaSearchPresentationContent presentation =
        WalkaContentScope.maybeOf(context)?.search.content ??
            WalkaSearchPresentationContent.bundled;
    final String query = _query.trim().toLowerCase();

    final Map<String, int> featuredPosition = <String, int>{
      for (int index = 0; index < presentation.featuredVariantIds.length; index++)
        presentation.featuredVariantIds[index]: index,
    };
    final List<WalkaCatalogViewItem> ordered =
        walkaCatalogViewItems(catalog.snapshot).toList(growable: true)
          ..sort((WalkaCatalogViewItem a, WalkaCatalogViewItem b) {
            final int aPosition = featuredPosition[a.variantId] ?? 1 << 20;
            final int bPosition = featuredPosition[b.variantId] ?? 1 << 20;
            return aPosition.compareTo(bPosition);
          });

    final List<WalkaCatalogViewItem> results = ordered
        .where((WalkaCatalogViewItem item) {
          if (_family != null && item.family != _family) return false;
          if (query.isEmpty) return true;
          final String haystack = <String>[
            item.title,
            item.variant,
            item.family.name,
            item.searchTerms,
          ].join(' ').toLowerCase();
          return query.split(RegExp(r'\s+')).every(haystack.contains);
        })
        .toList(growable: false);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-reference-search-scroll'),
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: WalkaDiscoveryHeader(
              trailingIcon: Icons.tune_rounded,
              trailingTooltip: 'Search filters',
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 42),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                Text(
                  presentation.heading,
                  key: const ValueKey<String>('cms-search-heading'),
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 32,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  presentation.supportingCopy,
                  key: const ValueKey<String>('cms-search-supporting-copy'),
                  style: const TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                WalkaSearchField(
                  controller: _controller,
                  query: _query,
                  placeholder: presentation.placeholder,
                  onChanged: (String value) => setState(() => _query = value),
                  onClear: _clearQuery,
                ),
                const SizedBox(height: 14),
                WalkaSearchFilters(
                  selectedFamily: _family,
                  allLabel: presentation.filterLabel('all', 'All'),
                  drawerLabel:
                      presentation.filterLabel('drawer-organization', 'Drawer'),
                  lunchLabel: presentation.filterLabel('lunch', 'Lunch'),
                  onChanged: (WalkaCatalogFamily? family) =>
                      setState(() => _family = family),
                ),
                if (catalog.isLoading || catalog.isOffline) ...<Widget>[
                  const SizedBox(height: 14),
                  WalkaDiscoveryCatalogStatus(controller: catalog),
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
                    WalkaDiscoverySourceBadge(source: catalog.snapshot.source),
                  ],
                ),
                const SizedBox(height: 12),
                if (results.isEmpty)
                  WalkaSearchEmptyState(
                    title: presentation.emptyTitle,
                    body: presentation.emptyBody,
                    onReset: _reset,
                  )
                else
                  WalkaSearchResults(
                    results: results,
                    onOpen: (WalkaCatalogViewItem item) =>
                        openWalkaCatalogItem(context, item),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
