import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../information/information_v102.dart';
import 'secondary_premium_v130.dart' show WalkaAppInfoPremiumV130;

/// DESIGN-007B.5 Android-reference Account surface.
///
/// The approved reference contains sample identity, VIP, orders, spend,
/// payment methods and sign-out data. WALKA mobile has no account backend, so
/// this screen keeps the visual hierarchy while exposing only real capabilities.
class WalkaAccountReferenceV131 extends StatelessWidget {
  const WalkaAccountReferenceV131({required this.onFavorites, super.key});

  final VoidCallback onFavorites;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = WalkaShellMetrics.horizontalGutter(context);
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-reference-account-scroll'),
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _AccountTopBar()),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 22, gutter, 0),
            sliver: const SliverToBoxAdapter(child: _AccountIdentity()),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
            sliver: const SliverToBoxAdapter(child: _AccountNotice()),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 0),
            sliver: const SliverToBoxAdapter(child: _AccountOverview()),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _AccountSection(
                title: 'Your WALKA Space',
                children: <Widget>[
                  _AccountAction(
                    icon: Icons.favorite_border_rounded,
                    title: 'Favorites',
                    subtitle: 'Drawer Organizer variants saved on this device',
                    onTap: onFavorites,
                  ),
                  _AccountAction(
                    icon: Icons.auto_stories_outlined,
                    title: 'Our Story',
                    subtitle: 'Thoughtful organization, designed for daily life',
                    onTap: () => _push(context, const WalkaAboutReferenceV131()),
                  ),
                  _AccountAction(
                    icon: Icons.info_outline_rounded,
                    title: 'App Information',
                    subtitle: 'Release, catalog and purchase-boundary details',
                    onTap: () => _push(context, const WalkaAppInfoPremiumV130()),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 22, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _AccountSection(
                title: 'Support & Destinations',
                children: <Widget>[
                  _AccountAction(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQ',
                    subtitle: 'Verified product care, use and purchase guidance',
                    onTap: () => _push(context, const WalkaFaqV102()),
                  ),
                  _AccountAction(
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact Us',
                    subtitle: 'WALKA product support and Amazon order routes',
                    onTap: () => _push(context, const WalkaContactV102()),
                  ),
                  _AccountAction(
                    icon: Icons.storefront_outlined,
                    title: 'Amazon Store',
                    subtitle: 'Official WALKA purchase destination',
                    external: true,
                    onTap: () => _push(context, const WalkaAmazonStoreV102()),
                  ),
                  _AccountAction(
                    icon: Icons.public_rounded,
                    title: 'Follow WALKA',
                    subtitle: 'Website and Instagram destinations',
                    external: true,
                    onTap: () => _push(context, const WalkaSocialV102()),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 22, gutter, 42),
            sliver: SliverToBoxAdapter(
              child: _AccountSection(
                title: 'Privacy & App',
                children: <Widget>[
                  _AccountAction(
                    icon: Icons.shield_outlined,
                    title: 'Privacy',
                    subtitle: 'Local Favorites, catalog behavior and handoffs',
                    onTap: () => _push(
                      context,
                      const WalkaLegalV102(type: WalkaLegalTypeV102.privacy),
                    ),
                  ),
                  _AccountAction(
                    icon: Icons.description_outlined,
                    title: 'Terms',
                    subtitle: 'Discovery and marketplace boundaries',
                    onTap: () => _push(
                      context,
                      const WalkaLegalV102(type: WalkaLegalTypeV102.terms),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTopBar extends StatelessWidget {
  const _AccountTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-account-topbar'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: WalkaColors.line, width: 0.7)),
      ),
      child: const Row(
        children: <Widget>[
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.menu_rounded, color: WalkaColors.navy),
          ),
          Expanded(
            child: Center(
              child: Text(
                'WALKA',
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.person_outline_rounded, color: WalkaColors.gold),
          ),
        ],
      ),
    );
  }
}

class _AccountIdentity extends StatelessWidget {
  const _AccountIdentity();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-account-identity'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF063A70), WalkaColors.navyDark],
              ),
            ),
            child: const Text(
              'W',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your WALKA Space',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 22,
                    height: 1.08,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'No account or sign-in is required.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Favorites stay on this device.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: WalkaColors.gold),
        ],
      ),
    );
  }
}

class _AccountNotice extends StatelessWidget {
  const _AccountNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-account-notice'),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF9EE), Color(0xFFFFFCF7)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.20)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.verified_outlined, color: WalkaColors.gold, size: 27),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Official WALKA destinations',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Discover here. Purchase continues on the official Amazon listing.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 10,
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

class _AccountOverview extends StatelessWidget {
  const _AccountOverview();

  @override
  Widget build(BuildContext context) {
    const List<(IconData, String, String)> items = <(IconData, String, String)>[
      (Icons.person_off_outlined, 'Sign-in', 'Not required'),
      (Icons.inventory_2_outlined, 'Catalog', '5 variants'),
      (Icons.favorite_border_rounded, 'Favorites', 'On device'),
      (Icons.open_in_new_rounded, 'Purchase', 'Amazon'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Account Overview',
          style: TextStyle(
            color: WalkaColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          key: const ValueKey<String>('reference-account-overview'),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WalkaColors.line),
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool twoColumns = constraints.maxWidth < 330;
              final double width = twoColumns
                  ? (constraints.maxWidth - 4) / 2
                  : (constraints.maxWidth - 12) / 4;
              return Wrap(
                spacing: 4,
                runSpacing: 16,
                children: items
                    .map(
                      ((IconData, String, String) item) => SizedBox(
                        width: width,
                        child: Column(
                          children: <Widget>[
                            Icon(item.$1, color: WalkaColors.navy, size: 24),
                            const SizedBox(height: 7),
                            Text(
                              item.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: WalkaColors.navy,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.$3,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: WalkaColors.muted,
                                fontSize: 9,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WalkaColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                children[i],
                if (i != children.length - 1)
                  const Divider(height: 1, color: WalkaColors.line),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.external = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool external;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey<String>(
          'reference-account-${title.toLowerCase().replaceAll(' ', '-')}',
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  shape: BoxShape.circle,
                  border: Border.all(color: WalkaColors.line),
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
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
              Icon(
                external ? Icons.north_east_rounded : Icons.chevron_right_rounded,
                color: WalkaColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// DESIGN-007B.5 Android-reference Our Story / About surface.
class WalkaAboutReferenceV131 extends StatelessWidget {
  const WalkaAboutReferenceV131({super.key});

  @override
  Widget build(BuildContext context) {
    final double gutter = WalkaShellMetrics.horizontalGutter(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy,
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.6,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: WalkaColors.line, width: 0.7),
        ),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          key: const PageStorageKey<String>('walka-reference-about-scroll'),
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
              sliver: const SliverToBoxAdapter(child: _AboutHero()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 32, gutter, 0),
              sliver: const SliverToBoxAdapter(child: _AboutStory()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
              sliver: const SliverToBoxAdapter(child: _AboutValues()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
              sliver: const SliverToBoxAdapter(child: _AboutPrinciples()),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 42),
              sliver: const SliverToBoxAdapter(child: _AboutClosing()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-about-hero'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFF7F0E5), Color(0xFFFFFCF7)],
        ),
        border: Border.all(color: WalkaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('OUR STORY', style: WalkaType.eyebrow),
                SizedBox(height: 9),
                Text(
                  'Organized living.\nElevated everyday.',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontFamily: 'serif',
                    fontSize: 32,
                    height: 1.02,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.45,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Thoughtful organization essentials that make everyday spaces easier to use and calmer to look at.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 196,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: WalkaProductVisual(
                      kind: WalkaProductVisualKind.drawerOrganizer,
                      primaryColor: Color(0xFFF7F4EC),
                      backgroundColor: Color(0xFFF2E7D5),
                      compact: true,
                      semanticLabel: 'WALKA Drawer Organizer story visual',
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: WalkaProductVisual(
                      kind: WalkaProductVisualKind.lunchBox,
                      primaryColor: Color(0xFF7D95AF),
                      backgroundColor: Color(0xFFE6EDF4),
                      compact: true,
                      semanticLabel: 'WALKA Lunch Box story visual',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutStory extends StatelessWidget {
  const _AboutStory();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('OUR POINT OF VIEW', style: WalkaType.eyebrow),
        SizedBox(height: 9),
        Text(
          'A calmer home begins with thoughtful details.',
          style: WalkaType.sectionTitle,
        ),
        SizedBox(height: 13),
        Text(
          'WALKA creates organization essentials that balance practical function with a refined visual language. We believe useful objects should make everyday spaces easier to live with and quieter to look at.',
          style: WalkaType.body,
        ),
      ],
    );
  }
}

class _AboutValues extends StatelessWidget {
  const _AboutValues();

  @override
  Widget build(BuildContext context) {
    const List<(IconData, String, String)> values = <(IconData, String, String)>[
      (
        Icons.tune_rounded,
        'Purposeful',
        'Useful details first, unnecessary complexity removed.',
      ),
      (
        Icons.auto_awesome_outlined,
        'Refined',
        'Clean proportions and restrained visual language.',
      ),
      (
        Icons.repeat_rounded,
        'Everyday',
        'Designed to support routines again and again.',
      ),
    ];
    return Container(
      key: const ValueKey<String>('reference-about-values'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'WHAT GUIDES US',
            style: TextStyle(
              color: WalkaColors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...values.map(
            ((IconData, String, String) value) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(value.$1, color: WalkaColors.gold, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          value.$2,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value.$3,
                          style: const TextStyle(
                            color: Color(0xFFB9C8D6),
                            fontSize: 10.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutPrinciples extends StatelessWidget {
  const _AboutPrinciples();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('HOW WE DESIGN', style: WalkaType.eyebrow),
        SizedBox(height: 9),
        Text('Simple choices, made deliberately.', style: WalkaType.sectionTitle),
        SizedBox(height: 16),
        _Principle(
          number: '01',
          title: 'Useful first',
          body:
              'Every WALKA product starts with the routine it needs to improve, then removes unnecessary complexity.',
        ),
        SizedBox(height: 10),
        _Principle(
          number: '02',
          title: 'Calm by design',
          body:
              'Clean proportions, restrained color and considered details help products sit naturally in the home.',
        ),
        SizedBox(height: 10),
        _Principle(
          number: '03',
          title: 'Made for repetition',
          body:
              'The best organization products quietly support everyday habits and remain easy to use again and again.',
        ),
      ],
    );
  }
}

class _Principle extends StatelessWidget {
  const _Principle({
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            number,
            style: const TextStyle(
              color: WalkaColors.gold,
              fontFamily: 'serif',
              fontSize: 24,
              fontWeight: FontWeight.w600,
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
                    color: WalkaColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 10.5,
                    height: 1.45,
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

class _AboutClosing extends StatelessWidget {
  const _AboutClosing();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-about-closing'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9ED),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.20)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('WALKA', style: WalkaType.eyebrow),
          SizedBox(height: 8),
          Text(
            'Thoughtful pieces for a better organized everyday.',
            style: WalkaType.sectionTitle,
          ),
          SizedBox(height: 10),
          Text(
            'Explore the current collection in the app. When you are ready to purchase, WALKA sends you to the official Amazon listing.',
            style: WalkaType.body,
          ),
        ],
      ),
    );
  }
}
