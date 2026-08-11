import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/production_asset_provenance.dart';

void main() {
  const PimgProductionAssetProvenanceReader reader =
      PimgProductionAssetProvenanceReader();

  test('repository provenance contains exactly five released variants in stable order',
      () async {
    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: Directory.current.path,
    );

    expect(inspection.valid, isTrue,
        reason: inspection.diagnostics.map((d) => d.message).join('\n'));
    expect(
      inspection.rows.map((PimgProvenanceRow row) => row.variantId).toList(),
      pimgReleasedVariantIds,
    );
    expect(inspection.admittedCount, 1);
    expect(inspection.pendingCount, 3);
    expect(inspection.blockedCount, 1);
    expect(inspection.rows.first.variantId, 'drawer-organizer:white');
    expect(inspection.rows.first.lifecycleState, 'ADMITTED');
    expect(inspection.rows[1].variantId, 'drawer-organizer:gray');
    expect(inspection.rows[1].lifecycleState, 'BLOCKED');
  });

  test('deterministic report exposes lifecycle counts and every mandatory QA state',
      () async {
    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: Directory.current.path,
    );
    final Map<String, dynamic> report =
        jsonDecode(pimgStableJson(inspection)) as Map<String, dynamic>;
    expect(report['state'], 'READY');
    expect((report['counts'] as Map<String, dynamic>)['admitted'], 1);
    expect((report['counts'] as Map<String, dynamic>)['pending'], 3);
    expect((report['counts'] as Map<String, dynamic>)['blocked'], 1);
    final List<dynamic> rows = report['variants'] as List<dynamic>;
    for (final dynamic raw in rows) {
      final Map<String, dynamic> row = raw as Map<String, dynamic>;
      final Map<String, dynamic> qa = row['qa'] as Map<String, dynamic>;
      for (final String key in pimgMandatoryQaChecks) {
        expect(qa.containsKey(key), isTrue,
            reason: '${row['variantId']} missing $key');
      }
    }
  });

  test('duplicate variant and canonical path are rejected', () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('walka-pimg-duplicate-');
    addTearDown(() => temp.delete(recursive: true));
    final Map<String, dynamic> provenance = jsonDecode(
      await File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsString(),
    ) as Map<String, dynamic>;
    final List<dynamic> rows = provenance['variants'] as List<dynamic>;
    final Map<String, dynamic> second =
        Map<String, dynamic>.from(rows[1] as Map<String, dynamic>);
    second['variantId'] = (rows[0] as Map<String, dynamic>)['variantId'];
    second['canonicalPath'] = (rows[0] as Map<String, dynamic>)['canonicalPath'];
    rows[1] = second;
    final File provenanceFile = File('${temp.path}/provenance.json')
      ..writeAsStringSync(jsonEncode(provenance));

    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: provenanceFile.path,
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: Directory.current.path,
    );
    final Set<String> codes =
        inspection.diagnostics.map((d) => d.code).toSet();
    expect(codes, contains('provenance.variant-id-duplicate'));
    expect(codes, contains('provenance.canonical-path-duplicate'));
  });

  test('source admission mismatch is rejected instead of silently drifting',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('walka-pimg-source-');
    addTearDown(() => temp.delete(recursive: true));
    final Map<String, dynamic> provenance = jsonDecode(
      await File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsString(),
    ) as Map<String, dynamic>;
    final List<dynamic> rows = provenance['variants'] as List<dynamic>;
    final Map<String, dynamic> first =
        Map<String, dynamic>.from(rows.first as Map<String, dynamic>);
    first['sourceFilename'] = 'not-the-approved-source.jpg';
    rows[0] = first;
    final File provenanceFile = File('${temp.path}/provenance.json')
      ..writeAsStringSync(jsonEncode(provenance));

    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: provenanceFile.path,
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: Directory.current.path,
    );
    expect(
      inspection.diagnostics.map((d) => d.code),
      contains('provenance.source-admission-mismatch'),
    );
  });

  test('ADMITTED requires fingerprint metadata, approved source and all QA PASS',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('walka-pimg-admitted-');
    addTearDown(() => temp.delete(recursive: true));
    final Map<String, dynamic> provenance = jsonDecode(
      await File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsString(),
    ) as Map<String, dynamic>;
    final List<dynamic> rows = provenance['variants'] as List<dynamic>;
    final Map<String, dynamic> pendingApproved =
        Map<String, dynamic>.from(rows[2] as Map<String, dynamic>);
    expect(pendingApproved['variantId'], 'lunch-box:blue');
    expect(pendingApproved['lifecycleState'], 'PENDING');
    pendingApproved['lifecycleState'] = 'ADMITTED';
    rows[2] = pendingApproved;
    final File provenanceFile = File('${temp.path}/provenance.json')
      ..writeAsStringSync(jsonEncode(provenance));

    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: provenanceFile.path,
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: '${temp.path}/empty-mobile-root',
    );
    final Set<String> codes =
        inspection.diagnostics.map((d) => d.code).toSet();
    expect(codes, contains('provenance.admitted-fingerprint-missing'));
    expect(codes, contains('provenance.admitted-qa-incomplete'));
    expect(codes, contains('provenance.admitted-file-missing'));
  });

  test('protected Images source path is rejected for runtime provenance',
      () async {
    final Directory temp =
        await Directory.systemTemp.createTemp('walka-pimg-protected-');
    addTearDown(() => temp.delete(recursive: true));
    final Map<String, dynamic> provenance = jsonDecode(
      await File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsString(),
    ) as Map<String, dynamic>;
    final List<dynamic> rows = provenance['variants'] as List<dynamic>;
    final Map<String, dynamic> first =
        Map<String, dynamic>.from(rows.first as Map<String, dynamic>);
    first['sourceFilename'] = 'Images/fake-runtime-source.png';
    rows[0] = first;
    final File provenanceFile = File('${temp.path}/provenance.json')
      ..writeAsStringSync(jsonEncode(provenance));

    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: provenanceFile.path,
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: Directory.current.path,
    );
    expect(
      inspection.diagnostics.map((d) => d.code),
      contains('provenance.protected-source-path'),
    );
  });
}
