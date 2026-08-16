import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pink_owner_review_gate.dart';

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Map<String, dynamic> _row(Map<String, dynamic> document, String variantId) =>
    (document['variants'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .singleWhere(
          (Map<String, dynamic> row) => row['variantId'] == variantId,
        );

void _writeJson(File file, Map<String, dynamic> value) {
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
}

Future<Directory> _fixtureRepo() async {
  final Directory root =
      await Directory.systemTemp.createTemp('walka-pink-owner-review-');
  final Directory mobile = Directory('${root.path}/mobile')..createSync();
  final Directory docs = Directory('${root.path}/docs/ui')..createSync(recursive: true);
  final Directory runtime = Directory(
    '${mobile.path}/lib/design_system/components/media',
  )..createSync(recursive: true);

  for (final String name in <String>[
    'PINK_SOURCE_EXTRACTION_CONTRACT.json',
    'PINK_OWNER_VISUAL_ACCEPTANCE.json',
    'PRODUCTION_SOURCE_ADMISSION.json',
    'PRODUCTION_ASSET_PROVENANCE.json',
  ]) {
    File('../docs/ui/$name').copySync('${docs.path}/$name');
  }
  File('lib/design_system/components/media/walka_product_media_admission.dart')
      .copySync('${runtime.path}/walka_product_media_admission.dart');
  return root;
}

void main() {
  const String variantId = 'lunch-box:pink';
  const String candidateSha =
      '755ead90e98b51f2fd732c267c01671ffa776d59624565b7521bd4c4ac3f1776';

  test('review candidate is mechanically locked but owner acceptance stays pending', () {
    final Map<String, dynamic> contract =
        _json('../docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json');
    final Map<String, dynamic> candidate =
        contract['reviewCandidate'] as Map<String, dynamic>;
    final Map<String, dynamic> receipt =
        _json('../docs/ui/PINK_OWNER_VISUAL_ACCEPTANCE.json');

    expect(candidate['issue'], 328);
    expect(candidate['state'], 'MECHANICALLY_CLEAN_AWAITING_OWNER_REVIEW');
    expect(candidate['sha256'], candidateSha);
    expect(candidate['byteSize'], 683551);
    expect(candidate['width'], 1024);
    expect(candidate['height'], 1024);
    expect(candidate['alphaBoundingBox'], <int>[51, 128, 973, 895]);
    expect(candidate['minimumTransparentSafeMarginPx'], 51);
    expect(candidate['sourceDerivedFromApprovedPanel'], isTrue);
    expect(candidate['marketplacePixelsOutsidePanelExcluded'], isTrue);
    expect(candidate['automationCanAcceptFinalVisualFidelity'], isFalse);
    expect(candidate['ownerAcceptanceReceipt'],
        'docs/ui/PINK_OWNER_VISUAL_ACCEPTANCE.json');

    expect(receipt['variantId'], variantId);
    expect(receipt['candidateSha256'], candidateSha);
    expect(receipt['status'], 'PENDING');
    expect(receipt['ownerAccepted'], isFalse);
    expect(receipt['decisionActor'], isNull);
    expect(receipt['decidedAt'], isNull);
    expect(receipt['stablePublicationAuthorized'], isFalse);
  });

  test('current repository passes fail-closed owner-review gate', () {
    final PinkOwnerReviewReport report =
        PinkOwnerReviewGateAuditor(mobileRoot: Directory.current).audit();

    expect(report.gateReady, isTrue, reason: report.prettyJson());
    expect(report.state, 'AWAITING_OWNER_ACCEPTANCE');
    expect(report.ownerAccepted, isFalse);
    expect(report.ownerStatus, 'PENDING');
    expect(report.reviewCandidateSha256, candidateSha);
    expect(report.receiptCandidateSha256, candidateSha);
    expect(report.provenanceState, 'PENDING');
    expect(report.runtimeState, 'pending');
    expect(report.canonicalExportPresent, isFalse);
  });

  test('premature admission is rejected while owner receipt remains pending', () async {
    final Directory root = await _fixtureRepo();
    addTearDown(() => root.delete(recursive: true));

    final File sourceFile =
        File('${root.path}/docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    final Map<String, dynamic> source =
        jsonDecode(sourceFile.readAsStringSync()) as Map<String, dynamic>;
    _row(source, variantId)['canonicalExportPresent'] = true;
    _writeJson(sourceFile, source);

    final File provenanceFile =
        File('${root.path}/docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
    final Map<String, dynamic> provenance =
        jsonDecode(provenanceFile.readAsStringSync()) as Map<String, dynamic>;
    final Map<String, dynamic> pink = _row(provenance, variantId);
    pink['lifecycleState'] = 'ADMITTED';
    pink['sha256'] = candidateSha;
    pink['byteSize'] = 683551;
    pink['width'] = 1024;
    pink['height'] = 1024;
    pink['alphaBoundingBox'] = <int>[51, 128, 973, 895];
    pink['nearestTransparentSafeMargin'] = 51;
    _writeJson(provenanceFile, provenance);

    final File runtimeFile = File(
      '${root.path}/mobile/lib/design_system/components/media/'
      'walka_product_media_admission.dart',
    );
    String runtime = runtimeFile.readAsStringSync();
    final int start = runtime.indexOf(
      "'lunch-box:pink': WalkaProductMediaAdmissionEntry(",
    );
    final int end = runtime.indexOf(
      "'lunch-box:green': WalkaProductMediaAdmissionEntry(",
      start,
    );
    final String block = runtime.substring(start, end)
        .replaceFirst(
          'WalkaProductMediaAdmissionState.pending',
          'WalkaProductMediaAdmissionState.admitted',
        )
        .replaceFirst(
          'canonicalExportPresent: false',
          'canonicalExportPresent: true',
        );
    runtime = runtime.replaceRange(start, end, block);
    runtimeFile.writeAsStringSync(runtime);

    final PinkOwnerReviewReport report = PinkOwnerReviewGateAuditor(
      mobileRoot: Directory('${root.path}/mobile'),
    ).audit();

    expect(report.gateReady, isFalse, reason: report.prettyJson());
    expect(
      report.violations.map((PinkOwnerReviewViolation item) => item.code),
      contains('PREMATURE-ADMISSION'),
    );
  });

  test('explicit owner acceptance can be recorded before separate admission', () async {
    final Directory root = await _fixtureRepo();
    addTearDown(() => root.delete(recursive: true));

    final File receiptFile =
        File('${root.path}/docs/ui/PINK_OWNER_VISUAL_ACCEPTANCE.json');
    final Map<String, dynamic> receipt =
        jsonDecode(receiptFile.readAsStringSync()) as Map<String, dynamic>;
    receipt['status'] = 'ACCEPTED';
    receipt['ownerAccepted'] = true;
    receipt['decisionActor'] = 'owner';
    receipt['decidedAt'] = '2026-08-16T14:45:00+03:00';
    final Map<String, dynamic> review =
        receipt['review'] as Map<String, dynamic>;
    for (final String stage in PinkOwnerReviewGateAuditor.requiredReviewStages) {
      review[stage] = 'PASS';
    }
    _writeJson(receiptFile, receipt);

    final PinkOwnerReviewReport report = PinkOwnerReviewGateAuditor(
      mobileRoot: Directory('${root.path}/mobile'),
    ).audit();

    expect(report.gateReady, isTrue, reason: report.prettyJson());
    expect(report.ownerAccepted, isTrue);
    expect(report.state, 'OWNER_ACCEPTED_AWAITING_ADMISSION');
    expect(report.provenanceState, 'PENDING');
    expect(report.runtimeState, 'pending');
    expect(report.canonicalExportPresent, isFalse);
  });

  test('CLI and Pink workflow enforce the independent owner-review gate', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('walka-pink-owner-cli-');
    addTearDown(() => temp.delete(recursive: true));
    final File reportFile = File('${temp.path}/pink-owner-review.json');

    final ProcessResult result = await Process.run(
      'dart',
      <String>[
        'run',
        'tool/verify_pink_owner_review_gate.dart',
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
    expect(cliReport['state'], 'AWAITING_OWNER_ACCEPTANCE');
    expect(cliReport['gateReady'], isTrue);
    expect(cliReport['ownerAccepted'], isFalse);
    expect(cliReport['blockerCount'], 0);

    final String workflow =
        File('../.github/workflows/pink-source-contract.yml').readAsStringSync();
    expect(workflow, contains('Verify Pink owner visual acceptance gate'));
    expect(workflow, contains('verify_pink_owner_review_gate.dart'));
    expect(workflow, contains('pink-owner-review-gate-report.json'));
    expect(workflow, contains('PINK_OWNER_VISUAL_ACCEPTANCE.json'));
  });
}
