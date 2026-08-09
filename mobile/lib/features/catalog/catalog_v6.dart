import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../lunch/lunch_box_v6.dart';
import 'catalog_v3.dart' show WalkaCollectionScreenV3;

class WalkaCategoriesV6 extends StatelessWidget {
  const WalkaCategoriesV6({super.key});

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WalkaCollectionScreenV3()),
    );
  }

  void _openLunch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WalkaLunchCollectionV6()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _CategoryHeader()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('SHOP WALKA', style: WalkaType.eyebrow),
                  SizedBox(height: 9),
                  Text('Collections', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Two everyday systems, designed with the same calm WALKA language.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(<Widget>[
                _CollectionFeatureCard(
                  number: '01',
                  eyebrow: 'DRAWER ORGANIZATION',
                  title: 'A calmer\ndrawer.',
                  description:
                      'Expandable storage for cutlery, utensils and everyday essentials.',
                  background: WalkaColors.navy,
                  foreground: Colors.white,
                  accent: WalkaColors.gold,
                  artwork: const _DrawerArtwork(),
                  onTap: () => _openDrawer(context),
                ),
                const SizedBox(height: 16),
                _CollectionFeatureCard(
                  number: '02',
                  eyebrow: 'LUNCH COLLECTION',
                  title: 'Lunch,\norganized.',
                  description:
                      '1200 ml stainless-steel bento system in Blue, Pink and Green.',
                  background: const Color(0xFFE6EDF2),
                  foreground: WalkaColors.navy,
                  accent: WalkaColors.gold,
                  artwork: const _LunchArtwork(),
                  onTap: () => _openLunch(context),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 42),
              child: _CategoryFooter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
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

class _CollectionFeatureCard extends StatelessWidget {
  const _CollectionFeatureCard({
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.background,
    required this.foreground,
    required this.accent,
    required this.artwork,
    required this.onTap,
  });

  final String number;
  final String eyebrow;
  final String title;
  final String description;
  final Color background;
  final Color foreground;
  final Color accent;
  final Widget artwork;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 355,
          child: Stack(
            children: <Widget>[
              Positioned(right: 8, bottom: 14, child: artwork),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$number · $eyebrow',
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: foreground,
                        fontSize: 35,
                        height: 1.02,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 230,
                      child: Text(
                        description,
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.72),
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Text(
                          'EXPLORE COLLECTION',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Icon(Icons.arrow_forward_rounded, color: accent, size: 18),
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

class _DrawerArtwork extends StatelessWidget {
  const _DrawerArtwork();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        width: 190,
        height: 116,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F4),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x2A000000), blurRadius: 18, offset: Offset(0, 10)),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _DrawerCell()),
                  const SizedBox(height: 5),
                  Expanded(child: _DrawerCell()),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Expanded(child: _DrawerCell()),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _DrawerCell()),
                        const SizedBox(width: 5),
                        Expanded(child: _DrawerCell()),
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

class _DrawerCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EBE8),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _LunchArtwork extends StatelessWidget {
  const _LunchArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 145,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 0,
            top: 4,
            child: _MiniLunchBox(color: const Color(0xFFB6C7A8), angle: 0.07),
          ),
          Positioned(
            right: 58,
            top: 20,
            child: _MiniLunchBox(color: const Color(0xFFE9B8C2), angle: -0.02),
          ),
          Positioned(
            right: 116,
            top: 38,
            child: _MiniLunchBox(color: const Color(0xFF7894A5), angle: -0.09),
          ),
        ],
      ),
    );
  }
}

class _MiniLunchBox extends StatelessWidget {
  const _MiniLunchBox({required this.color, required this.angle});

  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 108,
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x24000000), blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}

class _CategoryFooter extends StatelessWidget {
  const _CategoryFooter();

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
                  'Useful forms, refined finishes and practical details across every collection.',
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
