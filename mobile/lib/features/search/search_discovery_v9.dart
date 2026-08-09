import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../lunch/lunch_box_v6.dart';
import '../storefront/storefront_v2.dart' show WalkaProductDetailV2;

enum WalkaSearchCollection { all, drawer, lunch }

enum WalkaSearchSort { featured, name, collection }

enum WalkaSearchView { grid, list }

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

class WalkaSearchDiscoveryV9 extends StatefulWidget {
  const WalkaSearchDiscoveryV9({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<WalkaSearchDiscoveryV9> createState() =>
      _WalkaSearchDiscoveryV9State();
}

class _WalkaSearchDiscoveryV9State extends State<WalkaSearchDiscoveryV9> {
  late final TextEditingController _controller;
  late String _query;
  WalkaSearchCollection _collection = WalkaSearchCollection.all;
  WalkaSearchSort _sort = WalkaSearchSort.featured;
  WalkaSearchView _view = WalkaSearchView.grid;
  String? _color;
  final List<String> _recent = <String>['drawer organizer', 'lunch box'];

  static const List<String> _discover = <String>[
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

  bool get _hasSearchState => _query.trim().isNotEmpty ||
      _collection != WalkaSearchCollection.all ||
      _color != null;

  List<WalkaSearchProduct> get _results {
    final String normalized = _query.trim().toLowerCase();
    Iterable<WalkaSearchProduct> items = walkaSearchCatalog;

    if (_collection != WalkaSearchCollection.all) {
      items = items.where((p) => p.collection == _collection);
    }
    if (_color != null) {
      items = items.where((p) => p.colorLabel == _color);
    }
    if (normalized.isNotEmpty) {
      final List<String> tokens = normalized
          .split(RegExp(r'\s+'))
          .where((token) => token.isNotEmpty)
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

    final List<WalkaSearchProduct> results = items.toList();
    switch (_sort) {
      case WalkaSearchSort.featured:
        break;
      case WalkaSearchSort.name:
        results.sort((a, b) {
          final int title = a.title.compareTo(b.title);
          return title == 0 ? a.colorLabel.compareTo(b.colorLabel) : title;
        });
      case WalkaSearchSort.collection:
        results.sort((a, b) {
          final int family = a.collection.index.compareTo(b.collection.index);
          return family == 0 ? a.colorLabel.compareTo(b.colorLabel) : family;
        });
    }
    return results;
  }

  void _remember(String query) {
    final String clean = query.trim();
    if (clean.isEmpty) {
      return;
    }
    setState(() {
      _recent.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
      _recent.insert(0, clean);
      if (_recent.length > 5) {
        _recent.removeLast();
      }
    });
  }

  void _setQuery(String value, {bool remember = false}) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value);
    if (remember) {
      _remember(value);
    }
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _query = '';
      _collection = WalkaSearchCollection.all;
      _sort = WalkaSearchSort.featured;
      _color = null;
    });
  }

