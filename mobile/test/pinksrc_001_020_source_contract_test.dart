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

  test('PINKSRC-001..005 locks source fingerprint, dimensions and approved panel', () {
    final Map<String, dynamic> source = _map(contract['source']);
    final Map<String, dynamic> panel = _map(contract['approvedProductPanel']);

    expect(contract['schemaVersion'], 2);
    expect(contract['variantId'], variantId);
    expect(source['sourceId'], 'SRC-LUNCH-PINK-001');
    expect(source['filename'], '1000389975.jpg');
    expect(source['state'], 'APPROVED');
    expect(
      source['sha256'],
      '11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5',
    );
    expect(source['byteSize'], 189515);
    expect(source['width'], 695);
    expect(source['height'], 1536);
    expect(panel, containsPair('x', 28));
    expect(panel, containsPair('y', 760));
    expect(panel, containsPair('width', 647));
    expect(panel, containsPair('height', 575));
    expect((panel['x'] as int) + (panel['width'] as int), lessThanOrEqualTo(695));
    expect((panel['y'] as int) + (panel['height'] as int), lessThanOrEqualTo(1536));
    expect(panel['marketplacePixelsOutsidePanelMustBeExcluded'], isTrue);
  });

  test('PINKSRC-006..010 locks canonical output and admitted fingerprint', () {
    final Map<String, dynamic> output = _map(contract['canonicalOutput']);

    expect(output['path'], 'assets/products/lunch/pink.png');
    expect((output['path'] as String).startsWith('Images/'), isFalse);
    expect(output['width'], 1024);
    expect(output['height'], 1024);
    expect(output['pixelFormat'], '8-bit RGBA');
    expect(output['colorProfile'], 'sRGB');
    expect(output['minimumTransparentSafeMarginPx'], greaterThanOrEqualTo(51));
    expect(output['maximumByteSize'], 1258291);
    expect(
      output['admittedSha256'],
      '84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae',
    );
    expect(output['admittedByteSize'], 748350);
    expect(output['admittedAlphaBoundingBox'], <int>[51, 161, 972, 862]);
  });

  test('PINKSRC-011..013 requires all nine visual QA checks before admission', () {
    final List<String> qa =
        (contract['requiredVisualQa'] as List<dynamic>).cast<String>();
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
    expect(qa.toSet(), hasLength(9));

    final Map<String, dynamic> provenanceRow = _row(provenance, variantId);
    final Map<String, dynamic> qaStates = _map(provenanceRow['qa']);
    for (final String check in qa) {
      expect(qaStates[check], 'PASS', reason: check);
    }
    expect(_map(contract['admissionGuard'])['currentVisualQaState'], 'PASS');
  });

  test('PINKSRC-014..016 accepts admission only when source/provenance/runtime agree', () {
    final Map<String, dynamic> sourceRow = _row(sourceAdmission, variantId);
    final Map<String, dynamic> provenanceRow = _row(provenance, variantId);
    final Map<String, dynamic> guard = _map(contract['admissionGuard']);

    expect(sourceRow['sourceId'], 'SRC-LUNCH-PINK-001');
    expect(sourceRow['sourceFilename'], '1000389975.jpg');
    expect(sourceRow['sourceState'], 'APPROVED');
    expect(sourceRow['canonicalExportPresent'], isTrue);
    expect(provenanceRow['lifecycleState'], 'ADMITTED');
    expect(
      provenanceRow['sha256'],
      '84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae',
    );
    expect(provenanceRow['byteSize'], 748350);
    expect(provenanceRow['width'], 1024);
    expect(provenanceRow['height'], 1024);
    expect(provenanceRow['nearestTransparentSafeMargin'], greaterThanOrEqualTo(51));
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

  test('PINKSRC-017..020 auditor, CLI, CI artifact and receipt remain executable', () async {
    final Map<String, dynamic> namespace = _map(contract['taskNamespace']);
    final List<String> ids = List<String>.generate(
      20,
      (int index) => 'PINKSRC-${(index + 1).toString().padLeft(3, '0')}',
    );
    expect(namespace['prefix'], 'PINKSRC');
    expect(namespace['expectedCount'], 20);
    expect(ids, hasLength(20));
    expect(ids.toSet(), hasLength(20));
    expect(ids.first, 'PINKSRC-001');
    expect(ids.last, 'PINKSRC-020');

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

    final String flutterPreview =
        File('../.github/workflows/flutter-preview.yml').readAsStringSync();
    expect(flutterPreview, contains('flutter test'));
    expect(flutterPreview, contains('Flutter Preview'));

    final String pinkWorkflow =
        File('../.github/workflows/pink-source-contract.yml').readAsStringSync();
    expect(pinkWorkflow, contains('Flutter Preview · Pink Source Contract'));
    expect(pinkWorkflow, contains('Verify Pink source extraction contract'));
    expect(pinkWorkflow, contains('verify_pink_source_contract.dart'));
    expect(pinkWorkflow, contains('pink-source-contract-report.json'));
    expect(pinkWorkflow, contains('actions/upload-artifact@v4'));

    final File receipt = File('../docs/work/PINKSRC-001-020.md');
    expect(receipt.existsSync(), isTrue);
    final String receiptText = receipt.readAsStringSync();
    for (final String id in ids) {
      expect(receiptText, contains(id), reason: id);
    }
    expect(receiptText, contains('ADMITTED'));
    expect(receiptText, contains('PR #303'));
  });
}
