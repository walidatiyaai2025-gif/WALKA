import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media_admission.dart';

import '../tool/src/png_asset_inspector.dart';
import '../tool/src/visual_proof_v2.dart';

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> _row(Map<String, dynamic> document, String id) =>
    (document['variants'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .singleWhere((Map<String, dynamic> row) => row['variantId'] == id);

void main() {
  const String variantId = 'lunch-box:pink';
  const String canonicalSha =
      '1667519c9a1931f16c8d26acefbed65e1f39ae7820ac58551de71a61a580d7fb';
  const String rejectedSha =
      '84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae';

  test('PINKFIX-001..020 source master and approved-panel contract stay exact', () {
    final File source = File('../design_sources/pink/1000389975.jpg');
    final Map<String, dynamic> contract =
        _json('../docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json');
    expect(source.existsSync(), isTrue);
    expect(source.lengthSync(), 189515);
    final Map<String, dynamic> sourceContract =
        contract['source'] as Map<String, dynamic>;
    final Map<String, dynamic> panel =
        contract['approvedProductPanel'] as Map<String, dynamic>;
    expect(sourceContract['sha256'],
        '11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5');
    expect(sourceContract['width'], 695);
    expect(sourceContract['height'], 1536);
    expect(panel['x'], 28);
    expect(panel['y'], 760);
    expect(panel['width'], 647);
    expect(panel['height'], 575);
    expect(panel['marketplacePixelsOutsidePanelMustBeExcluded'], isTrue);
  });

  test('PINKFIX-021..040 generator contract is source-derived and non-generative', () {
    final String generator =
        File('tool/pinkfix_source_reextract.py').readAsStringSync();
    expect(generator, contains('SOURCE_SHA256'));
    expect(generator, contains('PANEL = (28, 760, 647, 575)'));
    expect(generator, contains('cv2.Canny(gray, 25, 70)'));
    expect(generator, contains('connectedComponentsWithStats'));
    expect(generator, contains('premultiplied'));
    expect(generator, contains('INTER_LANCZOS4'));
    expect(generator, contains('marketplacePixelsOutsidePanelExcluded'));
    expect(generator, contains('"recolor": False'));
    expect(generator, contains('"geometryReconstruction": False'));
    expect(generator, contains('"accessoryInvention": False'));
    expect(generator, contains('"generativeFill": False'));
  });

  test('PINKFIX-041..060 canonical PNG passes PAV and VPROOF v2 diagnostics', () {
    final Uint8List bytes =
        File('assets/products/lunch/pink.png').readAsBytesSync();
    const PavPngInspector inspector = PavPngInspector();
    final inspection = inspector.inspect(bytes);
    expect(inspection.hasBlockers, isFalse, reason: inspection.toJson().toString());
    expect(inspection.bytes, 749558);
    expect(inspection.width, 1024);
    expect(inspection.height, 1024);
    expect(inspection.bitDepth, 8);
    expect(inspection.colorType, 6);
    expect(inspection.hasColorProfile, isTrue);
    expect(inspection.alphaMetrics, isNotNull);
    expect(inspection.alphaMetrics!.perimeterTransparent, isTrue);
    expect(inspection.alphaMetrics!.bounds!.left, 51);
    expect(inspection.alphaMetrics!.bounds!.top, 125);
    expect(inspection.alphaMetrics!.bounds!.right, 972);
    expect(inspection.alphaMetrics!.bounds!.bottom, 898);
    expect(inspection.alphaMetrics!.safeMargins!.nearest, 51);

    const VproofAnalyzerV2 analyzer = VproofAnalyzerV2();
    final VproofV2Metrics metrics = analyzer.analyzeInspection(inspection);
    expect(metrics.obviousWhiteHalo, isFalse, reason: metrics.toJson().toString());
    expect(metrics.diagnosticDisposition, 'NO_OBVIOUS_HALO');
    expect(metrics.mismatchNearWhitePartialEdgeCount, lessThan(96));
    expect(metrics.mismatchPartialEdgeRatio, lessThan(0.18));
    expect(metrics.mismatchNearWhiteEdgeRatio, lessThan(0.30));
    expect(metrics.navy.brightDeltaRatio, lessThan(0.45));
    expect(metrics.toJson()['automationCanAcceptVisualFidelity'], isFalse);
  });

  test('PINKFIX-061..080 rejected candidate stays rejected and Pink becomes 4th admitted variant', () {
    final Map<String, dynamic> rejection =
        _json('../docs/ui/VISUAL_PROOF_REJECTIONS.json');
    final String rejectionText = jsonEncode(rejection);
    expect(rejectionText, contains(rejectedSha));
    expect(rejectionText, isNot(contains(canonicalSha)));

    final Map<String, dynamic> sourceAdmission =
        _json('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    final Map<String, dynamic> provenance =
        _json('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
    final Map<String, dynamic> pinkSource = _row(sourceAdmission, variantId);
    final Map<String, dynamic> pinkProvenance = _row(provenance, variantId);
    expect(pinkSource['canonicalExportPresent'], isTrue);
    expect(pinkProvenance['lifecycleState'], 'ADMITTED');
    expect(pinkProvenance['sha256'], canonicalSha);
    expect(pinkProvenance['byteSize'], 749558);

    expect(WalkaProductMediaAdmissionRegistry.admittedCount, 4);
    expect(WalkaProductMediaAdmissionRegistry.pendingCount, 0);
    expect(WalkaProductMediaAdmissionRegistry.blockedCount, 1);
    expect(WalkaProductMediaAdmissionRegistry.isRuntimeEligible(variantId), isTrue);
    expect(
      WalkaProductMediaAdmissionRegistry.entryFor('drawer-organizer:gray')!.state,
      WalkaProductMediaAdmissionState.blocked,
    );
  });

  test('PINKFIX-081..100 receipt covers exactly 100 tasks and stable publication remains fail closed', () {
    final Map<String, dynamic> receipt =
        _json('../docs/work/PINKFIX_001_100_RECEIPT.json');
    final List<String> ids =
        (receipt['completedTaskIds'] as List<dynamic>).cast<String>();
    expect(receipt['issue'], 326);
    expect(receipt['expectedCount'], 100);
    expect(ids, hasLength(100));
    expect(ids.toSet(), hasLength(100));
    expect(ids.first, 'PINKFIX-001');
    expect(ids.last, 'PINKFIX-100');
    for (int index = 1; index <= 100; index += 1) {
      expect(ids, contains('PINKFIX-${index.toString().padLeft(3, '0')}'));
    }
    final Map<String, dynamic> state =
        receipt['stateAfterAdmission'] as Map<String, dynamic>;
    expect(state['admitted'], 4);
    expect(state['pending'], 0);
    expect(state['blocked'], 1);
    expect(state['pink'], 'ADMITTED');
    expect(state['gray'], 'BLOCKED');
    expect(state['stablePublication'], isFalse);
    expect(state['ownerVisualAcceptanceStillRequired'], isTrue);

    final Map<String, dynamic> vfin =
        _json('../docs/ui/VFIN_RELEASE_RECEIPT.json');
    final Map<String, dynamic> media =
        vfin['productionMedia'] as Map<String, dynamic>;
    expect(media['admitted'], 4);
    expect(media['pending'], 0);
    expect(media['blocked'], 1);
    expect(media['stablePublication'], isFalse);
    expect(media['finalVisualStatus'], 'BLOCKED');
  });
}
