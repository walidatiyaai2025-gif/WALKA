import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../lunch/lunch_box_v6.dart';
import '../storefront/storefront_v2.dart' show WalkaProductDetailV2;

enum WalkaSearchCollection { all, drawer, lunch }

enum WalkaSearchSort { featured, name, collection }

extension WalkaSearchCollectionX on WalkaSearchCollection {
  String get label => switch (this) {
        WalkaSearchCollection.all => 'All',
        WalkaSearchCollection.drawer => 'Drawer',
        WalkaSearchCollection.lunch => 'Lunch',
      };
}

extension WalkaSearchSortX on WalkaSearchSort {
  String get label => switch (this) {
        WalkaSearchSort.featured => 'Featured',
        WalkaSearchSort.name => 'Name A–Z',
        WalkaSearchSort.collection => 'Collection',
      };
}

class WalkaSearchProduct {
  const WalkaSearchProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colorLabel,
    required this.collection,
    required this.searchTerms,
    this.drawerGray = false,
    this.lunchVariant,
  });

  final String id;
  final String title;
  final String subtitle;
  final String colorLabel;
  final WalkaSearchCollection collection;
  final String searchTerms;
  final bool drawerGray;
  final WalkaLunchVariant? lunchVariant;
}

const List<WalkaSearchProduct> walkaSearchCatalog = <WalkaSearchProduct>[
  WalkaSearchProduct(
    id: 'drawer-white',
    title: 'Expandable Drawer Organizer',
    subtitle: '8 compartments · 13″–22.4″',
    colorLabel: 'White',
    collection: WalkaSearchCollection.drawer,
    searchTerms:
        'drawer organizer cutlery utensils kitchen expandable white non slip 8 compartments home organization',
  ),
  WalkaSearchProduct(
    id: 'drawer-gray',
    title: 'Expandable Drawer Organizer',
    subtitle: '8 compartments · 13″–22.4″',
    colorLabel: 'Gray',
    collection: WalkaSearchCollection.drawer,
    searchTerms:
        'drawer organizer cutlery utensils kitchen expandable gray grey non slip 8 compartments home organization',
    drawerGray: true,
  ),
  WalkaSearchProduct(
    id: 'lunch-blue',
    title: 'Large Stainless Steel Bento Lunch Box',
    subtitle: '1200 ml · 4 compartments',
    colorLabel: 'Blue',
    collection: WalkaSearchCollection.lunch,
    searchTerms:
        'lunch box bento stainless steel 304 sus304 adult blue 1200 ml four 4 compartments bag utensils sauce cup',
    lunchVariant: WalkaLunchVariant.blue,
  ),
  WalkaSearchProduct(
    id: 'lunch-pink',
    title: 'Large Stainless Steel Bento Lunch Box',
    subtitle: '1200 ml · 4 compartments',
    colorLabel: 'Pink',
    collection: WalkaSearchCollection.lunch,
    searchTerms:
        'lunch box bento stainless steel 304 sus304 adult pink 1200 ml four 4 compartments bag utensils sauce cup',
    lunchVariant: WalkaLunchVariant.pink,
  ),
  WalkaSearchProduct(
    id: 'lunch-green',
    title: 'Large Stainless Steel Bento Lunch Box',
    subtitle: '1200 ml · 4 compartments',
    colorLabel: 'Green',
    collection: WalkaSearchCollection.lunch,
    searchTerms:
        'lunch box bento stainless steel 304 sus304 adult green 1200 ml four 4 compartments bag utensils sauce cup',
    lunchVariant: WalkaLunchVariant.green,
  ),
];

class WalkaSearchV9 extends StatefulWidget {
  const WalkaSearchV9({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<WalkaSearchV9> createState() => _WalkaSearchV9State();
}

class _WalkaSearchV9State extends State<WalkaSearchV9> {
  late final TextEditingController _controller;
  late String _query;
  WalkaSearchCollection _collection = WalkaSearchCollection.all;
  WalkaSearchSort _sort = WalkaSearchSort.featured;

  static const List<String> _recentSearches = <String>[
    'drawer organizer',
    'lunch box',
    'stainless steel',
  ];

  static const List<String> _discoverTerms = <String>[
    'Expandable',
    'White',
    'Gray',
    'Blue',
    'Pink',
    'Green',
    'SUS304',
    '1200 ml',
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<WalkaSearchProduct> get _results {
    final String normalized = _query.trim().toLowerCase();
    Iterable<WalkaSearchProduct> items = walkaSearchCatalog;

    if (_collection != WalkaSearchCollection.all) {
      items = items.where(
        (WalkaSearchProduct product) => product.collection == _collection,
      );
    }

    if (normalized.isNotEmpty) {
      final List<String> tokens = normalized
          .split(RegExp(r'\s+'))
          .where((String token) => token.isNotEmpty)
          .toList();
      items = items.where((WalkaSearchProduct product) {
        final String haystack = <String>[
          product.title,
          product.subtitle,
          product.colorLabel,
          product.collection.label,
          product.searchTerms,
        ].join(' ').toLowerCase();
        return tokens.every(haystack.contains);
      });
    }

    final List<WalkaSearchProduct> result = items.toList();
    switch (_sort) {
      case WalkaSearchSort.featured:
        break;
      case WalkaSearchSort.name:
        result.sort((a, b) {
          final int title = a.title.compareTo(b.title);
          if (title != 0) {
            return title;
          }
          return a.colorLabel.compareTo(b.colorLabel);
        });
      case WalkaSearchSort.collection:
        result.sort((a, b) {
          final int collection = a.collection.index.compareTo(b.collection.index);
          if (collection != 0) {
            return collection;
          }
          return a.colorLabel.compareTo(b.colorLabel);
        });
    }
    return result;
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value);
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _query = '';
      _collection = WalkaSearchCollection.all;
      _sort = WalkaSearchSort.featured;
    });
  }

