import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../storefront/storefront_v2.dart';

class WalkaCategoriesV3 extends StatelessWidget {
  const WalkaCategoriesV3({super.key});

  void _openDrawerCollection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalkaCollectionScreenV3(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _CatalogHeader()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('SHOP WALKA', style: WalkaType.eyebrow),
                  SizedBox(height: 9),
                  Text('Collections', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Thoughtful organization for kitchens, drawers and everyday routines.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: _FeaturedCollectionCard(
                onTap: () => _openDrawerCollection(context),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'EXPLORE BY ROUTINE',
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate.fixed(<Widget>[
                _SmallCollectionCard(
                  eyebrow: 'MEAL PREP',
                  title: 'Lunch\nCollection',
                  icon: Icons.lunch_dining_outlined,
                  background: const Color(0xFFE7EEF5),
                  onTap: () {},
                ),
                _SmallCollectionCard(
                  eyebrow: 'EVERYDAY CALM',
                  title: 'The Home\nEdit',
                  icon: Icons.home_outlined,
                  background: const Color(0xFFF0E7C9),
                  onTap: () {},
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.86,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 42),
              child: _CatalogPromise(),
            ),
          ),
        ],
      ),
    );
  }
}

class WalkaCollectionScreenV3 extends StatefulWidget {
  const WalkaCollectionScreenV3({super.key});

  @override
  State<WalkaCollectionScreenV3> createState() =>
      _WalkaCollectionScreenV3State();
}

