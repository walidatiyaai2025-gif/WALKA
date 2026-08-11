import 'package:flutter/material.dart';

import '../../design_system/components/layout/walka_content_width.dart';
import '../../design_system/walka_reference_ui.dart';
import '../../design_system/walka_shell.dart';
import '../catalog/catalog_state.dart';
import '../content/content_state.dart';
import '../content/domain/walka_mobile_content.dart';
import 'presentation/widgets/home/walka_home_benefit_band.dart';
import 'presentation/widgets/home/walka_home_collection_section.dart';
import 'presentation/widgets/home/walka_home_header.dart';
import 'presentation/widgets/home/walka_home_hero.dart';
import 'presentation/widgets/home/walka_home_small_changes.dart';
import 'presentation/widgets/home/walka_home_trust_strip.dart';
import 'storefront_catalog_v120.dart';

/// Reference Home composition shared by Android, iOS and wide desktop shells.
class WalkaHomePremiumV122 extends StatelessWidget {
  const WalkaHomePremiumV122({
    required this.onShopAll,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onShopAll;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController controller = WalkaCatalogScope.of(context);
    final WalkaHomeHeroContent heroContent =
        WalkaContentScope.maybeOf(context)?.home.content ??
            WalkaHomeHeroContent.bundled;
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(
      controller.snapshot,
    );
    final WalkaCatalogViewItem drawer = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'drawer-organizer:white',
    );
    final WalkaCatalogViewItem lunch = items.firstWhere(
      (WalkaCatalogViewItem item) => item.variantId == 'lunch-box:blue',
    );
    final String lunchLabel = '${lunch.title} ${lunch.variant}';
    final String drawerLabel = '${drawer.title} ${drawer.variant}';

    return WalkaReferenceViewport(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final WalkaContentTier tier =
              WalkaContentWidthMetrics.tierForWidth(constraints.maxWidth);
          final double maxWidth = WalkaContentWidthMetrics.maxWidthForTier(tier);
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              key: const ValueKey<String>('walka-home-responsive-frame'),
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Builder(
                builder: (BuildContext context) {
                  final double gutter = WalkaShellMetrics.horizontalGutter(context);
                  return CustomScrollView(
                    key: const PageStorageKey<String>('walka-premium-home-scroll'),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: WalkaHomeHeader(
                          onBrowse: onShopAll,
                          onSearch: onSearch,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: WalkaHomeHero(
                          content: heroContent,
                          lunchSemanticLabel: '$lunchLabel hero product',
                          drawerSemanticLabel: '$drawerLabel hero product',
                          onOpenLunch: () => openWalkaCatalogItem(context, lunch),
                          onShopAll: onShopAll,
                          onSearch: onSearch,
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
                        sliver: const SliverToBoxAdapter(
                          child: WalkaHomeBenefitBand(),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
                        sliver: SliverToBoxAdapter(
                          child: WalkaHomeCollectionSection(
                            lunchSemanticLabel: lunchLabel,
                            drawerSemanticLabel: drawerLabel,
                            onLunch: () => openWalkaCatalogItem(context, lunch),
                            onDrawer: () => openWalkaCatalogItem(context, drawer),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
                        sliver: SliverToBoxAdapter(
                          child: WalkaHomeSmallChanges(
                            drawerSemanticLabel: '$drawerLabel lifestyle visual',
                            onTap: () => openWalkaCatalogItem(context, drawer),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          gutter,
                          16,
                          gutter,
                          42 + MediaQuery.paddingOf(context).bottom,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: WalkaHomeTrustStrip(
                            itemCount: items.length,
                            release: controller.snapshot.config.release,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