  void _openProduct(WalkaSearchProduct product) {
    if (product.collection == WalkaSearchCollection.drawer) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WalkaProductDetailV2(initialGray: product.drawerGray),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaLunchProductDetailV6(
          initialVariant: product.lunchVariant ?? WalkaLunchVariant.blue,
        ),
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    final WalkaSearchCollection? selected =
        await showModalBottomSheet<WalkaSearchCollection>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('FILTER RESULTS', style: WalkaType.eyebrow),
                const SizedBox(height: 8),
                const Text('Shop by collection', style: WalkaType.sectionTitle),
                const SizedBox(height: 18),
                ...WalkaSearchCollection.values.map(
                  (WalkaSearchCollection value) => RadioListTile<WalkaSearchCollection>(
                    contentPadding: EdgeInsets.zero,
                    value: value,
                    groupValue: _collection,
                    activeColor: WalkaColors.navy,
                    title: Text(
                      switch (value) {
                        WalkaSearchCollection.all => 'All WALKA products',
                        WalkaSearchCollection.drawer => 'Drawer Organization',
                        WalkaSearchCollection.lunch => 'Lunch Collection',
                      },
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: value == WalkaSearchCollection.all
                        ? const Text('Show every available variant')
                        : null,
                    onChanged: (WalkaSearchCollection? item) {
                      if (item != null) {
                        Navigator.of(context).pop(item);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _collection = selected);
    }
  }

  Future<void> _showSortSheet() async {
    final WalkaSearchSort? selected = await showModalBottomSheet<WalkaSearchSort>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('SORT RESULTS', style: WalkaType.eyebrow),
                const SizedBox(height: 8),
                const Text('Choose an order', style: WalkaType.sectionTitle),
                const SizedBox(height: 18),
                ...WalkaSearchSort.values.map(
                  (WalkaSearchSort value) => RadioListTile<WalkaSearchSort>(
                    contentPadding: EdgeInsets.zero,
                    value: value,
                    groupValue: _sort,
                    activeColor: WalkaColors.navy,
                    title: Text(
                      value.label,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onChanged: (WalkaSearchSort? item) {
                      if (item != null) {
                        Navigator.of(context).pop(item);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _sort = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool searching = _query.trim().isNotEmpty ||
        _collection != WalkaSearchCollection.all;
    final List<WalkaSearchProduct> results = _results;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SEARCH WALKA',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _SearchField(
                  controller: _controller,
                  onChanged: (String value) => setState(() => _query = value),
                  onClear: _clearSearch,
                ),
              ),
            ),
            if (!searching) ...<Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: _SearchIntro(onQuery: _setQuery),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: _TermSection(
                    eyebrow: 'RECENT',
                    title: 'Pick up where you left off',
                    terms: _recentSearches,
                    onTap: _setQuery,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 42),
                  child: _TermSection(
                    eyebrow: 'DISCOVER',
                    title: 'Try a detail or color',
                    terms: _discoverTerms,
                    onTap: _setQuery,
                  ),
                ),
              ),
            ] else ...<Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                  child: _ResultsToolbar(
                    resultCount: results.length,
                    collection: _collection,
                    sort: _sort,
                    onFilter: _showFilterSheet,
                    onSort: _showSortSheet,
                  ),
                ),
              ),
              if (results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NoResults(
                    query: _query,
                    onClear: _clearSearch,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final WalkaSearchProduct product = results[index];
                        return _SearchProductCard(
                          product: product,
                          onTap: () => _openProduct(product),
                        );
                      },
                      childCount: results.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.67,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search organizers, colors, details…',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
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
    );
  }
}

