import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PAV-091..096 Flutter Preview wires source admission and schema-v2 diagnostics', () {
    final String workflow = File('../.github/workflows/flutter-preview.yml').readAsStringSync();

    expect(workflow, contains("- 'agent/pav-*'"));
    expect(
      workflow,
      contains(
        r'verify_production_assets.sh --report --root . --manifest "$manifest" --json "$report"',
      ),
    );
    expect(workflow, contains("manifest='../docs/ui/PRODUCTION_SOURCE_ADMISSION.json'"));
    expect(workflow, contains("['blockerCount']"));
    expect(workflow, contains("['warningCount']"));
    expect(workflow, contains('#### Per-variant admission state'));
    expect(workflow, contains("asset['variantId']"));
    expect(
      workflow,
      contains(
        'verify_production_assets.sh --enforce --root . --manifest ../docs/ui/PRODUCTION_SOURCE_ADMISSION.json --json production-asset-readiness-enforce.json',
      ),
    );
    expect(workflow, isNot(contains('Images/')));
  });
}
