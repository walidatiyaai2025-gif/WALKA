import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../lunch/lunch_box_v6.dart';
import '../products/product_experience_v10.dart';

class WalkaHomeV100 extends StatelessWidget {
  const WalkaHomeV100({super.key, this.onExploreAll});

  final VoidCallback? onExploreAll;

  void _openDrawer(BuildContext context, {bool gray = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaDrawerProductDetailV10(initialGray: gray),
      ),
    );
  }

  void _openLunch(
    BuildContext context, {
    WalkaLunchVariant variant = WalkaLunchVariant.blue,
  }) {
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
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.6,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onExploreAll,
                    child: const Text('SHOP ALL'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: _HomeHero(onTap: () => _openDrawer(context)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('THE WALKA EDIT', style: WalkaType.eyebrow),
                        SizedBox(height: 7),
                        Text('Designed for daily order', style: WalkaType.sectionTitle),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onExploreAll,
                    child: const Text('VIEW ALL'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 310,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  _HomeProductCard(
                    eyebrow: 'DRAWER ORGANIZATION',
                    title: 'Expandable Drawer Organizer',
                    variant: 'WHITE',
                    tone: const Color(0xFFF6F3EC),
                    artwork: const _DrawerHomeArtwork(gray: false),
                    onTap: () => _openDrawer(context),
                  ),
                  const SizedBox(width: 12),
                  _HomeProductCard(
                    eyebrow: 'DRAWER ORGANIZATION',
                    title: 'Expandable Drawer Organizer',
                    variant: 'GRAY',
                    tone: const Color(0xFFE1E3E6),
                    artwork: const _DrawerHomeArtwork(gray: true),
                    onTap: () => _openDrawer(context, gray: true),
                  ),
                  const SizedBox(width: 12),
                  _HomeProductCard(
                    eyebrow: 'LUNCH COLLECTION',
                    title: 'Large Stainless Steel Bento Lunch Box',
                    variant: 'BLUE',
                    tone: WalkaLunchVariant.blue.surface,
                    artwork: const _LunchHomeArtwork(
                      variant: WalkaLunchVariant.blue,
                    ),
                    onTap: () => _openLunch(context),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: _LunchFeature(onTap: () => _openLunch(context)),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 34, 20, 0),
              child: _WhyWalka(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 42)),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.navy,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 430,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -46,
                bottom: 22,
                child: Transform.rotate(
                  angle: -0.08,
                  child: const _DrawerHomeArtwork(
                    gray: false,
                    width: 280,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('PREMIUM HOME ORGANIZATION', style: WalkaType.eyebrow),
                    SizedBox(height: 13),
                    SizedBox(
                      width: 270,
                      child: Text(
                        'Order, without the noise.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: Colors.white,
                          fontSize: 41,
                          height: 1.02,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                    SizedBox(height: 13),
                    SizedBox(
                      width: 255,
                      child: Text(
                        'Thoughtful everyday organization in a calm, refined WALKA language.',
                        style: TextStyle(
                          color: Color(0xFFC8D4DF),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        Text(
                          'DISCOVER THE DRAWER EDIT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
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

class _HomeProductCard extends StatelessWidget {
  const _HomeProductCard({
    required this.eyebrow,
    required this.title,
    required this.variant,
    required this.tone,
    required this.artwork,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String variant;
  final Color tone;
  final Widget artwork;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 215,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
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
                    color: tone,
                    alignment: Alignment.center,
                    child: artwork,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color: WalkaColors.gold,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: <Widget>[
                          Text(
                            variant,
                            style: const TextStyle(
                              color: WalkaColors.muted,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const Spacer(),
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
      ),
    );
  }
}

class _LunchFeature extends StatelessWidget {
  const _LunchFeature({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE7EEF4),
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 330,
          child: Stack(
            children: <Widget>[
              const Positioned(
                right: -10,
                bottom: 16,
                child: _LunchHomeArtwork(
                  variant: WalkaLunchVariant.blue,
                  width: 220,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('LUNCH COLLECTION', style: WalkaType.eyebrow),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 210,
                      child: Text(
                        'A complete lunch system, refined.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: WalkaColors.navy,
                          fontSize: 31,
                          height: 1.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 205,
                      child: Text(
                        '1200 ml · SUS304 · Blue, Pink and Green.',
                        style: TextStyle(
                          color: WalkaColors.muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: <Widget>[
                        Text(
                          'EXPLORE LUNCH',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
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

class _WhyWalka extends StatelessWidget {
  const _WhyWalka();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('WHY WALKA', style: WalkaType.eyebrow),
        const SizedBox(height: 8),
        const Text('Useful forms. Refined details.', style: WalkaType.sectionTitle),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            Expanded(
              child: _ValueCard(
                icon: Icons.design_services_outlined,
                title: 'Thoughtful',
                body: 'Designed around real everyday routines.',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ValueCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Refined',
                body: 'Calm materials, finishes and visual language.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: WalkaColors.gold, size: 23),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              color: WalkaColors.muted,
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHomeArtwork extends StatelessWidget {
  const _DrawerHomeArtwork({required this.gray, this.width = 150});
  final bool gray;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.64,
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: gray ? const Color(0xFF9A9FA5) : const Color(0xFFF9F8F4),
        borderRadius: BorderRadius.circular(width * 0.06),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x30000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Expanded(child: _DrawerCell(gray: gray)),
                SizedBox(height: width * 0.025),
                Expanded(child: _DrawerCell(gray: gray)),
              ],
            ),
          ),
          SizedBox(width: width * 0.025),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Expanded(child: _DrawerCell(gray: gray)),
                SizedBox(height: width * 0.025),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _DrawerCell(gray: gray)),
                      SizedBox(width: width * 0.025),
                      Expanded(child: _DrawerCell(gray: gray)),
                    ],
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

class _DrawerCell extends StatelessWidget {
  const _DrawerCell({required this.gray});
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gray ? const Color(0xFFB5BABF) : const Color(0xFFE9EAE6),
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}

class _LunchHomeArtwork extends StatelessWidget {
  const _LunchHomeArtwork({required this.variant, this.width = 150});
  final WalkaLunchVariant variant;
  final double width;

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
            BoxShadow(color: Color(0x30000000), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy.withValues(alpha: 0.62),
            fontSize: width * 0.06,
            fontWeight: FontWeight.w900,
            letterSpacing: width * 0.012,
          ),
        ),
      ),
    );
  }
}