class _SearchIntro extends StatelessWidget {
  const _SearchIntro({required this.onQuery});

  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('FIND YOUR WALKA', style: WalkaType.eyebrow),
        const SizedBox(height: 9),
        const Text('What are you organizing?', style: WalkaType.sectionTitle),
        const SizedBox(height: 10),
        const Text(
          'Search across every WALKA color and collection, then continue directly into the product experience.',
          style: WalkaType.body,
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: _DiscoveryCard(
                icon: Icons.grid_view_rounded,
                eyebrow: 'HOME',
                title: 'Drawer\norganization',
                tone: WalkaColors.navy,
                foreground: Colors.white,
                onTap: () => onQuery('drawer organizer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DiscoveryCard(
                icon: Icons.lunch_dining_rounded,
                eyebrow: 'EVERYDAY',
                title: 'Lunch\ncollection',
                tone: const Color(0xFFE6EDF2),
                foreground: WalkaColors.navy,
                onTap: () => onQuery('lunch box'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.tone,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final Color tone;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tone,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 168,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icon, color: WalkaColors.gold, size: 22),
                    const Spacer(),
                    Icon(Icons.arrow_outward_rounded, color: foreground, size: 19),
                  ],
                ),
                const Spacer(),
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: WalkaColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: foreground,
                    fontSize: 22,
                    height: 1.03,
                    fontWeight: FontWeight.w600,
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

class _TermSection extends StatelessWidget {
  const _TermSection({
    required this.eyebrow,
    required this.title,
    required this.terms,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final List<String> terms;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            color: WalkaColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: terms.map((String term) {
            return ActionChip(
              onPressed: () => onTap(term),
              avatar: const Icon(Icons.north_west_rounded, size: 14),
              label: Text(term),
              backgroundColor: Colors.white,
              side: const BorderSide(color: WalkaColors.line),
              labelStyle: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ResultsToolbar extends StatelessWidget {
  const _ResultsToolbar({
    required this.resultCount,
    required this.collection,
    required this.sort,
    required this.onFilter,
    required this.onSort,
  });

  final int resultCount;
  final WalkaSearchCollection collection;
  final WalkaSearchSort sort;
  final VoidCallback onFilter;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('SEARCH RESULTS', style: WalkaType.eyebrow),
                  const SizedBox(height: 6),
                  Text(
                    '$resultCount ${resultCount == 1 ? 'result' : 'results'}',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: WalkaColors.navy,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              collection == WalkaSearchCollection.all
                  ? sort.label
                  : '${collection.label} · ${sort.label}',
              style: const TextStyle(
                color: WalkaColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFilter,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text(
                  collection == WalkaSearchCollection.all
                      ? 'FILTER'
                      : 'FILTER · ${collection.label.toUpperCase()}',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSort,
                icon: const Icon(Icons.swap_vert_rounded, size: 18),
                label: const Text('SORT'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({required this.product, required this.onTap});

  final WalkaSearchProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tone = product.collection == WalkaSearchCollection.drawer
        ? (product.drawerGray
            ? const Color(0xFFE5E7EA)
            : const Color(0xFFF6F3EC))
        : (product.lunchVariant ?? WalkaLunchVariant.blue).surface;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: WalkaColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: tone,
                  alignment: Alignment.center,
                  child: _SearchArtwork(product: product),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 13, 13, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.collection == WalkaSearchCollection.drawer
                          ? 'DRAWER ORGANIZATION'
                          : 'LUNCH COLLECTION',
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _productSwatch(product),
                            shape: BoxShape.circle,
                            border: Border.all(color: WalkaColors.line),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            product.colorLabel,
                            style: const TextStyle(
                              color: WalkaColors.navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: WalkaColors.gold,
                          size: 16,
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

  static Color _productSwatch(WalkaSearchProduct product) {
    if (product.collection == WalkaSearchCollection.drawer) {
      return product.drawerGray ? const Color(0xFF9AA0A6) : Colors.white;
    }
    return (product.lunchVariant ?? WalkaLunchVariant.blue).color;
  }
}

class _SearchArtwork extends StatelessWidget {
  const _SearchArtwork({required this.product});

  final WalkaSearchProduct product;

  @override
  Widget build(BuildContext context) {
    if (product.collection == WalkaSearchCollection.drawer) {
      return Transform.rotate(
        angle: -0.07,
        child: Container(
          width: 125,
          height: 88,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: product.drawerGray
                ? const Color(0xFFB5B9BD)
                : const Color(0xFFFCFCF9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 12,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(child: _ArtworkCell(gray: product.drawerGray)),
                    const SizedBox(height: 4),
                    Expanded(child: _ArtworkCell(gray: product.drawerGray)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Expanded(child: _ArtworkCell(gray: product.drawerGray)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: _ArtworkCell(gray: product.drawerGray)),
                          const SizedBox(width: 4),
                          Expanded(child: _ArtworkCell(gray: product.drawerGray)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final WalkaLunchVariant variant =
        product.lunchVariant ?? WalkaLunchVariant.blue;
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        width: 130,
        height: 76,
        decoration: BoxDecoration(
          color: variant.color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 12,
              offset: Offset(0, 7),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
          ),
        ),
      ),
    );
  }
}

class _ArtworkCell extends StatelessWidget {
  const _ArtworkCell({required this.gray});

  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gray ? const Color(0xFFC8CBCE) : const Color(0xFFE9EBE8),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 28, 30, 46),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: WalkaColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: WalkaColors.navy,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nothing matched that search',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                color: WalkaColors.navy,
                fontSize: 27,
                height: 1.08,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              query.trim().isEmpty
                  ? 'Try another collection or reset your filters.'
                  : 'We could not find “${query.trim()}”. Try a color, collection or product detail.',
              textAlign: TextAlign.center,
              style: WalkaType.body,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 190,
              child: ElevatedButton(
                onPressed: onClear,
                child: const Text('CLEAR SEARCH'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
