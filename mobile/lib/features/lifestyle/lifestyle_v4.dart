import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../storefront/storefront_v2.dart';

class WalkaFavoritesV4 extends StatefulWidget {
  const WalkaFavoritesV4({super.key});

  @override
  State<WalkaFavoritesV4> createState() => _WalkaFavoritesV4State();
}

class _WalkaFavoritesV4State extends State<WalkaFavoritesV4> {
  final Set<bool> _savedVariants = <bool>{false, true};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _LifestyleHeader()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('YOUR WALKA EDIT', style: WalkaType.eyebrow),
                  SizedBox(height: 9),
                  Text('Favorites', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Keep the pieces you want to return to in one calm, curated place.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          if (_savedVariants.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _FavoritesEmptyState(
                onExplore: () => DefaultTabController.of(context),
              ),
            )
          else ...<Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: <Widget>[
                    Text(
                      '${_savedVariants.length} SAVED',
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.favorite_rounded,
                      size: 17,
                      color: WalkaColors.gold,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                itemCount: _savedVariants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final bool gray = _savedVariants.elementAt(index);
                  return _FavoriteProductCard(
                    gray: gray,
                    onOpen: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WalkaProductDetailV2(
                            initialGray: gray,
                          ),
                        ),
                      );
                    },
                    onRemove: () => setState(() => _savedVariants.remove(gray)),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 34)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 42),
                child: _WishlistNote(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WalkaAccountV4 extends StatelessWidget {
  const WalkaAccountV4({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
        children: <Widget>[
          const _LifestyleHeader(compact: true),
          const SizedBox(height: 26),
          const Text('WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 9),
          const Text('Account', style: WalkaType.sectionTitle),
          const SizedBox(height: 9),
          const Text(
            'Your place for WALKA information, saved preferences and brand support.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 24),
          const _AccountHeroCard(),
          const SizedBox(height: 28),
          const _AccountSectionLabel('DISCOVER WALKA'),
          const SizedBox(height: 8),
          _AccountActionTile(
            icon: Icons.auto_stories_outlined,
            title: 'Our Story',
            subtitle: 'Design philosophy and the WALKA approach',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const WalkaAboutV4()),
              );
            },
          ),
          const SizedBox(height: 10),
          _AccountActionTile(
            icon: Icons.storefront_outlined,
            title: 'WALKA on Amazon',
            subtitle: 'Official storefront and product listings',
            trailing: Icons.north_east_rounded,
            onTap: () {},
          ),
          const SizedBox(height: 26),
          const _AccountSectionLabel('HELP & INFORMATION'),
          const SizedBox(height: 8),
          _AccountActionTile(
            icon: Icons.mail_outline_rounded,
            title: 'Contact WALKA',
            subtitle: 'Questions, product support and feedback',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _AccountActionTile(
            icon: Icons.shield_outlined,
            title: 'Privacy & Terms',
            subtitle: 'Policies and legal information',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _AccountActionTile(
            icon: Icons.info_outline_rounded,
            title: 'App Information',
            subtitle: 'WALKA mobile preview · version 0.4.0',
            onTap: () {},
          ),
          const SizedBox(height: 28),
          const _AmazonAccountNote(),
        ],
      ),
    );
  }
}

class WalkaAboutV4 extends StatelessWidget {
  const WalkaAboutV4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _LifestyleWordmark(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 44),
        children: <Widget>[
          const _AboutHero(),
          const SizedBox(height: 34),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('OUR POINT OF VIEW', style: WalkaType.eyebrow),
                SizedBox(height: 9),
                Text('A calmer home begins with thoughtful details.',
                    style: WalkaType.sectionTitle),
                SizedBox(height: 13),
                Text(
                  'WALKA creates organization essentials that balance practical function with a refined visual language. We believe useful objects should make everyday spaces easier to live with and quieter to look at.',
                  style: WalkaType.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const _ValuesPanel(),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('HOW WE DESIGN', style: WalkaType.eyebrow),
                SizedBox(height: 9),
                Text('Simple choices, made deliberately.',
                    style: WalkaType.sectionTitle),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _DesignPrinciple(
            number: '01',
            title: 'Useful first',
            body:
                'Every WALKA product starts with the routine it needs to improve, then removes unnecessary complexity.',
          ),
          const SizedBox(height: 12),
          const _DesignPrinciple(
            number: '02',
            title: 'Calm by design',
            body:
                'Clean proportions, restrained color and considered details help products sit naturally in the home.',
          ),
          const SizedBox(height: 12),
          const _DesignPrinciple(
            number: '03',
            title: 'Made for repetition',
            body:
                'The best organization products quietly support everyday habits and remain easy to use again and again.',
          ),
          const SizedBox(height: 32),
          const _AboutClosingPanel(),
        ],
      ),
    );
  }
}

