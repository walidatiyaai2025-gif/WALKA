import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pink_source_contract.dart';

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> _map(Object? value) => value as Map<String, dynamic>;

Map<String, dynamic> _row(Map<String, dynamic> document, String id) =>
    (document['variants'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .singleWhere((Map<String, dynamic> row) => row['variantId'] == id);

void main() {
  const String variantId = 'lunch-box:pink';
  late Map<String, dynamic> contract;
  late Map<String, dynamic> sourceAdmission;
  late Map<String, dynamic> provenance;

  setUpAll(() {
    contract = _json('../docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json');
    sourceAdmission = _json('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    provenance = _json('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
  });

  test('PINKSRC-001..005 keeps source fingerprint, dimensions and approved panel locked', () {
    final Map<String, dynamic> source = _map(contract['source']);
    final Map<String, dynamic> panel = _map(contract['approvedProductPanel']);
    expect(contract['schemaVersion'], 2);
    expect(contract['variantId'], variantId);
    expect(source['sourceId'], 'SRC-LUNCH-PINK-001');
    expect(source['filename'], '1000389975.jpg');
    expect(source['state'], 'APPROVED');
    expect(source['sha256'], '11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5');
    expect(source['byteSize'], 189515);
    expect(source['width'], 695);
    expect(source['height'], 1536);
    expect(panel, containsPair('x', 28));
    expect(panel, containsPair('y', 760));
    expect(panel, containsPair('width', 647));
    expect(panel, containsPair('height', 575));
    expect(panel['marketplacePixelsOutsidePanelMustBeExcluded'], isTrue);
  });

  test('PINKSRC-006..010 locks the new admitted canonical and preserves rejected evidence', () {
    final Map<String, dynamic> output = _map(contract['canonicalOutput']);
    expect(output['path'], 'assets/products/lunch/pink.png');
    expect(output['width'], 1024);
    expect(output['height'], 1024);
    expect(output['pixelFormat'], '8-bit RGBA');
    expect(output['colorProfile'], 'sRGB');
    expect(output['minimumTransparentSafeMarginPx'], 51);
    expect(output['maximumByteSize'], 1258291);
    expect(output['admittedSha256'], '1667519c9a1931f16c8d26acefbed65e1f39ae7820ac58551de71a61a580d7fb');
    expect(output['admittedByteSize'], 749558);
    expect(output['admittedAlphaBoundingBox'], <int>[51, 125, 972, 898]);
    expect(output['admittedDisposition'], 'SOURCE_PANEL_REEXTRACTED_NO_OBVIOUS_HALO');
    expect(output['supersedesRejectedSha256'], '84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae');
  });

  test('PINKSRC-011..013 requires all nine visual QA checks PASS after re-extraction', () {
    final List<String> qa = (contract['requiredVisualQa'] as List<dynamic>).cast<String>();
    expect(qa, <String>[
      'surfaceWhite',
      'surfaceIvory',
      'surfaceNavy',
      'downscale96',
      'downscale160',
      'downscale240',
      'downscale384',
      'geometryPreserved',
      'bakedUiExcluded',
    ]);
    final Map<String, dynamic> provenanceRow = _row(provenance, variantId);
    final Map<String, dynamic> qaStates = _map(provenanceRow['qa']);
    for (final String check in qa) {
      expect(qaStates[check], 'PASS', reason: check);
    }
    expect(_map(contract['admissionGuard'])['currentVisualQaState'], 'PASS');
    final Map<String, dynamic> rejected = _map(contract['lastRejectedVisualProof']);
    expect(rejected['workflowRun'], 31625699344);
    expect(rejected['artifactId'], 9153009337);
    expect(rejected['navyResult'], 'REJECTED_WHITE_HALO_AND_BACKGROUND_CONTAMINATION');
    final Map<String, dynamic> current = _map(contract['currentCanonicalProof']);
    expect(current['vproofDisposition'], 'NO_OBVIOUS_HALO');
    expect(current['navyStage'], 'PASS');
    expect(current['finalOwnerVisualAcceptanceStillRequired'], isTrue);
  });

  test('PINKSRC-014..016 source, provenance and runtime now reconcile as admitted', () {
    final Map<String, dynamic> sourceRow = _row(sourceAdmission, variantId);
    final Map<String, dynamic> provenanceRow = _row(provenance, variantId);
    final Map<String, dynamic> guard = _map(contract['admissionGuard']);
    expect(sourceRow['sourceState'], 'APPROVED');
    expect(sourceRow['canonicalExportPresent'], isTrue);
    expect(provenanceRow['lifecycleState'], 'ADMITTED');
    expect(provenanceRow['sha256'], '1667519c9a1931f16c8d26acefbed65e1f39ae7820ac58551de71a61a580d7fb');
    expect(provenanceRow['byteSize'], 749558);
    expect(provenanceRow['width'], 1024);
    expect(provenanceRow['height'], 1024);
    expect(provenanceRow['alphaBoundingBox'], <int>[51, 125, 972, 898]);
    expect(provenanceRow['nearestTransparentSafeMargin'], 51);
    expect(guard['requiredCurrentProvenanceState'], 'ADMITTED');
    expect(guard['requiredCurrentRuntimeState'], 'admitted');
    expect(guard['requiredCanonicalExportPresent'], isTrue);
    expect(guard['requiredRuntimeEligible'], isTrue);
    expect(guard['stablePublicationMustRemainFailClosed'], isTrue);

    final PinkSourceContractReport report =
        PinkSourceContractAuditor(mobileRoot: Directory.current).audit();
    expect(report.contractReady, isTrue, reason: report.prettyJson());
    expect(report.productionAdmitted, isTrue, reason: report.prettyJson());
    expect(report.state, 'LOCKED_ADMITTED');
    expect(report.visualQaState, 'PASS');
    expect(report.provenanceState, 'ADMITTED');
    expect(report.runtimeState, 'admitted');
    expect(report.canonicalExportPresent, isTrue);
  });

  test('PINKSRC-017..020 auditor, CLI, CI and historical receipt remain executable', () async {
    final Map<String, dynamic> namespace = _map(contract['taskNamespace']);
    final List<String> ids = List<String>.generate(
      20,
      (int index) => 'PINKSRC-${(index + 1).toString().padLeft(3, '0')}',
    );
    expect(namespace['prefix'], 'PINKSRC');
    expect(namespace['expectedCount'], 20);
    expect(ids.toSet(), hasLength(20));

    final Directory temp = await Directory.systemTemp.createTemp('walka-pinksrc-');
    addTearDown(() => temp.delete(recursive: true));
    final File reportFile = File('${temp.path}/pink-source-contract.json');
    final ProcessResult result = await Process.run(
      'dart',
      <String>[
        'run',
        'tool/verify_pink_source_contract.dart',
        '--root',
        '.',
        '--json',
        reportFile.path,
        '--report',
        '--enforce',
      ],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final Map<String, dynamic> cliReport = _json(reportFile.path);
    expect(cliReport['state'], 'LOCKED_ADMITTED');
    expect(cliReport['contractReady'], isTrue);
    expect(cliReport['productionAdmitted'], isTrue);
    expect(cliReport['blockerCount'], 0);

    final String pinkWorkflow = File('../.github/workflows/pink-source-contract.yml').readAsStringSync();
    expect(pinkWorkflow, contains('verify_pink_source_contract.dart'));
    expect(pinkWorkflow, contains('actions/upload-artifact@v4'));

    final File historicalReceipt = File('../docs/work/PINKSRC-001-020.md');
    expect(historicalReceipt.existsSync(), isTrue);
    final String text = historicalReceipt.readAsStringSync();
    for (final String id in ids) {
      expect(text, contains(id), reason: id);
    }
  });
}