  void _openProduct(WalkaSearchProduct product) {
    _remember(_query.isEmpty ? product.colorLabel : _query);
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

  Future<void> _showFilters() async {
    WalkaSearchCollection draftCollection = _collection;
    String? draftColor = _color;
    const List<String> colors = <String>['White', 'Gray', 'Blue', 'Pink', 'Green'];

    final _FilterSelection? selected = await showModalBottomSheet<_FilterSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: WalkaSearchCollection.values.map((value) {
                        final bool selected = draftCollection == value;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(value.label),
                          onSelected: (_) => setSheetState(
                            () => draftCollection = value,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: <Widget>[
                        const Text(
                          'COLOR',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Spacer(),
                        if (draftColor != null)
                          TextButton(
                            onPressed: () => setSheetState(() => draftColor = null),
                            child: const Text('CLEAR'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((String color) {
                        return ChoiceChip(
                          selected: draftColor == color,
                          avatar: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _swatchFor(color),
                              shape: BoxShape.circle,
                              border: Border.all(color: WalkaColors.line),
                            ),
                          ),
                          label: Text(color),
                          onSelected: (bool selected) => setSheetState(
                            () => draftColor = selected ? color : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 26),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(
                        _FilterSelection(draftCollection, draftColor),
                      ),
                      child: const Text('APPLY FILTERS'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _collection = selected.collection;
        _color = selected.color;
      });
    }
  }

  Future<void> _showSort() async {
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
                const SizedBox(height: 12),
                ...WalkaSearchSort.values.map((WalkaSearchSort value) {
                  final bool active = value == _sort;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => Navigator.of(context).pop(value),
                    leading: Icon(
                      active ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: active ? WalkaColors.navy : WalkaColors.muted,
                    ),
                    title: Text(
                      value.label,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: FontWeight.w700,
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
    if (selected != null && mounted) {
      setState(() => _sort = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _query = value),
                  onSubmitted: (value) => _remember(value),
                  decoration: InputDecoration(
                    hintText: 'Search organizers, colors, details…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clear,
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: WalkaColors.navy, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            if (!_hasSearchState) ...<Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: _DiscoveryIntro(onQuery: (q) => _setQuery(q, remember: true)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: _TermSection(
                    eyebrow: 'RECENT',
                    title: 'Pick up where you left off',
                    terms: _recent,
                    onTap: (q) => _setQuery(q, remember: true),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 42),
                  child: _TermSection(
                    eyebrow: 'DISCOVER',
                    title: 'Try a detail or color',
                    terms: _discover,
                    onTap: (q) => _setQuery(q, remember: true),
                  ),
                ),
              ),
            ] else ...<Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: _ResultsToolbar(
                    count: results.length,
                    collection: _collection,
                    color: _color,
                    sort: _sort,
                    view: _view,
                    onFilter: _showFilters,
                    onSort: _showSort,
                    onViewChanged: (view) => setState(() => _view = view),
                  ),
                ),
              ),
              if (results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NoResults(query: _query, onClear: _clear),
                )
              else if (_view == WalkaSearchView.grid)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final WalkaSearchProduct product = results[index];
                        return _ProductCard(
                          product: product,
                          grid: true,
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
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final WalkaSearchProduct product = results[index];
                      return _ProductCard(
                        product: product,
                        grid: false,
                        onTap: () => _openProduct(product),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiscoveryIntro extends StatelessWidget {
  const _DiscoveryIntro({required this.onQuery});

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
                  style: const TextStyle(
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
    required this.count,
    required this.collection,
    required this.color,
    required this.sort,
    required this.view,
    required this.onFilter,
    required this.onSort,
    required this.onViewChanged,
  });

  final int count;
  final WalkaSearchCollection collection;
  final String? color;
  final WalkaSearchSort sort;
  final WalkaSearchView view;
  final VoidCallback onFilter;
  final VoidCallback onSort;
  final ValueChanged<WalkaSearchView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    final bool filtered =
        collection != WalkaSearchCollection.all || color != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('SEARCH RESULTS', style: WalkaType.eyebrow),
                  const SizedBox(height: 6),
                  Text(
                    '$count ${count == 1 ? 'result' : 'results'}',
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
            _ViewToggle(view: view, onChanged: onViewChanged),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFilter,
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: Text(filtered ? 'FILTER · ON' : 'FILTER'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSort,
                icon: const Icon(Icons.swap_vert_rounded, size: 18),
                label: Text('SORT · ${sort.label.toUpperCase()}'),
              ),
            ),
          ],
        ),
        if (filtered) ...<Widget>[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              if (collection != WalkaSearchCollection.all)
                _ActiveFilter(label: collection.label),
              if (color != null) _ActiveFilter(label: color!),
            ],
          ),
        ],
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.view, required this.onChanged});

  final WalkaSearchView view;
  final ValueChanged<WalkaSearchView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: WalkaColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          _ViewButton(
            selected: view == WalkaSearchView.grid,
            icon: Icons.grid_view_rounded,
            tooltip: 'Grid view',
            onTap: () => onChanged(WalkaSearchView.grid),
          ),
          _ViewButton(
            selected: view == WalkaSearchView.list,
            icon: Icons.view_agenda_outlined,
            tooltip: 'List view',
            onTap: () => onChanged(WalkaSearchView.list),
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.selected,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        foregroundColor: selected ? Colors.white : WalkaColors.navy,
        backgroundColor: selected ? WalkaColors.navy : Colors.transparent,
      ),
    );
  }
}

class _ActiveFilter extends StatelessWidget {
  const _ActiveFilter({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: WalkaColors.gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.grid,
    required this.onTap,
  });

  final WalkaSearchProduct product;
  final bool grid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tone = _toneFor(product);
    if (!grid) {
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 145,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: WalkaColors.line),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 125,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: _Artwork(product: product, compact: true),
                ),
                const SizedBox(width: 14),
                Expanded(child: _ProductCopy(product: product)),
                const Icon(Icons.arrow_forward_rounded, color: WalkaColors.gold),
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
                  child: _Artwork(product: product),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 13, 13, 14),
                child: _ProductCopy(product: product),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _toneFor(WalkaSearchProduct product) {
    if (product.collection == WalkaSearchCollection.drawer) {
      return product.drawerGray
          ? const Color(0xFFE5E7EA)
          : const Color(0xFFF6F3EC);
    }
    return (product.lunchVariant ?? WalkaLunchVariant.blue).surface;
  }
}

class _ProductCopy extends StatelessWidget {
  const _ProductCopy({required this.product});

  final WalkaSearchProduct product;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        const SizedBox(height: 5),
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
          style: const TextStyle(color: WalkaColors.muted, fontSize: 9),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _swatchFor(product.colorLabel),
                shape: BoxShape.circle,
                border: Border.all(color: WalkaColors.line),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                product.colorLabel,
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.product, this.compact = false});

  final WalkaSearchProduct product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (product.collection == WalkaSearchCollection.drawer) {
      return Transform.rotate(
        angle: -0.07,
        child: Container(
          width: compact ? 95 : 125,
          height: compact ? 66 : 88,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: product.drawerGray
                ? const Color(0xFFB5B9BD)
                : const Color(0xFFFCFCF9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x24000000), blurRadius: 12, offset: Offset(0, 7)),
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(child: _Cell(gray: product.drawerGray)),
                    const SizedBox(height: 4),
                    Expanded(child: _Cell(gray: product.drawerGray)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Expanded(child: _Cell(gray: product.drawerGray)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: _Cell(gray: product.drawerGray)),
                          const SizedBox(width: 4),
                          Expanded(child: _Cell(gray: product.drawerGray)),
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
        width: compact ? 100 : 130,
        height: compact ? 59 : 76,
        decoration: BoxDecoration(
          color: variant.color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x24000000), blurRadius: 12, offset: Offset(0, 7)),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.gray});
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
              child: const Icon(Icons.search_off_rounded, color: WalkaColors.navy, size: 32),
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

class _FilterSelection {
  const _FilterSelection(this.collection, this.color);
  final WalkaSearchCollection collection;
  final String? color;
}

Color _swatchFor(String color) {
  return switch (color) {
    'White' => Colors.white,
    'Gray' => const Color(0xFF9AA0A6),
    'Blue' => WalkaLunchVariant.blue.color,
    'Pink' => WalkaLunchVariant.pink.color,
    'Green' => WalkaLunchVariant.green.color,
    _ => WalkaColors.surface,
  };
}