class _LifestyleHeader extends StatelessWidget {
  const _LifestyleHeader({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 34 : 52,
      child: Row(
        children: <Widget>[
          const _LifestyleWordmark(),
          const Spacer(),
          if (!compact)
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

class _FavoriteProductCard extends StatelessWidget {
  const _FavoriteProductCard({
    required this.gray,
    required this.onOpen,
    required this.onRemove,
  });

  final bool gray;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final Color background = gray
        ? const Color(0xFFE0E3E6)
        : const Color(0xFFF5F2EA);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
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
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(19),
                        ),
                      ),
                      child: Center(
                        child: _LifestyleOrganizer(width: 118, gray: gray),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        onPressed: onRemove,
                        tooltip: 'Remove favorite',
                        icon: const Icon(Icons.favorite_rounded, size: 19),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                          foregroundColor: WalkaColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Expandable Drawer Organizer',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 16,
                        height: 1.08,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${gray ? 'Gray' : 'White'} · 8 compartments',
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Row(
                      children: <Widget>[
                        Text(
                          'VIEW PRODUCT',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
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

class _FavoritesEmptyState extends StatelessWidget {
  const _FavoritesEmptyState({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 94,
            height: 94,
            decoration: const BoxDecoration(
              color: WalkaColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: WalkaColors.navy,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your edit is ready for something beautiful.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              color: WalkaColors.navy,
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 11),
          const Text(
            'Save WALKA pieces to keep your favorites together.',
            textAlign: TextAlign.center,
            style: WalkaType.body,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 220,
            child: OutlinedButton(
              onPressed: onExplore,
              child: const Text('EXPLORE COLLECTIONS'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistNote extends StatelessWidget {
  const _WishlistNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.bookmark_outline_rounded, color: WalkaColors.navy),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'YOUR WALKA EDIT',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Favorites are local visual state in Phase 1. Persistence will be connected in a later functional phase.',
                  style: TextStyle(
                    color: Color(0xFF435167),
                    fontSize: 11,
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

class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: WalkaColors.gold,
            child: Icon(
              Icons.person_outline_rounded,
              color: WalkaColors.navy,
              size: 27,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Welcome to WALKA',
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'A premium storefront preview. No sign-in required in Phase 1.',
                  style: TextStyle(
                    color: Color(0xFFBBC9D6),
                    fontSize: 11,
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

class _AccountSectionLabel extends StatelessWidget {
  const _AccountSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: WalkaColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _AccountActionTile extends StatelessWidget {
  const _AccountActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing = Icons.chevron_right_rounded,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
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
                child: Icon(icon, color: WalkaColors.navy, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(trailing, color: WalkaColors.gold, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmazonAccountNote extends StatelessWidget {
  const _AmazonAccountNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.shopping_bag_outlined, color: WalkaColors.navy),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Purchases will be completed through Amazon once external linking is enabled.',
              style: TextStyle(
                color: Color(0xFF425167),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -55,
            top: -20,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: WalkaColors.gold.withValues(alpha: 0.22),
                  width: 42,
                ),
              ),
            ),
          ),
          const Positioned(
            right: 20,
            bottom: 30,
            child: _LifestyleOrganizer(width: 165),
          ),
          const Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('OUR STORY', style: WalkaType.eyebrow),
                SizedBox(height: 13),
                SizedBox(
                  width: 265,
                  child: Text(
                    'Less clutter.\nMore room to live.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 36,
                      height: 1.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 14),
                SizedBox(
                  width: 250,
                  child: Text(
                    'WALKA makes everyday organization feel considered, useful and beautifully simple.',
                    style: TextStyle(
                      color: Color(0xFFD1DCE6),
                      fontSize: 13,
                      height: 1.5,
                    ),
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

class _ValuesPanel extends StatelessWidget {
  const _ValuesPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'THE WALKA STANDARD',
            style: TextStyle(
              color: WalkaColors.navy,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          SizedBox(height: 14),
          _ValueRow(
            icon: Icons.tune_rounded,
            title: 'Purposeful',
            description: 'Function leads every design decision.',
          ),
          SizedBox(height: 15),
          _ValueRow(
            icon: Icons.auto_awesome_outlined,
            title: 'Refined',
            description: 'Clean forms keep everyday spaces visually calm.',
          ),
          SizedBox(height: 15),
          _ValueRow(
            icon: Icons.favorite_border_rounded,
            title: 'Everyday',
            description: 'Made to support routines you repeat without friction.',
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: WalkaColors.navy, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF49586B),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesignPrinciple extends StatelessWidget {
  const _DesignPrinciple({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            number,
            style: const TextStyle(
              color: WalkaColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: WalkaColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(body, style: WalkaType.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutClosingPanel extends StatelessWidget {
  const _AboutClosingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('WALKA', style: WalkaType.eyebrow),
          SizedBox(height: 11),
          Text(
            'Beautiful spaces begin with thoughtful details.',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Phase 1 establishes the visual experience. Product discovery and purchasing will connect to Amazon after approval.',
            style: TextStyle(
              color: Color(0xFFC4D1DD),
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifestyleOrganizer extends StatelessWidget {
  const _LifestyleOrganizer({required this.width, this.gray = false});

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
            color: gray ? const Color(0xFF7D838A) : const Color(0xFFDCD8CE),
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x240F172A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(flex: 2, child: _LifestyleCompartment(color: inner)),
            SizedBox(width: width * 0.024),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _LifestyleCompartment(color: inner)),
                  SizedBox(height: width * 0.02),
                  Expanded(child: _LifestyleCompartment(color: inner)),
                  SizedBox(height: width * 0.02),
                  Expanded(child: _LifestyleCompartment(color: inner)),
                ],
              ),
            ),
            SizedBox(width: width * 0.024),
            Expanded(flex: 2, child: _LifestyleCompartment(color: inner)),
          ],
        ),
      ),
    );
  }
}

class _LifestyleCompartment extends StatelessWidget {
  const _LifestyleCompartment({required this.color});

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

class _LifestyleWordmark extends StatelessWidget {
  const _LifestyleWordmark();

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
