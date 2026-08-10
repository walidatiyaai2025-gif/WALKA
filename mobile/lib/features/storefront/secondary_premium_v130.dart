import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../favorites/favorites_state.dart';
import '../information/information_v102.dart';
import '../lifestyle/lifestyle_v4.dart' show WalkaAboutV4;
import '../products/product_experience_v100.dart';

/// DESIGN-005 premium secondary surfaces.
///
/// Favorites keeps the existing device-local controller/persistence contract.
/// Account keeps the released information/navigation destinations while
/// bringing both tabs into the shared DESIGN-002+ premium visual language.
class WalkaFavoritesPremiumV130 extends StatelessWidget {
  const WalkaFavoritesPremiumV130({required this.onExplore, super.key});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController controller = WalkaFavoritesScope.of(context);
    final List<bool> variants = controller.savedDrawerVariants;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-premium-favorites-scroll'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _SecondaryHeader(
              eyebrow: 'YOUR WALKA EDIT',
              title: 'Favorites',
              body: variants.isEmpty
                  ? 'Save the Drawer Organizer variants you want to revisit. Favorites stay on this device.'
                  : '${variants.length} saved ${variants.length == 1 ? 'variant' : 'variants'} ready to revisit.',
              trailing: variants.isEmpty
                  ? null
                  : _CountBadge(count: variants.length),
            ),
          ),
          if (variants.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  WalkaShellMetrics.horizontalGutter(context),
                  18,
                  WalkaShellMetrics.horizontalGutter(context),
                  34,
                ),
                child: _EmptyFavorites(onExplore: onExplore),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                WalkaShellMetrics.horizontalGutter(context),
                18,
                WalkaShellMetrics.horizontalGutter(context),
                42,
              ),
              sliver: SliverList.separated(
                itemCount: variants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (BuildContext context, int index) {
                  final bool gray = variants[index];
                  return _SavedDrawerCard(
                    gray: gray,
                    onOpen: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WalkaDrawerProductDetailV100(
                            initialGray: gray,
                          ),
                        ),
                      );
                    },
                    onRemove: () async {
                      final bool saved = await controller.removeDrawer(gray: gray);
                      if (!context.mounted || saved) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Favorite could not be updated.'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class WalkaAccountPremiumV130 extends StatelessWidget {
  const WalkaAccountPremiumV130({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        key: const PageStorageKey<String>('walka-premium-account-scroll'),
        padding: EdgeInsets.only(
          bottom: 42,
          left: WalkaShellMetrics.horizontalGutter(context),
          right: WalkaShellMetrics.horizontalGutter(context),
        ),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: WalkaWordmark(compact: true),
          ),
          const SizedBox(height: 24),
          const _AccountHero(),
          SizedBox(height: WalkaShellMetrics.verticalSectionGap(context)),
          _AccountSection(
            eyebrow: 'PRODUCT & SUPPORT',
            children: <Widget>[
              _AccountAction(
                icon: Icons.auto_stories_outlined,
                title: 'Our Story',
                subtitle: 'The thinking behind calmer everyday organization.',
                onTap: () => _push(context, const WalkaAboutV4()),
              ),
              _AccountAction(
                icon: Icons.help_outline_rounded,
                title: 'FAQ',
                subtitle: 'Verified product care, use and purchasing guidance.',
                onTap: () => _push(context, const WalkaFaqV102()),
              ),
              _AccountAction(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Us',
                subtitle: 'Support routes for WALKA and Amazon orders.',
                onTap: () => _push(context, const WalkaContactV102()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _AccountSection(
            eyebrow: 'OFFICIAL DESTINATIONS',
            children: <Widget>[
              _AccountAction(
                icon: Icons.storefront_outlined,
                title: 'Amazon Store',
                subtitle: 'Official WALKA purchase destination.',
                onTap: () => _push(context, const WalkaAmazonStoreV102()),
              ),
              _AccountAction(
                icon: Icons.public_rounded,
                title: 'Follow WALKA',
                subtitle: 'Website and Instagram destinations.',
                onTap: () => _push(context, const WalkaSocialV102()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _AccountSection(
            eyebrow: 'LEGAL & APP',
            children: <Widget>[
              _AccountAction(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'Local Favorites, catalog behavior and external handoffs.',
                onTap: () => _push(
                  context,
                  const WalkaLegalV102(type: WalkaLegalTypeV102.privacy),
                ),
              ),
              _AccountAction(
                icon: Icons.description_outlined,
                title: 'Terms',
                subtitle: 'Product discovery and marketplace boundaries.',
                onTap: () => _push(
                  context,
                  const WalkaLegalV102(type: WalkaLegalTypeV102.terms),
                ),
              ),
              _AccountAction(
                icon: Icons.info_outline_rounded,
                title: 'App Information',
                subtitle: 'Connected catalog · release 1.2.0+120.',
                onTap: () => _push(context, const WalkaAppInfoPremiumV130()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalkaAppInfoPremiumV130 extends StatelessWidget {
  const WalkaAppInfoPremiumV130({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const WalkaWordmark(
          compact: true,
          showDescriptor: false,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            WalkaShellMetrics.horizontalGutter(context),
            14,
            WalkaShellMetrics.horizontalGutter(context),
            42,
          ),
          children: const <Widget>[
            Text('WALKA MOBILE', style: WalkaType.eyebrow),
            SizedBox(height: 8),
            Text('App Information', style: WalkaType.sectionTitle),
            SizedBox(height: 10),
            Text(
              'The current WALKA storefront combines the premium Flutter experience with a versioned catalog integration while keeping purchase on Amazon.',
              style: WalkaType.body,
            ),
            SizedBox(height: 26),
            _AppMetric(label: 'Release', value: '1.2.0+120'),
            _AppMetric(label: 'Platform', value: 'Flutter · Android / iOS'),
            _AppMetric(label: 'Catalog', value: 'Versioned WALKA API + local fallback'),
            _AppMetric(label: 'Purchase model', value: 'Official Amazon handoff'),
            _AppMetric(label: 'Favorites', value: 'Stored on this device'),
            _AppMetric(label: 'Current catalog', value: '5 sellable variants'),
            SizedBox(height: 22),
            _ReleaseNotice(),
          ],
        ),
      ),
    );
  }
}

class _SecondaryHeader extends StatelessWidget {
  const _SecondaryHeader({
    required this.eyebrow,
    required this.title,
    required this.body,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        WalkaShellMetrics.horizontalGutter(context),
        16,
        WalkaShellMetrics.horizontalGutter(context),
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const WalkaWordmark(compact: true),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(eyebrow, style: WalkaType.eyebrow),
                    const SizedBox(height: 7),
                    Text(title, style: WalkaType.sectionTitle),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 9),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(body, style: WalkaType.body),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(WalkaRadius.pill),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WalkaRadius.lg),
        border: Border.all(color: WalkaColors.line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WalkaColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 178,
            color: const Color(0xFFF4F1EA),
            padding: const EdgeInsets.all(18),
            child: const WalkaProductVisual(
              kind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: Color(0xFFF4F1EA),
              backgroundColor: Color(0xFFE8E1D4),
              compact: true,
              semanticLabel: 'WALKA Drawer Organizer preview',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('CURATE YOUR EDIT', style: WalkaType.eyebrow),
                const SizedBox(height: 8),
                const Text(
                  'Save the pieces you want to revisit.',
                  style: WalkaType.sectionTitle,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Favorites are intentionally simple: saved Drawer Organizer variants stay on this device and open directly into the premium product experience.',
                  style: WalkaType.body,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: const Text('EXPLORE COLLECTIONS'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedDrawerCard extends StatelessWidget {
  const _SavedDrawerCard({
    required this.gray,
    required this.onOpen,
    required this.onRemove,
  });

  final bool gray;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String variant = gray ? 'Gray' : 'White';
    final Color productColor = gray
        ? const Color(0xFFD2D6DA)
        : const Color(0xFFF4F1EA);
    final Color backgroundColor = gray
        ? const Color(0xFFE6E8EA)
        : const Color(0xFFEFE9DE);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(WalkaRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: WalkaColors.line),
            borderRadius: BorderRadius.circular(WalkaRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 184,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ColoredBox(
                        color: backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: WalkaProductVisual(
                            kind: WalkaProductVisualKind.drawerOrganizer,
                            primaryColor: productColor,
                            backgroundColor: backgroundColor,
                            compact: true,
                            semanticLabel:
                                'WALKA Drawer Organizer $variant favorite',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.96),
                        shape: const CircleBorder(),
                        child: IconButton(
                          onPressed: onRemove,
                          tooltip: 'Remove $variant from Favorites',
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: WalkaColors.navy,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            variant.toUpperCase(),
                            style: WalkaType.eyebrow,
                          ),
                        ),
                        const Icon(
                          Icons.north_east_rounded,
                          color: WalkaColors.navy,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Expandable Drawer Organizer',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 24,
                        height: 1.08,
                        fontWeight: FontWeight.w600,
                        color: WalkaColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '8 compartments · 13 × 15 × 2 in · expands to 22.4 in · non-slip base',
                      style: WalkaType.body,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onOpen,
                        child: const Text('VIEW PRODUCT'),
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

class _AccountHero extends StatelessWidget {
  const _AccountHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(WalkaRadius.lg),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('YOUR WALKA SPACE', style: WalkaType.eyebrow),
          SizedBox(height: 10),
          Text(
            'Support, story and official destinations.',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 28,
              height: 1.08,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'No account or sign-in is required in this release. Use this space for verified product help, WALKA information and marketplace handoffs.',
            style: TextStyle(
              color: Color(0xFFC9D4DF),
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.eyebrow, required this.children});

  final String eyebrow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(eyebrow, style: WalkaType.eyebrow),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(WalkaRadius.md),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: WalkaColors.line),
              borderRadius: BorderRadius.circular(WalkaRadius.md),
            ),
            child: Column(
              children: List<Widget>.generate(children.length * 2 - 1, (int i) {
                if (i.isOdd) {
                  return const Divider(height: 1, indent: 70, endIndent: 14);
                }
                return children[i ~/ 2];
              }),
            ),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WalkaColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: WalkaColors.navy, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 12.5,
                        height: 1.32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: WalkaColors.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppMetric extends StatelessWidget {
  const _AppMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(WalkaRadius.sm),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: WalkaColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReleaseNotice extends StatelessWidget {
  const _ReleaseNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(WalkaRadius.md),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.verified_outlined, color: WalkaColors.gold, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Stable delivery contract',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Owner-visible Android builds are validated on stable main before the latest verified APK is published.',
                  style: TextStyle(
                    color: Color(0xFFC9D4DF),
                    height: 1.45,
                    fontSize: 13,
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
