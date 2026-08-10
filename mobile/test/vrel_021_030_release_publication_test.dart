import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String workflow;

  setUpAll(() {
    workflow = File('../.github/workflows/flutter-preview.yml').readAsStringSync();
  });

  test('PR validation reports production asset readiness without blocking build', () {
    final int report = workflow.indexOf('Report production product asset readiness');
    final int build = workflow.indexOf('Build installable release APK');
    expect(report, greaterThan(-1));
    expect(build, greaterThan(report));
    expect(workflow, contains('bash tool/verify_production_assets.sh --report'));
  });

  test('engineering APK artifact is uploaded before stable asset enforcement', () {
    final int candidate = workflow.indexOf('Upload installable APK candidate');
    final int enforce = workflow.indexOf(
      'Enforce production product assets before stable publication',
    );
    final int staleGuard = workflow.indexOf('Guard stable main publication');
    final int publish = workflow.indexOf('Publish latest verified APK to main');

    expect(candidate, greaterThan(-1));
    expect(enforce, greaterThan(candidate));
    expect(staleGuard, greaterThan(enforce));
    expect(publish, greaterThan(staleGuard));
  });

  test('missing production assets block publication but keep diagnostics actionable', () {
    expect(workflow, contains('continue-on-error: true'));
    expect(
      workflow,
      contains("steps.production_asset_enforce.outcome == 'success'"),
    );
    expect(
      workflow,
      contains("steps.production_asset_enforce.outcome == 'failure'"),
    );
    expect(workflow, contains('production-asset-enforcement-block-'));
    expect(workflow, contains('production-asset-readiness-enforce.json'));
  });

  test('verified candidate receipt records production readiness and report digest', () {
    expect(workflow, contains('Production asset readiness:'));
    expect(workflow, contains('Production asset report SHA-256:'));
    expect(workflow, contains('PRODUCTION_ASSET_REPORT_SHA'));
    expect(workflow, contains('production-asset-readiness.json'));
  });

  test('stale-main guard remains mandatory after production asset enforcement', () {
    expect(workflow, contains('git ls-remote origin refs/heads/main'));
    expect(workflow, contains("if [[ \"\$remote_main\" == \"\$GITHUB_SHA\" ]]"));
    expect(workflow, contains("steps.main_guard.outputs.publish == 'true'"));
  });
}
