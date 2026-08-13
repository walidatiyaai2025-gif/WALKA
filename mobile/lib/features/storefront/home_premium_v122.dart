import 'package:flutter/material.dart';

import '../../design_system/components/layout/walka_content_width.dart';
import '../../design_system/walka_reference_ui.dart';
import '../../design_system/walka_shell.dart';
import '../catalog/catalog_state.dart';
import '../content/content_state.dart';
import '../content/domain/walka_home_banner_content.dart';
import '../content/domain/walka_home_featured_content.dart';
import '../content/domain/walka_home_layout_content.dart';
import '../content/domain/walka_mobile_content.dart';
import 'presentation/widgets/home/walka_home_banner.dart';
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
    final WalkaContentController? contentController =
        WalkaContentScope.maybeOf(context);
    final WalkaHomeHeroContent heroContent =
        contentController?.home.content ?? WalkaHomeHeroContent.bundled;
    final WalkaHomeLayoutContent layout =
        contentController?.homeLayout.content ?? WalkaHomeLayoutContent.bundled;
    final WalkaHomeFeaturedContent requestedFeatured =
        contentController?.homeFeatured.content ?? WalkaHomeFeaturedContent.bundled;
    final WalkaHomeBannerContent banner =
        contentController?.homeBanner.content ?? WalkaHomeBannerContent.bundled;
    final List<WalkaCatalogViewItem> items = walkaCatalogViewItems(
      controller.snapshot,
    );
    final WalkaCatalogViewItem drawer = items.firstWhere(
      (WalkaCatalogViewItem item) => item.family == WalkaCatalogFamily.drawer,
    );
    final WalkaCatalogViewItem lunch = items.firstWhere(
      (WalkaCatalogViewItem item) => item.family == WalkaCatalogFamily.lunch,
    );
    final _ResolvedHomeFeatured featured = _resolveFeatured(
      items,
      requestedFeatured,
    );
    final String lunchLabel = _semanticLabel(lunch);
    final String drawerLabel = _semanticLabel(drawer);

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
                  final List<Widget> slivers = <Widget>[
                    SliverToBoxAdapter(
                      child: WalkaHomeHeader(
                        onBrowse: onShopAll,
                        onSearch: onSearch,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: WalkaScheduledHomeBanner(
                        content: banner,
                        onBrowse: onShopAll,
                        onSearch: onSearch,
                        horizontalPadding: gutter,
                      ),
                    ),
                    ...layout.visibleSections.expand(
                      (WalkaHomeSectionConfig section) => _sectionSlivers(
                        context: context,
                        section: section,
                        gutter: gutter,
                        heroContent: heroContent,
                        lunch: lunch,
                        drawer: drawer,
                        lunchLabel: lunchLabel,
                        drawerLabel: drawerLabel,
                        collectionFirst: featured.collectionFirst,
                        collectionSecond: featured.collectionSecond,
                        editorial: featured.editorial,
                        itemCount: items.length,
                        release: controller.snapshot.config.release,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 42 + MediaQuery.paddingOf(context).bottom,
                      ),
                    ),
                  ];

                  return CustomScrollView(
                    key: const PageStorageKey<String>('walka-premium-home-scroll'),
                    slivers: slivers,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Iterable<Widget> _sectionSlivers({
    required BuildContext context,
    required WalkaHomeSectionConfig section,
    required double gutter,
    required WalkaHomeHeroContent heroContent,
    required WalkaCatalogViewItem lunch,
    required WalkaCatalogViewItem drawer,
    required String lunchLabel,
    required String drawerLabel,
    required WalkaCatalogViewItem collectionFirst,
    required WalkaCatalogViewItem collectionSecond,
    required WalkaCatalogViewItem editorial,
    required int itemCount,
    required String release,
  }) sync* {
    switch (section.id) {
      case WalkaHomeSectionId.hero:
        yield SliverToBoxAdapter(
          child: WalkaHomeHero(
            content: heroContent,
            lunchSemanticLabel: '$lunchLabel hero product',
            drawerSemanticLabel: '$drawerLabel hero product',
            onOpenLunch: () => openWalkaCatalogItem(context, lunch),
            onShopAll: onShopAll,
            onSearch: onSearch,
          ),
        );
        break;
      case WalkaHomeSectionId.benefits:
        yield SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
          sliver: const SliverToBoxAdapter(child: WalkaHomeBenefitBand()),
        );
        break;
      case WalkaHomeSectionId.collection:
        yield SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, 28, gutter, 0),
          sliver: SliverToBoxAdapter(
            child: WalkaHomeCollectionSection(
              eyebrow: section.eyebrow!,
              title: section.title!,
              firstVariantId: collectionFirst.variantId,
              secondVariantId: collectionSecond.variantId,
              firstSemanticLabel: _semanticLabel(collectionFirst),
              secondSemanticLabel: _semanticLabel(collectionSecond),
              onFirst: () => openWalkaCatalogItem(context, collectionFirst),
              onSecond: () => openWalkaCatalogItem(context, collectionSecond),
            ),
          ),
        );
        break;
      case WalkaHomeSectionId.smallChanges:
        yield SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
          sliver: SliverToBoxAdapter(
            child: WalkaHomeSmallChanges(
              title: section.title!,
              body: section.body!,
              variantId: editorial.variantId,
              productSemanticLabel:
                  '${_semanticLabel(editorial)} lifestyle visual',
              onTap: () => openWalkaCatalogItem(context, editorial),
            ),
          ),
        );
        break;
      case WalkaHomeSectionId.trust:
        yield SliverPadding(
          padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
          sliver: SliverToBoxAdapter(
            child: WalkaHomeTrustStrip(
              itemCount: itemCount,
              release: release,
            ),
          ),
        );
        break;
    }
  }
}

String _semanticLabel(WalkaCatalogViewItem item) {
  return '${item.title} ${item.variant}';
}

_ResolvedHomeFeatured _resolveFeatured(
  List<WalkaCatalogViewItem> items,
  WalkaHomeFeaturedContent requested,
) {
  final Map<String, WalkaCatalogViewItem> byId = <String, WalkaCatalogViewItem>{
    for (final WalkaCatalogViewItem item in items) item.variantId: item,
  };

  _ResolvedHomeFeatured? resolve(WalkaHomeFeaturedContent content) {
    final WalkaCatalogViewItem? first =
        byId[content.collectionVariantIds.first];
    final WalkaCatalogViewItem? second =
        byId[content.collectionVariantIds.last];
    final WalkaCatalogViewItem? editorial = byId[content.editorialVariantId];
    if (first == null || second == null || editorial == null) {
      return null;
    }
    if (first.productId == second.productId) {
      return null;
    }
    return _ResolvedHomeFeatured(
      collectionFirst: first,
      collectionSecond: second,
      editorial: editorial,
    );
  }

  return resolve(requested) ??
      resolve(WalkaHomeFeaturedContent.bundled) ??
      _ResolvedHomeFeatured(
        collectionFirst: items.first,
        collectionSecond: items.length > 1 ? items[1] : items.first,
        editorial: items.first,
      );
}

class _ResolvedHomeFeatured {
  const _ResolvedHomeFeatured({
    required this.collectionFirst,
    required this.collectionSecond,
    required this.editorial,
  });

  final WalkaCatalogViewItem collectionFirst;
  final WalkaCatalogViewItem collectionSecond;
  final WalkaCatalogViewItem editorial;
}
