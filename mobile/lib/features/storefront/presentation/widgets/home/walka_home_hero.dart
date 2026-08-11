import 'package:flutter/material.dart';

import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/lunch/lunch_box_v6.dart';

import 'walka_home_hero_actions.dart';

class WalkaHomeHero extends StatelessWidget {
  const WalkaHomeHero({
    required this.lunchSemanticLabel,
    required this.drawerSemanticLabel,
    required this.onOpenLunch,
    required this.onShopAll,
    required this.onSearch,
    super.key,
  });

  final String lunchSemanticLabel;
  final String drawerSemanticLabel;
  final VoidCallback onOpenLunch;
  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 360;
        final double scale = MediaQuery.textScalerOf(context).scale(1);
        final bool stackContent = compact || scale > 1.15;

        return Material(
          color: const Color(0xFFFFFCF7),
          child: InkWell(
            onTap: onOpenLunch,
            child: Container(
              key: const ValueKey<String>('home-reference-hero'),
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 22,
                compact ? 26 : 30,
                compact ? 18 : 22,
                compact ? 22 : 26,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFFFFEFC),
                    Color(0xFFF8F4EC),
                    Color(0xFFFFFFFF),
                  ],
                ),
              ),
              child: stackContent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _HeroCopy(
                          compact: compact,
                          onShopAll: onShopAll,
                          onSearch: onSearch,
                        ),
                        const SizedBox(height: 20),
                        _HeroVisualStage(
                          height: compact ? 190 : 210,
                          lunchSemanticLabel: lunchSemanticLabel,
                          drawerSemanticLabel: drawerSemanticLabel,
                        ),
                        const SizedBox(height: 14),
                        const _HeroDots(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: _HeroCopy(
                            compact: false,
                            onShopAll: onShopAll,
                            onSearch: onSearch,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: <Widget>[
                              _HeroVisualStage(
                                height: 250,
                                lunchSemanticLabel: lunchSemanticLabel,
                                drawerSemanticLabel: drawerSemanticLabel,
                              ),
                              const SizedBox(height: 12),
                              const _HeroDots(),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.compact,
    required this.onShopAll,
    required this.onSearch,
  });

  final bool compact;
  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'PREMIUM ORGANIZATION\nELEVATED EVERYDAY.',
          style: TextStyle(
            color: WalkaColors.gold,
            fontSize: 10,
            height: 1.45,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Organize Better.\nLive Better.',
          style: TextStyle(
            color: WalkaColors.navy,
            fontFamily: 'serif',
            fontSize: compact ? 35 : 40,
            height: 0.98,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Premium drawer organizers and stainless steel lunch boxes designed for calm, everyday order.',
          style: TextStyle(
            color: Color(0xFF59616A),
            fontSize: 12.5,
            height: 1.55,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        WalkaHomeHeroActions(onShopAll: onShopAll, onSearch: onSearch),
      ],
    );
  }
}

class _HeroVisualStage extends StatelessWidget {
  const _HeroVisualStage({
    required this.height,
    required this.lunchSemanticLabel,
    required this.drawerSemanticLabel,
  });

  final double height;
  final String lunchSemanticLabel;
  final String drawerSemanticLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.82,
                heightFactor: 0.92,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: WalkaColors.gold.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: 190,
            height: height * 0.70,
            child: WalkaResolvedProductMedia(
              key: const ValueKey<String>('home-hero-lunch-visual'),
              variantId: 'lunch-box:green',
              kind: WalkaProductVisualKind.lunchBox,
              primaryColor: WalkaLunchVariant.green.color,
              backgroundColor: const Color(0xFFF6F2E8),
              compact: true,
              mediaSurface: WalkaProductMediaSurface.home,
              semanticLabel: lunchSemanticLabel,
            ),
          ),
          Positioned(
            right: 18,
            bottom: 0,
            width: 150,
            height: height * 0.48,
            child: WalkaResolvedProductMedia(
              key: const ValueKey<String>('home-hero-drawer-visual'),
              variantId: 'drawer-organizer:white',
              kind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: const Color(0xFFF7F4EC),
              backgroundColor: const Color(0xFFF2E6C9),
              compact: true,
              mediaSurface: WalkaProductMediaSurface.home,
              semanticLabel: drawerSemanticLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroDots extends StatelessWidget {
  const _HeroDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _HeroDot(active: true),
        SizedBox(width: 8),
        _HeroDot(),
        SizedBox(width: 8),
        _HeroDot(),
        SizedBox(width: 8),
        _HeroDot(),
      ],
    );
  }
}

class _HeroDot extends StatelessWidget {
  const _HeroDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? WalkaColors.navy : const Color(0xFFD6D6D6),
      ),
    );
  }
}
