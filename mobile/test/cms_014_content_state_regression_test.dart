import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_pdp_layout_cache.dart';
import 'package:walka/features/content/data/walka_pdp_layout_repository.dart';
import 'package:walka/features/content/data/walka_related_products_cache.dart';
import 'package:walka/features/content/data/walka_related_products_repository.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/content/domain/walka_pdp_layout_content.dart';
import 'package:walka/features/content/domain/walka_related_products_content.dart';

void main() {
  test('CMS-014 published PDP snapshots propagate into active content state and resist downgrade', () async {
    final _MemoryPdpLayoutCache layoutCache = _MemoryPdpLayoutCache();
    final _MemoryRelatedProductsCache relatedCache =
        _MemoryRelatedProductsCache();

    int layoutRevision = 14;
    int relatedRevision = 15;

    final WalkaPdpLayoutContent remoteLayout = WalkaPdpLayoutContent(
      sections: const <WalkaPdpSectionConfig>[
        WalkaPdpSectionConfig(id: WalkaPdpSectionId.variants, visible: true),
        WalkaPdpSectionConfig(id: WalkaPdpSectionId.gallery, visible: true),
        WalkaPdpSectionConfig(id: WalkaPdpSectionId.identity, visible: true),
        WalkaPdpSectionConfig(id: WalkaPdpSectionId.facts, visible: true),
        WalkaPdpSectionConfig(
          id: WalkaPdpSectionId.specifications,
          visible: true,
        ),
        WalkaPdpSectionConfig(
          id: WalkaPdpSectionId.amazonTrust,
          visible: true,
        ),
        WalkaPdpSectionConfig(id: WalkaPdpSectionId.editorial, visible: true),
        WalkaPdpSectionConfig(id: WalkaPdpSectionId.usage, visible: false),
      ],
    );
    const WalkaRelatedProductsContent remoteRelated =
        WalkaRelatedProductsContent(
      relationships: <WalkaRelatedProductRelationship>[
        WalkaRelatedProductRelationship(
          productId: 'drawer-organizer',
          relatedProductIds: <String>['stainless-steel-bento-lunch-box'],
        ),
        WalkaRelatedProductRelationship(
          productId: 'stainless-steel-bento-lunch-box',
          relatedProductIds: <String>[],
        ),
      ],
    );

    final WalkaContentController controller = WalkaContentController(
      pdpLayoutRepository: WalkaPdpLayoutRepository(
        cache: layoutCache,
        clock: () => DateTime.utc(2026, 8, 14, 3),
        remoteLoader: () async => WalkaPdpLayoutPayload(
          content: remoteLayout,
          revision: layoutRevision,
          publishedAt: DateTime.utc(2026, 8, 14, 2, 45),
        ),
      ),
      relatedProductsRepository: WalkaRelatedProductsRepository(
        cache: relatedCache,
        clock: () => DateTime.utc(2026, 8, 14, 3),
        remoteLoader: () async => WalkaRelatedProductsPayload(
          content: remoteRelated,
          revision: relatedRevision,
          publishedAt: DateTime.utc(2026, 8, 14, 2, 46),
        ),
      ),
    );

    expect(controller.isLoading, isTrue);
    await controller.load();

    expect(controller.isLoading, isFalse);
    expect(controller.pdpLayout.source, WalkaContentSource.remote);
    expect(controller.pdpLayout.revision, 14);
    expect(
      controller.pdpLayout.content.sections.first.id,
      WalkaPdpSectionId.variants,
    );
    expect(
      controller.pdpLayout.content.visibleSections
          .map((WalkaPdpSectionConfig section) => section.id),
      isNot(contains(WalkaPdpSectionId.usage)),
    );
    expect(controller.relatedProducts.source, WalkaContentSource.remote);
    expect(controller.relatedProducts.revision, 15);
    expect(
      controller.relatedProducts.content.relatedIdsFor('drawer-organizer'),
      <String>['stainless-steel-bento-lunch-box'],
    );
    expect(layoutCache.value?.revision, 14);
    expect(relatedCache.value?.revision, 15);

    layoutRevision = 13;
    relatedRevision = 14;
    await controller.load();

    expect(controller.pdpLayout.source, WalkaContentSource.cache);
    expect(controller.pdpLayout.revision, 14);
    expect(controller.relatedProducts.source, WalkaContentSource.cache);
    expect(controller.relatedProducts.revision, 15);
    expect(layoutCache.writeCount, 1);
    expect(relatedCache.writeCount, 1);
  });
}

class _MemoryPdpLayoutCache implements WalkaPdpLayoutCache {
  WalkaPdpLayoutSnapshot? value;
  int writeCount = 0;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<WalkaPdpLayoutSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaPdpLayoutSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}

class _MemoryRelatedProductsCache implements WalkaRelatedProductsCache {
  WalkaRelatedProductsSnapshot? value;
  int writeCount = 0;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<WalkaRelatedProductsSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaRelatedProductsSnapshot snapshot) async {
    writeCount += 1;
    value = snapshot;
  }
}
