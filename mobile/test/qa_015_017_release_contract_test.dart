import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String workflow;
  late String receipt;

  setUpAll(() {
    workflow = File('../.github/workflows/flutter-preview.yml').readAsStringSync();
    receipt = File('../Last verified APK/VERIFIED_BUILD.md').readAsStringSync();
  });

  test('QA-015 workflow enforces analyze and full Flutter test gates', () {
    expect(workflow, contains('- name: Analyze'));
    expect(workflow, contains('flutter analyze'));
    expect(workflow, contains('- name: Test'));
    expect(workflow, contains('flutter test --reporter expanded'));
    expect(workflow, contains('set -o pipefail'));
  });

  test('QA-016 workflow builds and uploads an installable release APK', () {
    expect(workflow, contains('- name: Build installable release APK'));
    expect(workflow, contains('flutter build apk --release'));
    expect(workflow, contains('- name: Stage verified APK candidate'));
    expect(workflow, contains('WALKA-latest.apk'));
    expect(workflow, contains('- name: Upload installable APK candidate'));
    expect(workflow, contains('if-no-files-found: error'));
  });

  test('QA-016 Android bootstrap cannot silently change validated dependencies', () {
    final int bootstrap = workflow.indexOf('- name: Generate Android runner');
    final int reconcile = workflow.indexOf(
      '- name: Reconcile locked dependencies after Android bootstrap',
    );
    final int branding = workflow.indexOf('- name: Apply WALKA Android branding');
    final int build = workflow.indexOf('- name: Build installable release APK');

    expect(bootstrap, greaterThan(-1));
    expect(reconcile, greaterThan(bootstrap));
    expect(branding, greaterThan(reconcile));
    expect(build, greaterThan(branding));
    expect(workflow, contains('git restore --source=HEAD -- pubspec.lock'));
    expect(workflow, contains('flutter pub get --enforce-lockfile'));
    expect(workflow, contains('EXPECTED_LOCK_SHA'));
    expect(
      workflow,
      contains('git diff --exit-code -- pubspec.yaml pubspec.lock analysis_options.yaml'),
    );
  });

  test('QA-017 stable-main publication is guarded and publishes evidence', () {
    const String enforce =
        '- name: Enforce production and owner visual release before stable publication';
    const String guard = '- name: Guard stable main publication';
    const String publish =
        '- name: Publish latest verified APK and release evidence to main';

    final int enforceIndex = workflow.indexOf(enforce);
    final int guardIndex = workflow.indexOf(guard);
    final int publishIndex = workflow.indexOf(publish);

    expect(enforceIndex, greaterThan(-1));
    expect(guardIndex, greaterThan(enforceIndex));
    expect(publishIndex, greaterThan(guardIndex));
    expect(workflow, contains('remote_main='));
    expect(
      workflow,
      contains(
        r'if [[ "$remote_main" == "$GITHUB_SHA" ]]'.replaceAll(r'\"', '"'),
      ),
    );
    expect(workflow, contains('visual-release-gate-enforce.json'));
    expect(workflow, contains('RELEASE_TOOLCHAIN_CONTRACT.json'));
    expect(workflow, contains('pubspec.lock'));
    expect(workflow, contains('git push origin HEAD:main'));
  });

  test('QA-017 candidate receipt separates implementation and validation commits', () {
    expect(
      workflow,
      contains("IMPLEMENTATION_SHA: \${{ github.event_name == 'pull_request' && github.event.pull_request.head.sha || github.sha }}"),
    );
    expect(workflow, contains('- Source commit: \\`${IMPLEMENTATION_SHA}\\`'));
    expect(workflow, contains('- Validation commit: \\`${GITHUB_SHA}\\`'));
    expect(workflow, contains('- pubspec.lock SHA-256: \\`${DEPENDENCY_LOCK_SHA}\\`'));
  });

  test('QA-017 checked-in verified APK receipt matches file size contract', () {
    final File apk = File('../Last verified APK/WALKA-latest.apk');
    expect(apk.existsSync(), isTrue);

    final RegExpMatch? source = RegExp(
      r'Source commit: `([0-9a-f]{40})`',
    ).firstMatch(receipt);
    final RegExpMatch? bytes = RegExp(r'APK bytes: `(\d+)`').firstMatch(receipt);
    final RegExpMatch? sha = RegExp(
      r'APK SHA-256: `([0-9a-f]{64})`',
    ).firstMatch(receipt);

    expect(source, isNotNull);
    expect(bytes, isNotNull);
    expect(sha, isNotNull);
    expect(int.parse(bytes!.group(1)!), apk.lengthSync());
    expect(receipt, contains('Flutter Analyze + full Flutter Test suite'));
    expect(receipt, contains('stable `main`'));
  });
}
