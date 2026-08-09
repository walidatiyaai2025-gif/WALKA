import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../lunch/lunch_box_v6.dart';
import '../storefront/storefront_v2.dart';

enum WalkaSearchCollection { all, drawer, lunch }

enum WalkaSearchSort { featured, nameAsc, collection }

enum WalkaSearchProductId {
  drawerWhite,
  drawerGray,
  lunchBlue,
  lunchPink,
  lunchGreen,
}

class WalkaSearchProduct {
  const WalkaSearchProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.collection,
    required this.colorLabel,
    required this.tone,
    required this.keywords,
  });

  final WalkaSearchProductId id;
  final String title;
  final String subtitle;
  final WalkaSearchCollection collection;
  final String colorLabel;
  final Color tone;
  final String keywords;
}

const List<WalkaSearchProduct> walkaSearchProducts = <WalkaSearchProduct>[
  WalkaSearchProduct(
    id: WalkaSearchProductId.drawerWhite,
    title: 'Expandable Drawer Organizer',
    subtitle: '8 compartments · White',
    collection: WalkaSearchCollection.drawer,
    colorLabel: 'White',
    tone: Color(0xFFF6F3EC),
    keywords: 'drawer organizer cutlery utensil expandable kitchen white',
  ),
  WalkaSearchProduct(
    id: WalkaSearchProductId.drawerGray,
    title: 'Expandable Drawer Organizer',
    subtitle: '8 compartments · Gray',
    collection: WalkaSearchCollection.drawer,
    colorLabel: 'Gray',
    tone: Color(0xFFE2E4E7),
    keywords: 'drawer organizer cutlery utensil expandable kitchen gray grey',
  ),
  WalkaSearchProduct(
    id: WalkaSearchProductId.lunchBlue,
    title: 'Large Stainless Steel Bento Lunch Box',
    subtitle: '1200 ml · Blue',
    collection: WalkaSearchCollection.lunch,
    colorLabel: 'Blue',
    tone: Color(0xFFE4EDF2),
    keywords: 'lunch bento stainless steel adult meal prep 1200 blue',
  ),
  WalkaSearchProduct(
    id: WalkaSearchProductId.lunchPink,
    title: 'Large Stainless Steel Bento Lunch Box',
    subtitle: '1200 ml · Pink',
    collection: WalkaSearchCollection.lunch,
    colorLabel: 'Pink',
    tone: Color(0xFFF7E8EB),
    keywords: 'lunch bento stainless steel adult meal prep 1200 pink',
  ),
  WalkaSearchProduct(
    id: WalkaSearchProductId.lunchGreen,
    title: 'Large Stainless Steel Bento Lunch Box',
    subtitle: '1200 ml · Green',
    collection: WalkaSearchCollection.lunch,
    colorLabel: 'Green',
    tone: Color(0xFFEBF0E6),
    keywords: 'lunch bento stainless steel adult meal prep 1200 green',
  ),
];

List<WalkaSearchProduct> filterWalkaSearchProducts({
  required String query,
  WalkaSearchCollection collection = WalkaSearchCollection.all,
  WalkaSearchSort sort = WalkaSearchSort.featured,
  Set<String> colors = const <String>{},
}) {
  final String normalized = query.trim().toLowerCase();
  final List<WalkaSearchProduct> results = walkaSearchProducts.where((product) {
    if (collection != WalkaSearchCollection.all &&
        product.collection != collection) {
      return false;
    }
    if (colors.isNotEmpty && !colors.contains(product.colorLabel)) {
      return false;
    }
    if (normalized.isEmpty) {
      return true;
    }
    final String searchable = <String>[
      product.title,
      product.subtitle,
      product.colorLabel,
      product.keywords,
    ].join(' ').toLowerCase();
    return searchable.contains(normalized);
  }).toList();

  switch (sort) {
    case WalkaSearchSort.featured:
      break;
    case WalkaSearchSort.nameAsc:
      results.sort((a, b) {
        final int titleCompare = a.title.compareTo(b.title);
        return titleCompare != 0
            ? titleCompare
            : a.colorLabel.compareTo(b.colorLabel);
      });
    case WalkaSearchSort.collection:
      results.sort((a, b) {
        final int collectionCompare = a.collection.index.compareTo(
          b.collection.index,
        );
        return collectionCompare != 0
            ? collectionCompare
            : a.colorLabel.compareTo(b.colorLabel);
      });
  }

  return results;
}

