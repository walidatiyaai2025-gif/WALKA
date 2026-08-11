import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final Map<String, dynamic> receipt =
      _readJson('../docs/ui/VFIN_RELEASE_RECEIPT.json');
  final Map<String, dynamic> provenance =
      _readJson('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
  final Map<String, dynamic> sourceAdmission =
      _readJson('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json');

  test('VFIN release receipt covers exactly VFIN-001 through VFIN-100', () {
    final Map<String, dynamic> coverage =
        receipt['taskCoverage'] as Map<String, dynamic>;
    final List<String> ids = (coverage['ids'] as List<dynamic>).cast<String>();

    expect(coverage['expectedCount'], 100);
    expect(ids, hasLength(100));
    expect(ids.toSet(), hasLength(100));
    for (int index = 0; index < 100; index += 1) {
      expect(ids[index], 'VFIN-${(index + 1).toString().padLeft(3, '0')}');
    }
  });

  test('receipt records the Green merged release gate and latest-main gate', () {
    final Map<String, dynamic> merged =
        receipt['mergedReleaseGate'] as Map<String, dynamic>;
    final Map<String, dynamic> main =
        receipt['latestMainGate'] as Map<String, dynamic>;
    final RegExp digest = RegExp(r'^sha256:[0-9a-f]{64}$');

    expect(merged['pullRequest'], 277);
    expect(merged['prWorkflowResult'], 'success');
    expect((merged['mergeCommit'] as String), hasLength(40));
    expect((merged['sourceHead'] as String), hasLength(40));
    expect(merged['prWorkflowRun'], greaterThan(0));
    expect(digest.hasMatch(merged['prEngineeringApkDigest'] as String), isTrue);

    expect(main['commit'], merged['mergeCommit']);
    expect(main['workflowResult'], 'success');
    expect(main['protectedImagesGuard'], 'PASS');
    expect(main['analyze'], 'PASS');
    expect(main['fullFlutterTests'], 'PASS');
    expect(main['androidReleaseApk'], 'PASS');
    expect(digest.hasMatch(main['engineeringApkDigest'] as String), isTrue);
    expect(digest.hasMatch(main['readinessArtifactDigest'] as String), isTrue);
    expect(digest.hasMatch(main['enforcementBlockArtifactDigest'] as String), isTrue);
  });

  test('receipt production counts match authoritative provenance', () {
    final List<Map<String, dynamic>> rows =
        (provenance['variants'] as List<dynamic>).cast<Map<String, dynamic>>();
    final Map<String, dynamic> media =
        receipt['productionMedia'] as Map<String, dynamic>;

    final int admitted =
        rows.where((Map<String, dynamic> row) => row['lifecycleState'] == 'ADMITTED').length;
    final int pending =
        rows.where((Map<String, dynamic> row) => row['lifecycleState'] == 'PENDING').length;
    final int blocked =
        rows.where((Map<String, dynamic> row) => row['lifecycleState'] == 'BLOCKED').length;

    expect(rows, hasLength(5));
    expect(media['admitted'], admitted);
    expect(media['pending'], pending);
    expect(media['blocked'], blocked);
    expect(admitted + pending + blocked, 5);

    final bool mechanicallyReady = admitted == 5 && pending == 0 && blocked == 0;
    expect(media['mechanicalReady'], mechanicallyReady);
    if (!mechanicallyReady) {
      expect(media['stablePublication'], isFalse);
      expect(media['finalVisualStatus'], 'BLOCKED');
      expect(media['ownerVisualAcceptance'], 'REQUIRES_OWNER_REVIEW');
    }
  });

  test('Drawer Gray stays fail-closed while its source is BLOCKED', () {
    final Map<String, dynamic> graySource =
        (sourceAdmission['variants'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .singleWhere(
              (Map<String, dynamic> row) =>
                  row['variantId'] == 'drawer-organizer:gray',
            );
    final Map<String, dynamic> grayProvenance =
        (provenance['variants'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .singleWhere(
              (Map<String, dynamic> row) =>
                  row['variantId'] == 'drawer-organizer:gray',
            );

    expect(graySource['sourceState'], 'BLOCKED');
    expect(graySource['canonicalExportPresent'], isFalse);
    expect(grayProvenance['lifecycleState'], isNot('ADMITTED'));
    expect(grayProvenance['canonicalPath'], 'assets/products/drawer/gray.png');
  });

  test('reconciliation keeps visual blocker separate from engineering success', () {
    expect(receipt['parentIssue'], 275);
    expect(receipt['visualBlockerIssue'], 230);
    final Map<String, dynamic> media =
        receipt['productionMedia'] as Map<String, dynamic>;
    expect(media['stablePublication'], isFalse);
    expect(media['ownerVisualAcceptance'], 'REQUIRES_OWNER_REVIEW');
    expect(media['finalVisualStatus'], 'BLOCKED');
  });
}