class _WalkaCollectionScreenV3State extends State<WalkaCollectionScreenV3> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final List<_CatalogProduct> visibleProducts = switch (_selectedFilter) {
      1 => const <_CatalogProduct>[
          _CatalogProduct(
            title: 'Expandable Drawer Organizer',
            variant: 'White',
            gray: false,
          ),
        ],
      2 => const <_CatalogProduct>[
          _CatalogProduct(
            title: 'Expandable Drawer Organizer',
            variant: 'Gray',
            gray: true,
          ),
        ],
      _ => const <_CatalogProduct>[
          _CatalogProduct(
            title: 'Expandable Drawer Organizer',
            variant: 'White',
            gray: false,
          ),
          _CatalogProduct(
            title: 'Expandable Drawer Organizer',
            variant: 'Gray',
            gray: true,
          ),
        ],
    };

    return Scaffold(
      appBar: AppBar(
        title: const _CatalogWordmark(),
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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _CollectionIntro(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _FilterChip(
                            label: 'All',
                            selected: _selectedFilter == 0,
                            onTap: () => setState(() => _selectedFilter = 0),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'White',
                            selected: _selectedFilter == 1,
                            onTap: () => setState(() => _selectedFilter = 1),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Gray',
                            selected: _selectedFilter == 2,
                            onTap: () => setState(() => _selectedFilter = 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    tooltip: 'Sort',
                    icon: const Icon(Icons.tune_rounded),
                    style: IconButton.styleFrom(
                      foregroundColor: WalkaColors.navy,
                      backgroundColor: WalkaColors.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.builder(
              itemCount: visibleProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.66,
              ),
              itemBuilder: (BuildContext context, int index) {
                final _CatalogProduct product = visibleProducts[index];
                return _CatalogProductCard(
                  product: product,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WalkaProductDetailV2(
                          initialGray: product.gray,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 34)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 42),
              child: _CollectionWhyWalka(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 0),
      child: Row(
        children: <Widget>[
          const _CatalogWordmark(),
          const Spacer(),
          IconButton(
            onPressed: () {},
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            style: IconButton.styleFrom(
              foregroundColor: WalkaColors.navy,
              backgroundColor: WalkaColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCollectionCard extends StatelessWidget {
  const _FeaturedCollectionCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.navy,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 360,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -46,
                top: -32,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: WalkaColors.gold.withValues(alpha: 0.22),
                      width: 34,
                    ),
                  ),
                ),
              ),
              const Positioned(
                right: 20,
                bottom: 26,
                child: _CatalogOrganizer(width: 172),
              ),
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('01 · FEATURED COLLECTION', style: WalkaType.eyebrow),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 250,
                      child: Text(
                        'Drawer\nOrganization',
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: Colors.white,
                          fontSize: 34,
                          height: 1.02,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: 230,
                      child: Text(
                        'Expandable organization designed for cutlery, utensils and everyday essentials.',
                        style: TextStyle(
                          color: Color(0xFFD2DCE6),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        Text(
                          'SHOP COLLECTION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: WalkaColors.gold,
                          size: 18,
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

class _SmallCollectionCard extends StatelessWidget {
  const _SmallCollectionCard({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: WalkaColors.navy, size: 21),
              ),
              const Spacer(),
              Text(
                eyebrow,
                style: const TextStyle(
                  color: WalkaColors.gold,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'serif',
                  color: WalkaColors.navy,
                  fontSize: 21,
                  height: 1.02,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.arrow_forward_rounded,
                color: WalkaColors.navy,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogPromise extends StatelessWidget {
  const _CatalogPromise();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.auto_awesome_outlined, color: WalkaColors.gold),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'THE WALKA STANDARD',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Useful forms, refined finishes and practical details.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 12,
                    height: 1.4,
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

class _CollectionIntro extends StatelessWidget {
  const _CollectionIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('DRAWER ORGANIZATION', style: WalkaType.eyebrow),
        const SizedBox(height: 9),
        const Text('Designed for a calmer drawer', style: WalkaType.sectionTitle),
        const SizedBox(height: 10),
        const Text(
          'Expandable organizers with clear compartments, generous capacity and a stable non-slip base.',
          style: WalkaType.body,
        ),
        const SizedBox(height: 20),
        Container(
          height: 164,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0E8),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(child: _CatalogOrganizer(width: 220)),
        ),
        const SizedBox(height: 13),
        const Text(
          '2 COLOR OPTIONS',
          style: TextStyle(
            color: WalkaColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? WalkaColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? WalkaColors.navy : WalkaColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : WalkaColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CatalogProductCard extends StatelessWidget {
  const _CatalogProductCard({required this.product, required this.onTap});

  final _CatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = product.gray
        ? const Color(0xFFE1E4E7)
        : const Color(0xFFF5F2EA);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19),
                    ),
                  ),
                  child: Center(
                    child: _CatalogOrganizer(
                      width: 116,
                      gray: product.gray,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 16,
                        height: 1.08,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${product.variant} · 8 compartments',
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: <Widget>[
                        Text(
                          'VIEW',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: WalkaColors.gold,
                          size: 14,
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

class _CollectionWhyWalka extends StatelessWidget {
  const _CollectionWhyWalka();

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
          Text('WHY WALKA', style: WalkaType.eyebrow),
          SizedBox(height: 11),
          Text(
            'Flexible by design.',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 14),
          _BenefitRow(
            icon: Icons.open_in_full_rounded,
            text: 'Expands from 13″ to 22.4″',
          ),
          SizedBox(height: 10),
          _BenefitRow(
            icon: Icons.grid_view_rounded,
            text: 'Eight practical compartments',
          ),
          SizedBox(height: 10),
          _BenefitRow(
            icon: Icons.layers_outlined,
            text: 'Stable non-slip base',
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: WalkaColors.gold, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFFD3DEE8), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _CatalogOrganizer extends StatelessWidget {
  const _CatalogOrganizer({required this.width, this.gray = false});

  final double width;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    final Color shell = gray
        ? const Color(0xFF989DA4)
        : const Color(0xFFF8F7F2);
    final Color inner = gray
        ? const Color(0xFFB0B5BB)
        : Colors.white;

    return Transform.rotate(
      angle: -0.035,
      child: Container(
        width: width,
        height: width * 0.66,
        padding: EdgeInsets.all(width * 0.045),
        decoration: BoxDecoration(
          color: shell,
          borderRadius: BorderRadius.circular(width * 0.08),
          border: Border.all(
            color: gray ? const Color(0xFF7C8289) : const Color(0xFFDCD8CE),
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x220F172A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(flex: 2, child: _CatalogCompartment(color: inner)),
            SizedBox(width: width * 0.024),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _CatalogCompartment(color: inner)),
                  SizedBox(height: width * 0.02),
                  Expanded(child: _CatalogCompartment(color: inner)),
                  SizedBox(height: width * 0.02),
                  Expanded(child: _CatalogCompartment(color: inner)),
                ],
              ),
            ),
            SizedBox(width: width * 0.024),
            Expanded(flex: 2, child: _CatalogCompartment(color: inner)),
          ],
        ),
      ),
    );
  }
}

class _CatalogCompartment extends StatelessWidget {
  const _CatalogCompartment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
    );
  }
}

class _CatalogWordmark extends StatelessWidget {
  const _CatalogWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WALKA',
      style: TextStyle(
        color: WalkaColors.navy,
        fontSize: 23,
        fontWeight: FontWeight.w800,
        letterSpacing: 5.2,
      ),
    );
  }
}

class _CatalogProduct {
  const _CatalogProduct({
    required this.title,
    required this.variant,
    required this.gray,
  });

  final String title;
  final String variant;
  final bool gray;
}