class WalkaSearchV7 extends StatefulWidget {
  const WalkaSearchV7({super.key});

  @override
  State<WalkaSearchV7> createState() => _WalkaSearchV7State();
}

class _WalkaSearchV7State extends State<WalkaSearchV7> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _recentSearches = <String>[];

  String _query = '';
  WalkaSearchCollection _collection = WalkaSearchCollection.all;
  WalkaSearchSort _sort = WalkaSearchSort.featured;
  Set<String> _colors = <String>{};
  bool _grid = false;

  static const List<String> _suggestions = <String>[
    'drawer organizer',
    'lunch box',
    'stainless steel bento',
    'expandable cutlery tray',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<WalkaSearchProduct> get _results => filterWalkaSearchProducts(
        query: _query,
        collection: _collection,
        sort: _sort,
        colors: _colors,
      );

  bool get _hasActiveSearch =>
      _query.trim().isNotEmpty ||
      _collection != WalkaSearchCollection.all ||
      _colors.isNotEmpty;

  void _applyQuery(String value, {bool submit = false}) {
    final String next = value.trimLeft();
    if (_controller.text != next) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    setState(() {
      _query = next;
      if (submit && next.trim().isNotEmpty) {
        _recentSearches.remove(next.trim());
        _recentSearches.insert(0, next.trim());
        if (_recentSearches.length > 4) {
          _recentSearches.removeLast();
        }
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _query = '';
      _collection = WalkaSearchCollection.all;
      _sort = WalkaSearchSort.featured;
      _colors = <String>{};
    });
  }

  Future<void> _showFilters() async {
    final _SearchFilterSelection? selection =
        await showModalBottomSheet<_SearchFilterSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        WalkaSearchCollection draftCollection = _collection;
        Set<String> draftColors = Set<String>.from(_colors);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('FILTER RESULTS', style: WalkaType.eyebrow),
                    const SizedBox(height: 8),
                    const Text('Narrow the collection', style: WalkaType.sectionTitle),
                    const SizedBox(height: 22),
                    const _SheetLabel('COLLECTION'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WalkaSearchCollection.values.map((value) {
                        return ChoiceChip(
                          label: Text(_collectionLabel(value)),
                          selected: draftCollection == value,
                          onSelected: (_) => setSheetState(
                            () => draftCollection = value,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    const _SheetLabel('COLOR'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <String>[
                        'White',
                        'Gray',
                        'Blue',
                        'Pink',
                        'Green',
                      ].map((String color) {
                        return FilterChip(
                          label: Text(color),
                          selected: draftColors.contains(color),
                          onSelected: (bool selected) {
                            setSheetState(() {
                              if (selected) {
                                draftColors.add(color);
                              } else {
                                draftColors.remove(color);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                draftCollection = WalkaSearchCollection.all;
                                draftColors = <String>{};
                              });
                            },
                            child: const Text('RESET'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(
                              _SearchFilterSelection(
                                draftCollection,
                                draftColors,
                              ),
                            ),
                            child: const Text('APPLY'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || selection == null) {
      return;
    }
    setState(() {
      _collection = selection.collection;
      _colors = selection.colors;
    });
  }

  Future<void> _showSort() async {
    final WalkaSearchSort? selected = await showModalBottomSheet<WalkaSearchSort>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('SORT RESULTS', style: WalkaType.eyebrow),
                const SizedBox(height: 8),
                const Text('Choose an order', style: WalkaType.sectionTitle),
                const SizedBox(height: 14),
                ...WalkaSearchSort.values.map((value) {
                  final bool active = value == _sort;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.of(context).pop(value),
                    leading: Icon(
                      active
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: active ? WalkaColors.gold : WalkaColors.muted,
                    ),
                    title: Text(
                      _sortLabel(value),
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }
    setState(() => _sort = selected);
  }

  void _openProduct(WalkaSearchProduct product) {
    final Widget destination = switch (product.id) {
      WalkaSearchProductId.drawerWhite => const WalkaProductDetailV2(),
      WalkaSearchProductId.drawerGray =>
        const WalkaProductDetailV2(initialGray: true),
      WalkaSearchProductId.lunchBlue => const WalkaLunchProductDetailV6(),
      WalkaSearchProductId.lunchPink => const WalkaLunchProductDetailV6(
          initialVariant: WalkaLunchVariant.pink,
        ),
      WalkaSearchProductId.lunchGreen => const WalkaLunchProductDetailV6(
          initialVariant: WalkaLunchVariant.green,
        ),
    };
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<WalkaSearchProduct> results = _results;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 38),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: <Widget>[
                Text(
                  'WALKA',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.8,
                  ),
                ),
                Spacer(),
                Text('DISCOVER', style: WalkaType.eyebrow),
              ],
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onChanged: (String value) => setState(() => _query = value),
            onSubmitted: (String value) => _applyQuery(value, submit: true),
            decoration: InputDecoration(
              hintText: 'Search WALKA products',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _clearSearch,
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: WalkaColors.navy, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SearchActionRow(
            collection: _collection,
            colorCount: _colors.length,
            sort: _sort,
            grid: _grid,
            onFilter: _showFilters,
            onSort: _showSort,
            onToggleView: () => setState(() => _grid = !_grid),
          ),
          const SizedBox(height: 24),
          if (!_hasActiveSearch) ...<Widget>[
            _DiscoveryIntro(onSearch: _applyQuery),
            const SizedBox(height: 26),
            if (_recentSearches.isNotEmpty) ...<Widget>[
              _ChipSection(
                title: 'RECENT SEARCHES',
                values: _recentSearches,
                onSelected: _applyQuery,
              ),
              const SizedBox(height: 24),
            ],
            _ChipSection(
              title: 'SUGGESTED SEARCHES',
              values: _suggestions,
              onSelected: _applyQuery,
            ),
            const SizedBox(height: 30),
            const Text('SHOP THE FULL EDIT', style: WalkaType.eyebrow),
            const SizedBox(height: 8),
            const Text('All WALKA essentials', style: WalkaType.sectionTitle),
            const SizedBox(height: 16),
            _ResultsView(
              products: results,
              grid: _grid,
              onOpen: _openProduct,
            ),
          ] else ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('SEARCH RESULTS', style: WalkaType.eyebrow),
                      const SizedBox(height: 7),
                      Text(
                        '${results.length} ${results.length == 1 ? 'match' : 'matches'}',
                        style: WalkaType.sectionTitle,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _clearSearch,
                  child: const Text('RESET'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (results.isEmpty)
              _NoResults(onReset: _clearSearch)
            else
              _ResultsView(
                products: results,
                grid: _grid,
                onOpen: _openProduct,
              ),
          ],
        ],
      ),
    );
  }
}

class _SearchActionRow extends StatelessWidget {
  const _SearchActionRow({
    required this.collection,
    required this.colorCount,
    required this.sort,
    required this.grid,
    required this.onFilter,
    required this.onSort,
    required this.onToggleView,
  });

  final WalkaSearchCollection collection;
  final int colorCount;
  final WalkaSearchSort sort;
  final bool grid;
  final VoidCallback onFilter;
  final VoidCallback onSort;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) {
    final int activeFilters =
        (collection == WalkaSearchCollection.all ? 0 : 1) + colorCount;
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onFilter,
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Text(activeFilters == 0 ? 'FILTER' : 'FILTER · $activeFilters'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSort,
            icon: const Icon(Icons.swap_vert_rounded, size: 18),
            label: Text(_sortShortLabel(sort)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          tooltip: grid ? 'Show list' : 'Show grid',
          onPressed: onToggleView,
          icon: Icon(grid ? Icons.view_agenda_outlined : Icons.grid_view_rounded),
        ),
      ],
    );
  }
}

class _DiscoveryIntro extends StatelessWidget {
  const _DiscoveryIntro({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -28,
            bottom: -42,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: WalkaColors.gold.withValues(alpha: 0.24),
                  width: 30,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('FIND YOUR WALKA', style: WalkaType.eyebrow),
              const SizedBox(height: 11),
              const SizedBox(
                width: 250,
                child: Text(
                  'A faster way to\nfind everyday order.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Colors.white,
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  _HeroQuickAction(
                    label: 'DRAWERS',
                    onTap: () => onSearch('drawer organizer'),
                  ),
                  _HeroQuickAction(
                    label: 'LUNCH',
                    onTap: () => onSearch('lunch box'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroQuickAction extends StatelessWidget {
  const _HeroQuickAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: BorderSide.none,
      label: Text(
        label,
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.values,
    required this.onSelected,
  });

  final String title;
  final List<String> values;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: WalkaType.eyebrow),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((String value) {
            return ActionChip(
              onPressed: () => onSelected(value),
              avatar: const Icon(Icons.search_rounded, size: 16),
              label: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.products,
    required this.grid,
    required this.onOpen,
  });

  final List<WalkaSearchProduct> products;
  final bool grid;
  final ValueChanged<WalkaSearchProduct> onOpen;

  @override
  Widget build(BuildContext context) {
    if (!grid) {
      return Column(
        children: products.map((WalkaSearchProduct product) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _SearchProductCard(
              product: product,
              compact: false,
              onTap: () => onOpen(product),
            ),
          );
        }).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (BuildContext context, int index) {
        final WalkaSearchProduct product = products[index];
        return _SearchProductCard(
          product: product,
          compact: true,
          onTap: () => onOpen(product),
        );
      },
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({
    required this.product,
    required this.compact,
    required this.onTap,
  });

  final WalkaSearchProduct product;
  final bool compact;
  final VoidCallback onTap;

  bool get _isLunch => product.collection == WalkaSearchCollection.lunch;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: WalkaColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _ProductArtwork(product: product)),
                const SizedBox(height: 12),
                Text(
                  _isLunch ? 'LUNCH COLLECTION' : 'DRAWER ORGANIZATION',
                  style: const TextStyle(
                    color: WalkaColors.gold,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 12,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.colorLabel,
                  style: const TextStyle(color: WalkaColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 108, height: 100, child: _ProductArtwork(product: product)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _isLunch ? 'LUNCH COLLECTION' : 'DRAWER ORGANIZATION',
                      style: const TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.title,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 15,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.subtitle,
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
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward_rounded, color: WalkaColors.gold, size: 16),
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

class _ProductArtwork extends StatelessWidget {
  const _ProductArtwork({required this.product});

  final WalkaSearchProduct product;

  @override
  Widget build(BuildContext context) {
    final bool lunch = product.collection == WalkaSearchCollection.lunch;
    return Container(
      decoration: BoxDecoration(
        color: product.tone,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Container(
          width: lunch ? 70 : 78,
          height: lunch ? 45 : 58,
          decoration: BoxDecoration(
            color: _artworkColor(product.colorLabel),
            borderRadius: BorderRadius.circular(lunch ? 13 : 10),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x1E000000), blurRadius: 9, offset: Offset(0, 5)),
            ],
          ),
          child: Icon(
            lunch ? Icons.lunch_dining_outlined : Icons.grid_view_rounded,
            color: WalkaColors.navy.withValues(alpha: 0.58),
            size: lunch ? 24 : 28,
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 30),
      decoration: BoxDecoration(
        color: WalkaColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.search_off_rounded, color: WalkaColors.navy, size: 42),
          const SizedBox(height: 14),
          const Text(
            'No WALKA pieces found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              color: WalkaColors.navy,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a broader term or reset the filters to see the full collection.',
            textAlign: TextAlign.center,
            style: WalkaType.body,
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: onReset,
            child: const Text('RESET SEARCH'),
          ),
        ],
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: WalkaColors.navy,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SearchFilterSelection {
  const _SearchFilterSelection(this.collection, this.colors);

  final WalkaSearchCollection collection;
  final Set<String> colors;
}

String _collectionLabel(WalkaSearchCollection collection) => switch (collection) {
      WalkaSearchCollection.all => 'All',
      WalkaSearchCollection.drawer => 'Drawer',
      WalkaSearchCollection.lunch => 'Lunch',
    };

String _sortLabel(WalkaSearchSort sort) => switch (sort) {
      WalkaSearchSort.featured => 'Featured',
      WalkaSearchSort.nameAsc => 'Name A–Z',
      WalkaSearchSort.collection => 'Collection',
    };

String _sortShortLabel(WalkaSearchSort sort) => switch (sort) {
      WalkaSearchSort.featured => 'SORT',
      WalkaSearchSort.nameAsc => 'A–Z',
      WalkaSearchSort.collection => 'COLLECTION',
    };

Color _artworkColor(String label) => switch (label) {
      'White' => const Color(0xFFF9F8F4),
      'Gray' => const Color(0xFF969CA3),
      'Blue' => const Color(0xFF7894A5),
      'Pink' => const Color(0xFFE9B8C2),
      'Green' => const Color(0xFFB6C7A8),
      _ => WalkaColors.surface,
    };
