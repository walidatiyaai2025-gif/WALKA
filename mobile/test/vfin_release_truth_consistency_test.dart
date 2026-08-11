import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/production_asset_provenance.dart';

void main() {
  const PimgProductionAssetProvenanceReader reader =
      PimgProductionAssetProvenanceReader();

  test('source admission and provenance stay synchronized', () async {
    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: Directory.current.path,
    );
    expect(
      inspection.valid,
      isTrue,
      reason: inspection.diagnostics.map((dynamic d) => d.message).join('\n'),
    );
    expect(
      inspection.admittedCount + inspection.pendingCount + inspection.blockedCount,
      5,
    );
  });

  test('5/5 readiness is impossible while media is pending or blocked', () async {
    final PimgProvenanceInspection inspection = await reader.inspect(
      provenancePath: '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
      sourceAdmissionPath: '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
      mobileRoot: Directory.current.path,
    );
    final bool fiveOfFive = inspection.admittedCount == 5;
    if (inspection.pendingCount > 0 || inspection.blockedCount > 0) {
      expect(fiveOfFive, isFalse);
    }
    if (fiveOfFive) {
      expect(inspection.pendingCount, 0);
      expect(inspection.blockedCount, 0);
    }
  });
}
