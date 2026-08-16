import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/gray_owner_presentation_gate.dart';
import '../tool/src/pink_owner_review_gate.dart';
import '../tool/src/visual_release_gate.dart';

Map<String, dynamic> _json(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

void _writeJson(File file, Map<String, dynamic> value) {
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(value)}\n');
}

Map<String, dynamic> _variant(Map<String, dynamic> document, String id) =>
    (document['variants'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .singleWhere((Map<String, dynamic> row) => row['variantId'] == id);

Future<Directory> _fixture() async {
  final Directory root =
      await Directory.systemTemp.createTemp('walka-visual-release-');
  final List<String> files = <String>[
    'docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json',
    'docs/ui/PINK_OWNER_VISUAL_ACCEPTANCE.json',
    'docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
    'docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
    'docs/ui/GRAY_OWNER_PRESENTATION_DECISION.json',
    'docs/ui/VISUAL_RELEASE_OWNER_ACCEPTANCE.json',
    'mobile/lib/design_system/components/media/walka_product_media_admission.dart',
  ];
  for (final String relative in files) {
    final File source = File('../$relative');
    final File target = File('${root.path}/$relative');
    target.parent.createSync(recursive: true);
    source.copySync(target.path);
  }
  _writeProductionReport(root, ready: false, readyCount: 3);
  return root;
}

void _writeProductionReport(
  Directory root, {
  required bool ready,
  required int readyCount,
}) {
  _writeJson(
    File('${root.path}/mobile/production-asset-readiness.json'),
    <String, dynamic>{
      'schemaVersion': 2,
      'state': ready ? 'READY' : 'BLOCKED',
      'ready': ready,
      'requiredCount': 5,
      'readyCount': readyCount,
      'blockerCount': ready ? 0 : 2,
      'warningCount': 0,
    },
  );
}

VisualReleaseGateReport _audit(Directory root, {String? digest}) =>
    VisualReleaseGateAuditor(
      mobileRoot: Directory('${root.path}/mobile'),
      productionReport:
          File('${root.path}/mobile/production-asset-readiness.json'),
      currentVisualInputDigest: digest,
    ).audit();

void main() {
  test('current P0 truth is contract-valid but stable publication blocked', () async {
    final Directory root = await _fixture();
    addTearDown(() => root.deleteSync(recursive: true));

    final VisualReleaseGateReport report =
        _audit(root, digest: 'a' * 64);

    expect(report.contractValid, isTrue, reason: report.prettyJson());
    expect(report.stableReleaseReady, isFalse);
    expect(report.state, 'BLOCKED');
    expect(report.productionReadyCount, 3);
    expect(report.pinkReport.state, 'AWAITING_OWNER_ACCEPTANCE');
    expect(report.grayReport.state, 'AWAITING_OWNER_DECISION');
    expect(
      report.releaseBlockers,
      containsAll(<String>[
        'production-assets-not-ready',
        'pink-owner-visual-acceptance-pending',
        'gray-owner-presentation-decision-pending',
        'final-owner-screen-acceptance-pending',
      ]),
    );
  });

  test('Gray source promotion before owner decision fails closed', () async {
    final Directory root = await _fixture();
    addTearDown(() => root.deleteSync(recursive: true));
    final File sourceFile =
        File('${root.path}/docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    final Map<String, dynamic> source = _json(sourceFile);
    final Map<String, dynamic> gray =
        _variant(source, 'drawer-organizer:gray');
    gray['sourceState'] = 'APPROVED';
    gray['canonicalExportPresent'] = true;
    _writeJson(sourceFile, source);

    final GrayOwnerDecisionReport report = GrayOwnerPresentationGateAuditor(
      mobileRoot: Directory('${root.path}/mobile'),
    ).audit();

    expect(report.gateReady, isFalse);
    expect(
      report.violations.map((GrayOwnerDecisionViolation item) => item.code),
      contains('PREMATURE-ADMISSION'),
    );
  });

  test('stable authorization cannot be asserted before final owner acceptance',
      () async {
    final Directory root = await _fixture();
    addTearDown(() => root.deleteSync(recursive: true));
    final File receiptFile =
        File('${root.path}/docs/ui/VISUAL_RELEASE_OWNER_ACCEPTANCE.json');
    final Map<String, dynamic> receipt = _json(receiptFile);
    receipt['stablePublicationAuthorized'] = true;
    _writeJson(receiptFile, receipt);

    final VisualReleaseGateReport report =
        _audit(root, digest: 'b' * 64);

    expect(report.contractValid, isFalse);
    expect(
      report.violations.map((VisualReleaseViolation item) => item.code),
      contains('PREMATURE-STABLE-AUTH'),
    );
  });

  test('accepted owner receipt is invalidated by later visual input drift',
      () async {
    final Directory root = await _fixture();
    addTearDown(() => root.deleteSync(recursive: true));
    final File receiptFile =
        File('${root.path}/docs/ui/VISUAL_RELEASE_OWNER_ACCEPTANCE.json');
    final Map<String, dynamic> receipt = _json(receiptFile);
    final Map<String, dynamic> screens =
        receipt['screenGroups'] as Map<String, dynamic>;
    for (final String key in screens.keys) {
      screens[key] = 'PASS';
    }
    receipt['finalDecision'] = 'ACCEPTED';
    receipt['ownerAccepted'] = true;
    receipt['acceptedVisualInputDigest'] = 'a' * 64;
    receipt['acceptedSourceCommit'] = 'b' * 40;
    receipt['acceptedApkSha256'] = 'c' * 64;
    receipt['decisionActor'] = 'owner';
    receipt['decidedAt'] = '2026-08-16T12:00:00Z';
    receipt['stablePublicationAuthorized'] = true;
    _writeJson(receiptFile, receipt);

    final VisualReleaseGateReport report =
        _audit(root, digest: 'd' * 64);

    expect(report.contractValid, isTrue, reason: report.prettyJson());
    expect(report.stableReleaseReady, isFalse);
    expect(report.releaseBlockers, contains('accepted-visual-input-digest-stale'));
  });

  test('fully reconciled synthetic report is stable-release ready', () {
    final PinkOwnerReviewReport pink = PinkOwnerReviewReport(
      violations: const <PinkOwnerReviewViolation>[],
      reviewCandidateSha256: 'a' * 64,
      receiptCandidateSha256: 'a' * 64,
      ownerStatus: 'ACCEPTED',
      ownerAccepted: true,
      provenanceState: 'ADMITTED',
      runtimeState: 'admitted',
      canonicalExportPresent: true,
    );
    final GrayOwnerDecisionReport gray = GrayOwnerDecisionReport(
      violations: const <GrayOwnerDecisionViolation>[],
      decision: 'APPROVED_EXPANDED_SOURCE',
      ownerApproved: true,
      sourceState: 'APPROVED',
      provenanceState: 'ADMITTED',
      runtimeState: 'admitted',
      canonicalExportPresent: true,
    );
    final VisualReleaseGateReport report = VisualReleaseGateReport(
      violations: const <VisualReleaseViolation>[],
      releaseBlockers: <String>[],
      productionAssetsReady: true,
      productionReadyCount: 5,
      productionRequiredCount: 5,
      pinkReport: pink,
      grayReport: gray,
      screenStates: const <String, String>{
        'home': 'PASS',
        'discovery': 'PASS',
        'pdp': 'PASS',
        'favorites': 'PASS',
        'account_about': 'PASS',
      },
      finalDecision: 'ACCEPTED',
      ownerAccepted: true,
      currentVisualInputDigest:
          'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
      acceptedVisualInputDigest:
          'dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',
      acceptedSourceCommit: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      acceptedApkSha256:
          'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
      stablePublicationAuthorized: true,
    );

    expect(pink.state, 'OWNER_ACCEPTED_ADMISSION_RECONCILED');
    expect(gray.fullyAdmitted, isTrue);
    expect(report.contractValid, isTrue);
    expect(report.stableReleaseReady, isTrue);
    expect(report.state, 'READY');
  });
}
