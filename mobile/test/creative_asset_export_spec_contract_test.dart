import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pav_models.dart';

void main() {
  test('ASSET-002 export spec stays bound to executable PAV contract', () {
    final String spec = File('../docs/ui/CREATIVE_ASSET_EXPORT_SPEC.md').readAsStringSync();
    final String productionStandard =
        File('../docs/ui/CREATIVE_ASSET_PRODUCTION_STANDARD.md').readAsStringSync();

    expect(spec, contains('**$pavCanonicalWidth × $pavCanonicalHeight px**'));
    expect(spec, contains('**$pavCanonicalBitDepth-bit**'));
    expect(spec, contains('**RGBA / PNG color type $pavCanonicalColorType**'));
    expect(spec, contains('**${_groupDigits(pavHardFileBudgetBytes)} bytes (1.2 MiB)**'));

    final int safeMargin = (pavCanonicalWidth * 0.05).floor();
    expect(spec, contains('minimum of **$safeMargin px**'));
    expect(spec, contains('≥$safeMargin px safe margin'));

    for (final PavAssetContract contract in pavRequiredAssets) {
      expect(
        spec,
        contains('mobile/${contract.path}'),
        reason: '${contract.variantId} canonical path must be documented.',
      );
    }

    expect(
      productionStandard,
      contains('**exactly $pavCanonicalWidth×$pavCanonicalHeight px**'),
    );
    expect(
      productionStandard,
      isNot(contains('Default long-side target for reusable primary cutout: approximately **1600 px**')),
      reason: '1600px may describe editable source quality, never the canonical runtime canvas.',
    );
  });
}

String _groupDigits(int value) {
  final String digits = '$value';
  final StringBuffer output = StringBuffer();
  for (int index = 0; index < digits.length; index += 1) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      output.write(',');
    }
    output.write(digits[index]);
  }
  return output.toString();
}
