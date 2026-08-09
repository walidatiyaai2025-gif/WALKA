import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../lunch/lunch_box_v6.dart';
import '../products/product_experience_v10.dart';

class WalkaCategoriesV10 extends StatelessWidget {
  const WalkaCategoriesV10({super.key, this.onSearch});

  final VoidCallback? onSearch;

  void _openDrawer(BuildContext context, bool gray) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaDrawerProductDetailV10(initialGray: gray),
      ),
    );
  }

  void _openLunch(BuildContext context, WalkaLunchVariant variant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaLunchProductDetailV10(initialVariant: variant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 0),
              child: Row(
                children: <Widget>[
                  const Text(
                    'WALKA',
                    style: TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.8,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onSearch,
                    tooltip: 'Search',
                    icon: const Icon(Icons.search_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: WalkaColors.navy,
                      backgroundColor: WalkaColors.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('SHOP WALKA', style: WalkaType.eyebrow),
                  SizedBox(height: 9),
                  Text('Collections', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Choose a finish, open the full product gallery, and continue to the official Amazon listing.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
              child: _CollectionHeroV10(
                family: _CatalogFamilyV10.drawer,
                eyebrow: 'DRAWER ORGANIZATION',
                title: 'A calmer drawer.',
                description: '8 compartments · expandable 13″–22.4″',
                onTap: () => _openDrawer(context, false),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 13),
              child: _CollectionHeadingV10(
                eyebrow: 'CHOOSE A FINISH',
                title: 'Drawer Organizer',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
              children: <Widget>[
                _VariantCardV10(
                  family: _CatalogFamilyV10.drawer,
                  label: 'White',
                  subtitle: 'Clean, warm neutral',
                  swatch: Colors.white,
                  tone: const Color(0xFFF6F3EC),
                  onTap: () => _openDrawer(context, false),
                ),
                _VariantCardV10(
                  family: _CatalogFamilyV10.drawer,
                  label: 'Gray',
                  subtitle: 'Soft architectural gray',
                  swatch: const Color(0xFF969CA2),
                  tone: const Color(0xFFE2E4E7),
                  onTap: () => _openDrawer(context, true),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: _CollectionHeroV10(
                family: _CatalogFamilyV10.lunch,
                eyebrow: 'LUNCH COLLECTION',
                title: 'Lunch, organized.',
                description: '1200 ml · SUS304 · 4 compartments',
                onTap: () => _openLunch(context, WalkaLunchVariant.blue),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 13),
              child: _CollectionHeadingV10(
                eyebrow: 'CHOOSE A COLOR',
                title: 'Lunch Box',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 42),
            sliver: SliverGrid.builder(
              itemCount: WalkaLunchVariant.values.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (BuildContext context, int index) {
                final WalkaLunchVariant variant = WalkaLunchVariant.values[index];
                return _VariantCardV10(
                  family: _CatalogFamilyV10.lunch,
                  label: variant.label,
                  subtitle: variant.pantone,
                  swatch: variant.color,
                  tone: variant.surface,
                  onTap: () => _openLunch(context, variant),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _CatalogFamilyV10 { drawer, lunch }

class _CollectionHeadingV10 extends StatelessWidget {
  const _CollectionHeadingV10({required this.eyebrow, required this.title});
  final String eyebrow;
  final String title;

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
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CollectionHeroV10 extends StatelessWidget {
  const _CollectionHeroV10({
    required this.family,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final _CatalogFamilyV10 family;
  final String eyebrow;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool drawer = family == _CatalogFamilyV10.drawer;
    return Material(
      color: drawer ? WalkaColors.navy : const Color(0xFFE7EEF4),
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 270,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -18,
                bottom: -4,
                child: drawer
                    ? const _DrawerCatalogRenderV10(width: 190, gray: false)
                    : const _LunchCatalogRenderV10(
                        width: 190,
                        variant: WalkaLunchVariant.blue,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(eyebrow, style: WalkaType.eyebrow),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: drawer ? Colors.white : WalkaColors.navy,
                          fontSize: 31,
                          height: 1.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 195,
                      child: Text(
                        description,
                        style: TextStyle(
                          color: drawer
                              ? const Color(0xFFC8D4DF)
                              : WalkaColors.muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Text(
                          'OPEN PRODUCT EXPERIENCE',
                          style: TextStyle(
                            color: drawer ? Colors.white : WalkaColors.navy,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
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

class _VariantCardV10 extends StatelessWidget {
  const _VariantCardV10({
    required this.family,
    required this.label,
    required this.subtitle,
    required this.swatch,
    required this.tone,
    required this.onTap,
  });

  final _CatalogFamilyV10 family;
  final String label;
  final String subtitle;
  final Color swatch;
  final Color tone;
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
                  child: family == _CatalogFamilyV10.drawer
                      ? _DrawerCatalogRenderV10(
                          width: 130,
                          gray: label == 'Gray',
                        )
                      : _LunchCatalogRenderV10(
                          width: 130,
                          variant: WalkaLunchVariant.values.firstWhere(
                            (item) => item.label == label,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: swatch,
                            shape: BoxShape.circle,
                            border: Border.all(color: WalkaColors.line),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          label,
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 9,
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

class _DrawerCatalogRenderV10 extends StatelessWidget {
  const _DrawerCatalogRenderV10({required this.width, required this.gray});
  final double width;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.07,
      child: Container(
        width: width,
        height: width * 0.63,
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: gray ? const Color(0xFF9A9FA5) : const Color(0xFFF9F8F4),
          borderRadius: BorderRadius.circular(width * 0.06),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x2A000000), blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _CellV10(gray: gray)),
                  const SizedBox(height: 5),
                  Expanded(child: _CellV10(gray: gray)),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Expanded(child: _CellV10(gray: gray)),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _CellV10(gray: gray)),
                        const SizedBox(width: 5),
                        Expanded(child: _CellV10(gray: gray)),
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
}

class _CellV10 extends StatelessWidget {
  const _CellV10({required this.gray});
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gray ? const Color(0xFFB6BBC0) : const Color(0xFFE9EAE6),
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}

class _LunchCatalogRenderV10 extends StatelessWidget {
  const _LunchCatalogRenderV10({required this.width, required this.variant});
  final double width;
  final WalkaLunchVariant variant;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        width: width,
        height: width * 0.55,
        decoration: BoxDecoration(
          color: variant.color,
          borderRadius: BorderRadius.circular(width * 0.08),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x2A000000), blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy.withValues(alpha: 0.65),
            fontSize: width * 0.06,
            fontWeight: FontWeight.w900,
            letterSpacing: width * 0.012,
          ),
        ),
      ),
    );
  }
}
