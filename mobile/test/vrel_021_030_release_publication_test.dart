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

  test('engineering APK artifact precedes production and owner enforcement', () {
    final int candidate = workflow.indexOf('Upload installable APK candidate');
    final int enforce = workflow.indexOf(
      'Enforce production and owner visual release before stable publication',
    );
    final int staleGuard = workflow.indexOf('Guard stable main publication');
    final int publish = workflow.indexOf(
      'Publish latest verified APK and release evidence to main',
    );

    expect(candidate, greaterThan(-1));
    expect(enforce, greaterThan(candidate));
    expect(staleGuard, greaterThan(enforce));
    expect(publish, greaterThan(staleGuard));
  });

  test('blocked release uploads both production and owner diagnostics', () {
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
    expect(workflow, contains('visual-release-gate-enforce.json'));
  });

  test('verified candidate receipt records readiness and deterministic inputs', () {
    expect(workflow, contains('Production asset readiness:'));
    expect(workflow, contains('Production asset report SHA-256:'));
    expect(workflow, contains('PRODUCTION_ASSET_REPORT_SHA'));
    expect(workflow, contains('production-asset-readiness.json'));
    expect(workflow, contains('Visual input digest:'));
    expect(workflow, contains('Release input digest:'));
    expect(workflow, contains('pubspec.lock SHA-256:'));
  });

  test('stale-main guard remains mandatory after owner release enforcement', () {
    expect(workflow, contains('git ls-remote origin refs/heads/main'));
    expect(workflow, contains("if [[ \"\$remote_main\" == \"\$GITHUB_SHA\" ]]"));
    expect(workflow, contains("steps.main_guard.outputs.publish == 'true'"));
  });
}
