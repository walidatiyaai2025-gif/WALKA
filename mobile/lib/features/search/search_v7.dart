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
        final int title = a.title.compareTo(b.title);
        return title == 0 ? a.colorLabel.compareTo(b.colorLabel) : title;
      });
      break;
    case WalkaSearchSort.collection:
      results.sort((a, b) {
        final int group = a.collection.index.compareTo(b.collection.index);
        return group == 0 ? a.colorLabel.compareTo(b.colorLabel) : group;
      });
      break;
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
  final List<String> _recent = <String>[];

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
    super.dispose();
  }

  List<WalkaSearchProduct> get _results => filterWalkaSearchProducts(
        query: _query,
        collection: _collection,
        sort: _sort,
        colors: _colors,
      );

  bool get _active =>
      _query.trim().isNotEmpty ||
      _collection != WalkaSearchCollection.all ||
      _colors.isNotEmpty;

  void _useQuery(String value, {bool remember = false}) {
    final String clean = value.trim();
    _controller.value = TextEditingValue(
      text: clean,
      selection: TextSelection.collapsed(offset: clean.length),
    );
    setState(() {
      _query = clean;
      if (remember && clean.isNotEmpty) {
        _recent.remove(clean);
        _recent.insert(0, clean);
        if (_recent.length > 4) {
          _recent.removeLast();
        }
      }
    });
  }

  void _reset() {
    _controller.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _query = '';
      _collection = WalkaSearchCollection.all;
      _sort = WalkaSearchSort.featured;
      _colors = <String>{};
    });
  }

  Future<void> _filter() async {
    final _FilterValue? value = await showModalBottomSheet<_FilterValue>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        WalkaSearchCollection collection = _collection;
        Set<String> colors = Set<String>.from(_colors);
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
                    const SizedBox(height: 20),
                    const Text(
                      'COLLECTION',
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      children: WalkaSearchCollection.values.map((item) {
                        return ChoiceChip(
                          label: Text(_collectionLabel(item)),
                          selected: item == collection,
                          onSelected: (_) {
                            setSheetState(() => collection = item);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'COLOR',
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <String>['White', 'Gray', 'Blue', 'Pink', 'Green']
                          .map((String color) {
                        return FilterChip(
                          label: Text(color),
                          selected: colors.contains(color),
                          onSelected: (bool selected) {
                            setSheetState(() {
                              if (selected) {
                                colors.add(color);
                              } else {
                                colors.remove(color);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                collection = WalkaSearchCollection.all;
                                colors = <String>{};
                              });
                            },
                            child: const Text('RESET'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(
                              _FilterValue(collection, colors),
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
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      _collection = value.collection;
      _colors = value.colors;
    });
  }

  Future<void> _chooseSort() async {
    final WalkaSearchSort? value = await showModalBottomSheet<WalkaSearchSort>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
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
                const SizedBox(height: 12),
                ...WalkaSearchSort.values.map((item) {
                  final bool selected = item == _sort;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.of(sheetContext).pop(item),
                    leading: Icon(
                      selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: selected ? WalkaColors.gold : WalkaColors.muted,
                    ),
                    title: Text(
                      _sortLabel(item),
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
    if (!mounted || value == null) {
      return;
    }
    setState(() => _sort = value);
  }

  void _open(WalkaSearchProduct product) {
    final Widget page = switch (product.id) {
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
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final List<WalkaSearchProduct> results = _results;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 38),
        children: <Widget>[
          const Row(
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
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onChanged: (String value) => setState(() => _query = value),
            onSubmitted: (String value) => _useQuery(value, remember: true),
            decoration: InputDecoration(
              hintText: 'Search WALKA products',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _reset,
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
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _filter,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(_filterLabel(_collection, _colors.length)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _chooseSort,
                  icon: const Icon(Icons.swap_vert_rounded, size: 18),
                  label: Text(_sortShortLabel(_sort)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: _grid ? 'Show list' : 'Show grid',
                onPressed: () => setState(() => _grid = !_grid),
                icon: Icon(
                  _grid ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (!_active) ...<Widget>[
            _DiscoveryHero(onQuery: _useQuery),
            const SizedBox(height: 24),
            if (_recent.isNotEmpty) ...<Widget>[
              _SearchChips(
                title: 'RECENT SEARCHES',
                values: _recent,
                onQuery: _useQuery,
              ),
              const SizedBox(height: 22),
            ],
            _SearchChips(
              title: 'SUGGESTED SEARCHES',
              values: _suggestions,
              onQuery: _useQuery,
            ),
            const SizedBox(height: 28),
            const Text('SHOP THE FULL EDIT', style: WalkaType.eyebrow),
            const SizedBox(height: 8),
            const Text('All WALKA essentials', style: WalkaType.sectionTitle),
            const SizedBox(height: 14),
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
                TextButton(onPressed: _reset, child: const Text('RESET')),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (results.isEmpty)
            _NoResults(onReset: _reset)
          else
            _ProductResults(
              products: results,
              grid: _grid,
              onOpen: _open,
            ),
        ],
      ),
    );
  }
}

class _DiscoveryHero extends StatelessWidget {
  const _DiscoveryHero({required this.onQuery});

  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 225,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('FIND YOUR WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 12),
          const Text(
            'A faster way to\nfind everyday order.',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 29,
              height: 1.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ActionChip(
                onPressed: () => onQuery('drawer organizer'),
                backgroundColor: Colors.white,
                side: BorderSide.none,
                label: const Text('DRAWERS'),
              ),
              ActionChip(
                onPressed: () => onQuery('lunch box'),
                backgroundColor: Colors.white,
                side: BorderSide.none,
                label: const Text('LUNCH'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchChips extends StatelessWidget {
  const _SearchChips({
    required this.title,
    required this.values,
    required this.onQuery,
  });

  final String title;
  final List<String> values;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: WalkaType.eyebrow),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((String value) {
            return ActionChip(
              onPressed: () => onQuery(value),
              avatar: const Icon(Icons.search_rounded, size: 16),
              label: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProductResults extends StatelessWidget {
  const _ProductResults({
    required this.products,
    required this.grid,
    required this.onOpen,
  });

  final List<WalkaSearchProduct> products;
  final bool grid;
  final ValueChanged<WalkaSearchProduct> onOpen;

  @override
  Widget build(BuildContext context) {
    if (grid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.73,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _ProductCard(
            product: products[index],
            compact: true,
            onTap: () => onOpen(products[index]),
          );
        },
      );
    }
    return Column(
      children: products.map((product) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ProductCard(
            product: product,
            compact: false,
            onTap: () => onOpen(product),
          ),
        );
      }).toList(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.compact,
    required this.onTap,
  });

  final WalkaSearchProduct product;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget art = Container(
      decoration: BoxDecoration(
        color: product.tone,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Icon(
          product.collection == WalkaSearchCollection.lunch
              ? Icons.lunch_dining_outlined
              : Icons.grid_view_rounded,
          color: WalkaColors.navy,
          size: 34,
        ),
      ),
    );

    if (compact) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              border: Border.all(color: WalkaColors.line),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: art),
                const SizedBox(height: 10),
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
            border: Border.all(color: WalkaColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 105, height: 96, child: art),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.collection == WalkaSearchCollection.lunch
                          ? 'LUNCH COLLECTION'
                          : 'DRAWER ORGANIZATION',
                      style: const TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.title,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 14,
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
                    const SizedBox(height: 8),
                    const Text(
                      'VIEW PRODUCT  →',
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
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

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: WalkaColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.search_off_rounded, color: WalkaColors.navy, size: 40),
          const SizedBox(height: 12),
          const Text(
            'No WALKA pieces found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              color: WalkaColors.navy,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a broader term or reset filters to see the full collection.',
            textAlign: TextAlign.center,
            style: WalkaType.body,
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onReset, child: const Text('RESET SEARCH')),
        ],
      ),
    );
  }
}

class _FilterValue {
  const _FilterValue(this.collection, this.colors);

  final WalkaSearchCollection collection;
  final Set<String> colors;
}

String _collectionLabel(WalkaSearchCollection value) => switch (value) {
      WalkaSearchCollection.all => 'All',
      WalkaSearchCollection.drawer => 'Drawer',
      WalkaSearchCollection.lunch => 'Lunch',
    };

String _sortLabel(WalkaSearchSort value) => switch (value) {
      WalkaSearchSort.featured => 'Featured',
      WalkaSearchSort.nameAsc => 'Name A–Z',
      WalkaSearchSort.collection => 'Collection',
    };

String _sortShortLabel(WalkaSearchSort value) => switch (value) {
      WalkaSearchSort.featured => 'SORT',
      WalkaSearchSort.nameAsc => 'A–Z',
      WalkaSearchSort.collection => 'COLLECTION',
    };

String _filterLabel(WalkaSearchCollection collection, int colorCount) {
  final int count = (collection == WalkaSearchCollection.all ? 0 : 1) + colorCount;
  return count == 0 ? 'FILTER' : 'FILTER · $count';
}
