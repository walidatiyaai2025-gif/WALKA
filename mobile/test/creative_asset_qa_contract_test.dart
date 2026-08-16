import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pav_models.dart';

void main() {
  test('ASSET-010 QA receipt matches source admission and production provenance', () {
    final String receipt = File('../docs/ui/CREATIVE_ASSET_QA.md').readAsStringSync();
    final Map<String, dynamic> provenance = _readJson(
      '../docs/ui/PRODUCTION_ASSET_PROVENANCE.json',
    );
    final Map<String, dynamic> admission = _readJson(
      '../docs/ui/PRODUCTION_SOURCE_ADMISSION.json',
    );

    final List<String> mandatoryChecks = (provenance['mandatoryQaChecks'] as List<dynamic>)
        .cast<String>();
    final Map<String, Map<String, dynamic>> admissionByVariant = <String, Map<String, dynamic>>{
      for (final dynamic raw in admission['variants'] as List<dynamic>)
        (raw as Map<String, dynamic>)['variantId'] as String: raw,
    };

    int passCount = 0;
    int blockedCount = 0;

    for (final dynamic raw in provenance['variants'] as List<dynamic>) {
      final Map<String, dynamic> variant = raw as Map<String, dynamic>;
      final String variantId = variant['variantId'] as String;
      final String lifecycle = variant['lifecycleState'] as String;
      final String canonicalPath = variant['canonicalPath'] as String;
      final Map<String, dynamic> source = admissionByVariant[variantId]!;
      final bool admitted = lifecycle == 'ADMITTED';
      final String expectedReceiptState = admitted ? 'PASS' : 'BLOCKED';

      expect(
        receipt,
        matches(
          RegExp(
            r'\| `' +
                RegExp.escape(variantId) +
                r'` \| `mobile/' +
                RegExp.escape(canonicalPath) +
                r'` \| \*\*' +
                expectedReceiptState +
                r'\*\* \|',
          ),
        ),
        reason: '$variantId must have the correct per-file ASSET-010 state.',
      );
      expect(
        source['canonicalPath'],
        canonicalPath,
        reason: '$variantId source admission and provenance paths must agree.',
      );

      if (admitted) {
        passCount += 1;
        expect(source['sourceState'], 'APPROVED');
        expect(source['canonicalExportPresent'], isTrue);
        expect(variant['width'], pavCanonicalWidth);
        expect(variant['height'], pavCanonicalHeight);
        expect(variant['byteSize'] as int, lessThanOrEqualTo(pavHardFileBudgetBytes));
        expect(
          variant['nearestTransparentSafeMargin'] as int,
          greaterThanOrEqualTo((pavCanonicalWidth * 0.05).floor()),
        );

        final String sha256 = variant['sha256'] as String;
        expect(sha256, matches(RegExp(r'^[a-f0-9]{64}$')));
        expect(receipt, contains('`$sha256`'));

        final Map<String, dynamic> qa = variant['qa'] as Map<String, dynamic>;
        for (final String check in mandatoryChecks) {
          expect(
            qa[check],
            'PASS',
            reason: '$variantId cannot be documented PASS while $check is not PASS.',
          );
        }
      } else {
        blockedCount += 1;
        expect(
          source['canonicalExportPresent'],
          isFalse,
          reason: '$variantId must not be documented BLOCKED while source admission claims a canonical export.',
        );
      }
    }

    expect(receipt, contains('$passCount PASS / $blockedCount BLOCKED'));
    expect(receipt, contains('does not authorize stable publication'));
    expect(receipt, contains('#220/#230'));
  });
}

Map<String, dynamic> _readJson(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}
