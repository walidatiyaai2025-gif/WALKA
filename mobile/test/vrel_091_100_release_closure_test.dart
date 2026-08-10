import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VREL batch receipts cover every atomic ID from 001 through 100', () {
    final List<String> receiptPaths = <String>[
      '../docs/work/VREL-001-010-021-030.md',
      '../docs/work/VREL-011-020.md',
      '../docs/work/VREL-031-060.md',
      '../docs/work/VREL-061-070.md',
      '../docs/work/VREL-071-080.md',
      '../docs/work/VREL-081-090.md',
      '../docs/work/VREL-091-100.md',
    ];
    final String receipts = receiptPaths
        .map((String path) => File(path).readAsStringSync())
        .join('\n');

    for (int number = 1; number <= 100; number += 1) {
      final String id = 'VREL-${number.toString().padLeft(3, '0')}';
      expect(receipts, contains(id), reason: 'Missing task receipt for $id');
    }
  });

  test('closure readiness reconciles exactly the five released variant IDs', () {
    final Map<String, dynamic> admission = jsonDecode(
      File('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final Set<String> variants = (admission['variants'] as List<dynamic>)
        .map((dynamic row) => row['variantId'] as String)
        .toSet();

    expect(
      variants,
      equals(<String>{
        'drawer-organizer:white',
        'drawer-organizer:gray',
        'lunch-box:blue',
        'lunch-box:pink',
        'lunch-box:green',
      }),
    );

    final String readiness = File(
      '../docs/ui/PRODUCT_MEDIA_RELEASE_READINESS.md',
    ).readAsStringSync();
    expect(readiness, contains('Drawer Organizer — White'));
    expect(readiness, contains('Drawer Organizer — Gray'));
    expect(readiness, contains('Lunch Box — Blue'));
    expect(readiness, contains('Lunch Box — Pink'));
    expect(readiness, contains('Lunch Box — Green'));
  });

  test('current owner-visible verified APK remains pinned to the pre-gate receipt', () {
    final String receipt = File(
      '../Last verified APK/VERIFIED_BUILD.md',
    ).readAsStringSync();
    expect(
      receipt,
      contains('01cb7c1a01b82f4e126220e1e0ee481d7710e258'),
    );
    expect(receipt, contains('Workflow run number: `632`'));

    final String readiness = File(
      '../docs/ui/PRODUCT_MEDIA_RELEASE_READINESS.md',
    ).readAsStringSync();
    expect(readiness, contains('Owner-visible production-media release state: BLOCKED'));
    expect(readiness, contains('run #632'));
  });

  test('closure workflow keeps protected master guard and asset enforcement before publication', () {
    final String workflow =
        File('../.github/workflows/flutter-preview.yml').readAsStringSync();

    final int protectedGuard =
        workflow.indexOf('Guard protected reference masters');
    final int analyze = workflow.indexOf('Analyze');
    final int tests = workflow.indexOf('Test');
    final int report =
        workflow.indexOf('Report production product asset readiness');
    final int build = workflow.indexOf('Build installable release APK');
    final int candidate = workflow.indexOf('Upload installable APK candidate');
    final int enforce = workflow.indexOf(
      'Enforce production product assets before stable publication',
    );
    final int staleGuard = workflow.indexOf('Guard stable main publication');
    final int publish = workflow.indexOf('Publish latest verified APK to main');

    expect(protectedGuard, greaterThan(-1));
    expect(analyze, greaterThan(protectedGuard));
    expect(tests, greaterThan(analyze));
    expect(report, greaterThan(tests));
    expect(build, greaterThan(report));
    expect(candidate, greaterThan(build));
    expect(enforce, greaterThan(candidate));
    expect(staleGuard, greaterThan(enforce));
    expect(publish, greaterThan(staleGuard));
  });

  test('visual acceptance lifecycle distinguishes PASS BLOCKED and REOPEN', () {
    final String readiness = File(
      '../docs/ui/PRODUCT_MEDIA_RELEASE_READINESS.md',
    ).readAsStringSync();
    expect(readiness, contains('### PASS'));
    expect(readiness, contains('### BLOCKED'));
    expect(readiness, contains('### REOPEN'));
    expect(readiness, contains('Rollback procedure'));
    expect(readiness, contains('Final owner review checklist'));
  });

  test('batch receipt keeps visual blocker open rather than claiming photography readiness', () {
    final String batch =
        File('../docs/work/VREL-BATCH-100.md').readAsStringSync();
    expect(batch, contains('Production visual-release completion'));
    expect(batch, contains('Issue #230 remains open'));
    expect(batch, contains('Drawer Gray source: BLOCKED'));
    expect(batch, contains('Closure validation pending'));
  });
}
