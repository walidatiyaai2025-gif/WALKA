import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../commerce/amazon_purchase.dart';

enum WalkaLunchVariant { blue, pink, green }

extension WalkaLunchVariantX on WalkaLunchVariant {
  String get label => switch (this) {
        WalkaLunchVariant.blue => 'Blue',
        WalkaLunchVariant.pink => 'Pink',
        WalkaLunchVariant.green => 'Green',
      };

  String get pantone => switch (this) {
        WalkaLunchVariant.blue => 'PANTONE 4155 U',
        WalkaLunchVariant.pink => 'PANTONE 9242 U',
        WalkaLunchVariant.green => 'PANTONE 6198 U',
      };

  Color get color => switch (this) {
        WalkaLunchVariant.blue => const Color(0xFF7894A5),
        WalkaLunchVariant.pink => const Color(0xFFE9B8C2),
        WalkaLunchVariant.green => const Color(0xFFB6C7A8),
      };

  Color get surface => Color.lerp(color, Colors.white, 0.78)!;
}

class WalkaLunchCollectionV6 extends StatelessWidget {
  const WalkaLunchCollectionV6({super.key});

  void _openProduct(BuildContext context, WalkaLunchVariant variant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaLunchProductDetailV6(initialVariant: variant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _WalkaWordmark(),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _LunchCollectionHero()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('CHOOSE YOUR COLOR', style: WalkaType.eyebrow),
                        SizedBox(height: 8),
                        Text('Three calm finishes', style: WalkaType.sectionTitle),
                      ],
                    ),
                  ),
                  Text(
                    '3 OPTIONS',
                    style: TextStyle(
                      color: WalkaColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: WalkaLunchVariant.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (BuildContext context, int index) {
                final WalkaLunchVariant variant = WalkaLunchVariant.values[index];
                return _LunchVariantCard(
                  variant: variant,
                  onTap: () => _openProduct(context, variant),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 42),
              child: _LunchCollectionPromise(),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkaLunchProductDetailV6 extends StatefulWidget {
  const WalkaLunchProductDetailV6({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  State<WalkaLunchProductDetailV6> createState() =>
      _WalkaLunchProductDetailV6State();
}

class _WalkaLunchProductDetailV6State extends State<WalkaLunchProductDetailV6> {
  late WalkaLunchVariant _variant;
  int _galleryIndex = 0;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _variant = widget.initialVariant;
  }

  WalkaAmazonLunchVariant get _amazonVariant => switch (_variant) {
        WalkaLunchVariant.blue => WalkaAmazonLunchVariant.blue,
        WalkaLunchVariant.pink => WalkaAmazonLunchVariant.pink,
        WalkaLunchVariant.green => WalkaAmazonLunchVariant.green,
      };

  Future<void> _openAmazon() async {
    bool opened = false;
    try {
      opened = await openLunchBoxOnAmazon(_amazonVariant);
    } catch (_) {
      opened = false;
    }

    if (!mounted || opened) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Amazon could not be opened. Please try again.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _WalkaWordmark(),
        actions: <Widget>[
          IconButton(
            onPressed: () => setState(() => _favorite = !_favorite),
            tooltip: _favorite ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _favorite ? WalkaColors.gold : WalkaColors.navy,
            ),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'Share product',
            icon: const Icon(Icons.ios_share_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: ElevatedButton.icon(
          onPressed: _openAmazon,
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: const Text('BUY ON AMAZON'),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _LunchGallery(
              variant: _variant,
              index: _galleryIndex,
              onChanged: (int index) => setState(() => _galleryIndex = index),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('WALKA · LUNCH COLLECTION', style: WalkaType.eyebrow),
                  const SizedBox(height: 10),
                  const Text(
                    'Large Stainless Steel Bento Lunch Box',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: WalkaColors.navy,
                      fontSize: 31,
                      height: 1.08,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '4 compartments · 1200 ml · insulated bag, utensils & sauce cup included',
                    style: WalkaType.body,
                  ),
                  const SizedBox(height: 24),
                  _VariantSelector(
                    selected: _variant,
                    onSelected: (WalkaLunchVariant value) {
                      setState(() {
                        _variant = value;
                        _galleryIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  const _UsageCallout(),
                  const SizedBox(height: 28),
                  const _LunchFeatureGrid(),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    eyebrow: 'WHAT IS INCLUDED',
                    title: 'Everything for the routine',
                  ),
                  const SizedBox(height: 16),
                  const _IncludedItems(),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    eyebrow: 'PRODUCT DETAILS',
                    title: 'Measured for everyday meals',
                  ),
                  const SizedBox(height: 16),
                  const _LunchSpecifications(),
                  const SizedBox(height: 30),
                  const _SectionHeading(
                    eyebrow: 'CARE & USE',
                    title: 'Simple care, clear guidance',
                  ),
                  const SizedBox(height: 16),
                  const _CarePanel(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LunchCollectionHero extends StatelessWidget {
  const _LunchCollectionHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 395,
        decoration: BoxDecoration(
          color: WalkaColors.navy,
          borderRadius: BorderRadius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -58,
              top: -48,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: WalkaColors.gold.withValues(alpha: 0.2),
                    width: 40,
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 18,
              bottom: 24,
              child: _LunchBoxRender(
                variant: WalkaLunchVariant.blue,
                width: 235,
                open: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('MEAL PREP · REFINED', style: WalkaType.eyebrow),
                  SizedBox(height: 13),
                  SizedBox(
                    width: 245,
                    child: Text(
                      'Lunch,\norganized.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: Colors.white,
                        fontSize: 38,
                        height: 1.02,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 225,
                    child: Text(
                      'A generous stainless-steel bento designed for adult everyday meals.',
                      style: TextStyle(
                        color: Color(0xFFD2DCE6),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '1200 ML · 4 COMPARTMENTS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
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
}

class _LunchVariantCard extends StatelessWidget {
  const _LunchVariantCard({required this.variant, required this.onTap});

  final WalkaLunchVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 190,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: WalkaColors.line),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: variant.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: _LunchBoxRender(variant: variant, width: 155),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      variant.label.toUpperCase(),
                      style: const TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Large Bento\nLunch Box',
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 22,
                        height: 1.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      variant.pantone,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      children: <Widget>[
                        Text(
                          'VIEW PRODUCT',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: WalkaColors.gold,
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
    );
  }
}

class _LunchGallery extends StatelessWidget {
  const _LunchGallery({
    required this.variant,
    required this.index,
    required this.onChanged,
  });

  final WalkaLunchVariant variant;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<_GalleryMode> modes = <_GalleryMode>[
      _GalleryMode('Complete set', false, false),
      _GalleryMode('Open tray', true, false),
      _GalleryMode('Carry kit', false, true),
    ];
    final _GalleryMode mode = modes[index];

    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: variant.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            children: <Widget>[
              Center(
                child: _LunchBoxRender(
                  variant: variant,
                  width: 285,
                  open: mode.open,
                  carry: mode.carry,
                ),
              ),
              Positioned(
                left: 18,
                top: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    mode.label.toUpperCase(),
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(modes.length, (int i) {
            final bool selected = i == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Semantics(
                button: true,
                selected: selected,
                label: 'Show ${modes[i].label}',
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(99),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 28 : 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: selected ? WalkaColors.navy : WalkaColors.line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _VariantSelector extends StatelessWidget {
  const _VariantSelector({required this.selected, required this.onSelected});

  final WalkaLunchVariant selected;
  final ValueChanged<WalkaLunchVariant> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text(
              'COLOR',
              style: TextStyle(
                color: WalkaColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Text(
              '${selected.label} · ${selected.pantone}',
              style: const TextStyle(
                color: WalkaColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: WalkaLunchVariant.values.map((WalkaLunchVariant variant) {
            final bool active = selected == variant;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: variant == WalkaLunchVariant.green ? 0 : 8,
                ),
                child: Semantics(
                  button: true,
                  selected: active,
                  label: '${variant.label} lunch box',
                  child: InkWell(
                    onTap: () => onSelected(variant),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 66,
                      decoration: BoxDecoration(
                        color: variant.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active ? WalkaColors.navy : Colors.transparent,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: variant.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x16000000),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            variant.label,
                            style: const TextStyle(
                              color: WalkaColors.navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _UsageCallout extends StatelessWidget {
  const _UsageCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.38)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.shield_outlined, color: WalkaColors.gold, size: 25),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'SECURE LOCK · HELPS PREVENT SPILLS',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Best for dry & semi-wet foods. Not intended for liquids. Carry upright.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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

class _LunchFeatureGrid extends StatelessWidget {
  const _LunchFeatureGrid();

  @override
  Widget build(BuildContext context) {
    const List<_Feature> items = <_Feature>[
      _Feature(Icons.grid_view_rounded, '4', 'Compartments'),
      _Feature(Icons.local_drink_outlined, '1200', 'ml capacity'),
      _Feature(Icons.kitchen_outlined, '304', 'Stainless tray'),
      _Feature(Icons.lock_outline_rounded, '4', 'Secure clips'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (BuildContext context, int index) {
        final _Feature item = items[index];
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: WalkaColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: WalkaColors.navy, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.value,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IncludedItems extends StatelessWidget {
  const _IncludedItems();

  @override
  Widget build(BuildContext context) {
    const List<_Included> items = <_Included>[
      _Included(Icons.lunch_dining_outlined, 'Bento box', 'PP outer + SUS304 tray'),
      _Included(Icons.soup_kitchen_outlined, 'Sauce cup', 'Round cup with lid'),
      _Included(Icons.restaurant_rounded, 'Utensils', 'Spoon + fork included'),
      _Included(Icons.shopping_bag_outlined, 'Carry bag', 'Insulated travel bag'),
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Icon(item.icon, color: WalkaColors.gold, size: 22),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.detail,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LunchSpecifications extends StatelessWidget {
  const _LunchSpecifications();

  @override
  Widget build(BuildContext context) {
    const List<(String, String)> rows = <(String, String)>[
      ('Capacity', '1200 ml'),
      ('Lunch box', '11.42 × 8.66 × 3.15 in'),
      ('With bag', '11.81 × 8.86 × 3.54 in'),
      ('Carry bag', '10.63 × 7.48 × 2.76 in'),
      ('Weight with bag', '1.84 lb'),
      ('Tray material', 'SUS304 stainless steel'),
      ('Outer body', 'BPA-free PP'),
      ('Use', 'Adults · dry & semi-wet meals'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        children: List<Widget>.generate(rows.length, (int index) {
          final (String label, String value) = rows[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: index == rows.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: WalkaColors.line)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 110,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: WalkaColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CarePanel extends StatelessWidget {
  const _CarePanel();

  @override
  Widget build(BuildContext context) {
    const List<String> bullets = <String>[
      'Stainless steel tray: dishwasher safe.',
      'Lid and silicone gasket: dishwasher safe, top rack.',
      'Stainless steel tray is not microwave safe.',
      'PP outer body is microwave safe after removing the stainless tray, lid and silicone gasket.',
      'Carry the lunch box upright and avoid liquids.',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: bullets.map((String text) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, color: WalkaColors.gold, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFFD9E1E8),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LunchCollectionPromise extends StatelessWidget {
  const _LunchCollectionPromise();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('DESIGNED FOR ADULT ROUTINES', style: WalkaType.eyebrow),
          SizedBox(height: 9),
          Text(
            'Generous capacity without the visual clutter.',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 24,
              height: 1.08,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'A stainless tray, practical accessories and a calm palette designed to move from kitchen to workday.',
            style: TextStyle(
              color: Color(0xFFD2DCE6),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 8),
        Text(title, style: WalkaType.sectionTitle),
      ],
    );
  }
}

class _WalkaWordmark extends StatelessWidget {
  const _WalkaWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WALKA',
      style: TextStyle(
        color: WalkaColors.navy,
        fontSize: 17,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.6,
      ),
    );
  }
}

class _LunchBoxRender extends StatelessWidget {
  const _LunchBoxRender({
    required this.variant,
    required this.width,
    this.open = false,
    this.carry = false,
  });

  final WalkaLunchVariant variant;
  final double width;
  final bool open;
  final bool carry;

  @override
  Widget build(BuildContext context) {
    final double height = width * 0.56;

    if (carry) {
      return SizedBox(
        width: width,
        height: height * 1.1,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              right: width * 0.02,
              bottom: 0,
              child: Container(
                width: width * 0.7,
                height: height * 0.78,
                decoration: BoxDecoration(
                  color: WalkaColors.navyDark,
                  borderRadius: BorderRadius.circular(width * 0.07),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x25000000), blurRadius: 14, offset: Offset(0, 7)),
                  ],
                ),
                child: Center(
                  child: Text(
                    'WALKA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w800,
                      letterSpacing: width * 0.015,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: _ClosedLunchBody(variant: variant, width: width * 0.65),
            ),
          ],
        ),
      );
    }

    if (open) {
      return SizedBox(
        width: width,
        height: height * 1.2,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 0,
              left: width * 0.1,
              child: Transform.rotate(
                angle: -0.05,
                child: Container(
                  width: width * 0.78,
                  height: height * 0.55,
                  decoration: BoxDecoration(
                    color: variant.color,
                    borderRadius: BorderRadius.circular(width * 0.06),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: width * 0.58,
                      height: height * 0.16,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: _OpenTray(variant: variant, width: width),
            ),
          ],
        ),
      );
    }

    return _ClosedLunchBody(variant: variant, width: width);
  }
}

class _ClosedLunchBody extends StatelessWidget {
  const _ClosedLunchBody({required this.variant, required this.width});

  final WalkaLunchVariant variant;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.54,
      decoration: BoxDecoration(
        color: variant.color,
        borderRadius: BorderRadius.circular(width * 0.075),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: width * 0.07,
            right: width * 0.07,
            top: width * 0.065,
            height: width * 0.055,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Center(
            child: Text(
              'WALKA',
              style: TextStyle(
                color: WalkaColors.navy.withValues(alpha: 0.55),
                fontSize: width * 0.055,
                fontWeight: FontWeight.w900,
                letterSpacing: width * 0.012,
              ),
            ),
          ),
          ...List<Widget>.generate(4, (int index) {
            final bool side = index < 2;
            return Positioned(
              left: side ? width * (index == 0 ? -0.015 : 0.94) : width * (index == 2 ? 0.18 : 0.73),
              top: side ? width * 0.19 : width * 0.47,
              child: Container(
                width: side ? width * 0.065 : width * 0.09,
                height: side ? width * 0.15 : width * 0.055,
                decoration: BoxDecoration(
                  color: WalkaColors.navyDark.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OpenTray extends StatelessWidget {
  const _OpenTray({required this.variant, required this.width});

  final WalkaLunchVariant variant;
  final double width;

  @override
  Widget build(BuildContext context) {
    final double h = width * 0.5;
    return Container(
      width: width,
      height: h,
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: variant.color,
        borderRadius: BorderRadius.circular(width * 0.07),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(width * 0.025),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEE),
          borderRadius: BorderRadius.circular(width * 0.045),
          border: Border.all(color: const Color(0xFFC7CDD1), width: 2),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: _SteelCompartment(radius: width * 0.025),
                  ),
                  SizedBox(height: width * 0.015),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _SteelCompartment(radius: width * 0.022)),
                        SizedBox(width: width * 0.015),
                        Expanded(child: _SteelCompartment(radius: width * 0.022)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: width * 0.015),
            Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  Expanded(child: _SteelCompartment(radius: width * 0.025)),
                  SizedBox(height: width * 0.015),
                  Container(
                    width: width * 0.12,
                    height: width * 0.12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DBDE),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
}

class _SteelCompartment extends StatelessWidget {
  const _SteelCompartment({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFF7F8F8), Color(0xFFD8DDE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

class _GalleryMode {
  const _GalleryMode(this.label, this.open, this.carry);

  final String label;
  final bool open;
  final bool carry;
}

class _Feature {
  const _Feature(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;
}

class _Included {
  const _Included(this.icon, this.title, this.detail);

  final IconData icon;
  final String title;
  final String detail;
}
