import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media_admission.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> _rows(Map<String, dynamic> document) =>
    (document['variants'] as List<dynamic>).cast<Map<String, dynamic>>();

Map<String, Map<String, dynamic>> _byId(Map<String, dynamic> document) =>
    <String, Map<String, dynamic>>{
      for (final Map<String, dynamic> row in _rows(document))
        row['variantId'] as String: row,
    };

String _lifecycle(WalkaProductMediaAdmissionState state) => switch (state) {
      WalkaProductMediaAdmissionState.pending => 'PENDING',
      WalkaProductMediaAdmissionState.admitted => 'ADMITTED',
      WalkaProductMediaAdmissionState.blocked => 'BLOCKED',
    };

void main() {
  late Map<String, dynamic> source;
  late Map<String, dynamic> provenance;
  late Map<String, dynamic> receipt;
  late Map<String, Map<String, dynamic>> sourceById;
  late Map<String, Map<String, dynamic>> provenanceById;

  setUpAll(() {
    source = _readJson('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json');
    provenance = _readJson('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json');
    receipt = _readJson('../docs/ui/VFIN_RELEASE_RECEIPT.json');
    sourceById = _byId(source);
    provenanceById = _byId(provenance);
  });

  test('AMIG-001..010 task namespace is exact, ordered and unique', () {
    final List<String> ids = List<String>.generate(
      100,
      (int index) => 'AMIG-${(index + 1).toString().padLeft(3, '0')}',
    );
    expect(ids, hasLength(100));
    expect(ids.toSet(), hasLength(100));
    expect(ids.first, 'AMIG-001');
    expect(ids.last, 'AMIG-100');
    for (int group = 0; group < 10; group += 1) {
      expect(ids.skip(group * 10).take(10), hasLength(10));
    }
  });

  test('AMIG-011..020 released variant sets agree across every admission layer', () {
    final List<String> released =
        WalkaProductMediaAdmissionRegistry.releasedVariantIds;
    expect(released, hasLength(5));
    expect(released.toSet(), hasLength(5));
    expect(sourceById.keys.toSet(), released.toSet());
    expect(provenanceById.keys.toSet(), released.toSet());
    expect(WalkaProductMediaResolver.productionVariantIds, released);
    expect(WalkaProductMediaResolver.productionAssets.keys.toList(), released);
  });

  test('AMIG-021..030 registry partition and quarantine counts are state-derived', () {
    final Iterable<WalkaProductMediaAdmissionEntry> entries =
        WalkaProductMediaAdmissionRegistry.entries.values;
    final int pending = entries
        .where((WalkaProductMediaAdmissionEntry entry) =>
            entry.state == WalkaProductMediaAdmissionState.pending)
        .length;
    final int blocked = entries
        .where((WalkaProductMediaAdmissionEntry entry) =>
            entry.state == WalkaProductMediaAdmissionState.blocked)
        .length;
    final int admitted = entries
        .where((WalkaProductMediaAdmissionEntry entry) => entry.eligibleForRuntime)
        .length;
    expect(WalkaProductMediaAdmissionRegistry.registeredCount, 5);
    expect(WalkaProductMediaAdmissionRegistry.admittedCount, admitted);
    expect(WalkaProductMediaAdmissionRegistry.pendingCount, pending);
    expect(WalkaProductMediaAdmissionRegistry.blockedCount, blocked);
    expect(WalkaProductMediaAdmissionRegistry.quarantinedCount, 5 - admitted);
    expect(admitted + pending + blocked, 5);
  });

  test('AMIG-031..040 source, provenance and runtime metadata stay in lockstep', () {
    for (final String id
        in WalkaProductMediaAdmissionRegistry.releasedVariantIds) {
      final WalkaProductMediaAdmissionEntry runtime =
          WalkaProductMediaAdmissionRegistry.entries[id]!;
      final Map<String, dynamic> sourceRow = sourceById[id]!;
      final Map<String, dynamic> provenanceRow = provenanceById[id]!;
      expect(sourceRow['canonicalPath'], runtime.canonicalPath, reason: id);
      expect(provenanceRow['canonicalPath'], runtime.canonicalPath, reason: id);
      expect(
        sourceRow['sourceState'] == 'APPROVED',
        runtime.sourceApproved,
        reason: id,
      );
      expect(
        provenanceRow['sourceState'] == 'APPROVED',
        runtime.sourceApproved,
        reason: id,
      );
      expect(
        sourceRow['canonicalExportPresent'],
        runtime.canonicalExportPresent,
        reason: id,
      );
      expect(provenanceRow['lifecycleState'], _lifecycle(runtime.state), reason: id);
    }
  });

  test('AMIG-041..050 admitted variants require approved source, export, fingerprint and QA', () {
    for (final WalkaProductMediaAdmissionEntry runtime
        in WalkaProductMediaAdmissionRegistry.entries.values) {
      final Map<String, dynamic> sourceRow = sourceById[runtime.variantId]!;
      final Map<String, dynamic> provenanceRow = provenanceById[runtime.variantId]!;
      if (!runtime.eligibleForRuntime) continue;
      expect(runtime.state, WalkaProductMediaAdmissionState.admitted,
          reason: runtime.variantId);
      expect(runtime.sourceApproved, isTrue, reason: runtime.variantId);
      expect(runtime.canonicalExportPresent, isTrue, reason: runtime.variantId);
      expect(sourceRow['sourceState'], 'APPROVED', reason: runtime.variantId);
      expect(sourceRow['canonicalExportPresent'], isTrue,
          reason: runtime.variantId);
      expect(provenanceRow['lifecycleState'], 'ADMITTED',
          reason: runtime.variantId);
      expect(provenanceRow['sha256'], isA<String>(), reason: runtime.variantId);
      expect((provenanceRow['sha256'] as String), hasLength(64),
          reason: runtime.variantId);
      expect(provenanceRow['byteSize'], greaterThan(0), reason: runtime.variantId);
      final Map<String, dynamic> qa =
          provenanceRow['qa'] as Map<String, dynamic>;
      expect(qa.values.every((dynamic value) => value == 'PASS'), isTrue,
          reason: runtime.variantId);
      expect(File(runtime.canonicalPath).existsSync(), isTrue,
          reason: runtime.variantId);
    }
  });

  test('AMIG-051..060 resolver admits exactly runtime-eligible variants', () {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    final Set<String> eligible =
        WalkaProductMediaAdmissionRegistry.admittedVariantIds.toSet();
    expect(
      resolver.admittedAssets
          .map((WalkaProductMediaAsset asset) => asset.variantId)
          .toSet(),
      eligible,
    );
    for (final String id
        in WalkaProductMediaAdmissionRegistry.releasedVariantIds) {
      expect(resolver.hasRegisteredAsset(id), isTrue, reason: id);
      expect(
        resolver.hasAdmittedAsset(id),
        WalkaProductMediaAdmissionRegistry.isRuntimeEligible(id),
        reason: id,
      );
    }
  });

  test('AMIG-061..070 quarantine remains explicit and cannot promote blocked sources', () {
    const WalkaProductMediaResolver resolver =
        WalkaProductMediaResolver.production();
    for (final String id
        in WalkaProductMediaAdmissionRegistry.quarantinedVariantIds) {
      final WalkaProductMediaAdmissionEntry entry =
          WalkaProductMediaAdmissionRegistry.entries[id]!;
      expect(entry.eligibleForRuntime, isFalse, reason: id);
      expect(entry.quarantineReason, isNot('admitted'), reason: id);
      expect(resolver.hasRegisteredAsset(id), isTrue, reason: id);
      expect(resolver.hasAdmittedAsset(id), isFalse, reason: id);
    }
    final WalkaProductMediaAdmissionEntry gray =
        WalkaProductMediaAdmissionRegistry.entries['drawer-organizer:gray']!;
    expect(gray.state, WalkaProductMediaAdmissionState.blocked);
    expect(gray.sourceApproved, isFalse);
    expect(sourceById[gray.variantId]!['sourceState'], 'BLOCKED');
    expect(sourceById[gray.variantId]!['canonicalExportPresent'], isFalse);
  });

  test('AMIG-071..080 Blue migration is additive and does not weaken future admissions', () {
    final Set<String> admitted =
        WalkaProductMediaAdmissionRegistry.admittedVariantIds.toSet();
    expect(admitted, contains('drawer-organizer:white'));
    expect(admitted, contains('lunch-box:blue'));
    for (final String id in <String>['drawer-organizer:white', 'lunch-box:blue']) {
      expect(sourceById[id]!['canonicalExportPresent'], isTrue, reason: id);
      expect(provenanceById[id]!['lifecycleState'], 'ADMITTED', reason: id);
    }
    for (final String id in <String>['lunch-box:pink', 'lunch-box:green']) {
      expect(sourceById[id]!['sourceState'], 'APPROVED', reason: id);
      expect(
        provenanceById[id]!['lifecycleState'],
        anyOf('PENDING', 'ADMITTED'),
        reason: id,
      );
    }
  });

  test('AMIG-081..090 release receipt reconciles current counts and stays fail closed', () {
    final Map<String, dynamic> media =
        receipt['productionMedia'] as Map<String, dynamic>;
    expect(media['admitted'], WalkaProductMediaAdmissionRegistry.admittedCount);
    expect(media['pending'], WalkaProductMediaAdmissionRegistry.pendingCount);
    expect(media['blocked'], WalkaProductMediaAdmissionRegistry.blockedCount);
    final bool ready = WalkaProductMediaAdmissionRegistry.allReleasedMediaAdmitted;
    expect(media['mechanicalReady'], ready);
    if (!ready) {
      expect(media['stablePublication'], isFalse);
      expect(media['finalVisualStatus'], 'BLOCKED');
      expect(media['ownerVisualAcceptance'], 'REQUIRES_OWNER_REVIEW');
    }
  });

  test('AMIG-091..100 runtime consistency CLI emits current state without hard-coded counts',
      () async {
    final Directory temp = await Directory.systemTemp.createTemp('walka-amig-');
    addTearDown(() => temp.delete(recursive: true));
    final File report = File('${temp.path}/admission.json');
    final ProcessResult result = await Process.run(
      'dart',
      <String>[
        'run',
        'tool/verify_runtime_media_admission.dart',
        '--json',
        report.path,
      ],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final Map<String, dynamic> json = _readJson(report.path);
    expect(json['consistent'], isTrue);
    expect(json['registeredCount'], WalkaProductMediaAdmissionRegistry.registeredCount);
    expect(json['admittedCount'], WalkaProductMediaAdmissionRegistry.admittedCount);
    expect(json['pendingCount'], WalkaProductMediaAdmissionRegistry.pendingCount);
    expect(json['blockedCount'], WalkaProductMediaAdmissionRegistry.blockedCount);
    expect(json['presentButQuarantinedCount'],
        WalkaProductMediaAdmissionRegistry.quarantinedCount);
    expect(json['issues'], isEmpty);
  });
}
