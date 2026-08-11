import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pav_models.dart';
import 'support/pav_png_fixture.dart';

late String _validatorPath;

void main() {
  setUpAll(() {
    _validatorPath = File('tool/verify_production_assets.dart').absolute.path;
  });

  test('report mode names all five missing variants without failing PR validation', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-vrel-report-');
    addTearDown(() => root.delete(recursive: true));
    await writePavManifest(root);

    final ProcessResult result = await _run(root, '--report');
    expect(result.exitCode, 0);

    final Map<String, dynamic> report = _readReport(root);
    expect(report['schemaVersion'], 2);
    expect(report['ready'], isFalse);
    expect(report['requiredCount'], 5);
    expect(report['readyCount'], 0);
    expect((report['assets'] as List<dynamic>).length, 5);
    expect(result.stdout, contains('drawer-white'));
    expect(result.stdout, contains('lunch-green'));
  });

  test('enforce mode blocks stable publication when canonical files are absent', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-vrel-enforce-');
    addTearDown(() => root.delete(recursive: true));
    await writePavManifest(root);

    final ProcessResult result = await _run(root, '--enforce');
    expect(result.exitCode, 1);
    expect(result.stderr, contains('stable owner-visible APK publication is blocked'));
  });

  test('five canonical RGBA PNGs with approved manifest satisfy admission gate', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-vrel-pass-');
    addTearDown(() => root.delete(recursive: true));
    await writePavManifest(root);
    await writeCanonicalPavAssets(root);

    final ProcessResult result = await _run(root, '--enforce');
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

    final Map<String, dynamic> report = _readReport(root);
    expect(report['ready'], isTrue);
    expect(report['readyCount'], 5);
    expect(report['blockerCount'], 0);
    final List<dynamic> assets = report['assets'] as List<dynamic>;
    expect(assets.every((dynamic row) => row['width'] == 1024), isTrue);
    expect(assets.every((dynamic row) => row['colorType'] == 6), isTrue);
    expect(assets.every((dynamic row) => row['hasColorProfile'] == true), isTrue);
  });

  test('invalid signature, non-RGBA and oversize runtime files are rejected', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-vrel-invalid-');
    addTearDown(() => root.delete(recursive: true));
    await writePavManifest(root);
    await writeCanonicalPavAssets(root);

    await File('${root.path}/${pavRequiredAssets[0].path}')
        .writeAsBytes(<int>[1, 2, 3], flush: true);
    await File('${root.path}/${pavRequiredAssets[1].path}').writeAsBytes(
      buildPavPng(colorType: 2),
      flush: true,
    );
    final File oversize = File('${root.path}/${pavRequiredAssets[2].path}');
    final Uint8List base = buildPavPng();
    await oversize.writeAsBytes(
      <int>[...base, ...List<int>.filled(pavHardFileBudgetBytes + 1, 0)],
      flush: true,
    );

    final ProcessResult result = await _run(root, '--enforce');
    expect(result.exitCode, 1);
    final Map<String, dynamic> report = _readReport(root);
    final List<dynamic> assets = report['assets'] as List<dynamic>;
    expect(assets[0]['issues'], contains('png.invalid-signature'));
    expect(assets[1]['issues'], contains('png.color-type-not-rgba'));
    expect(assets[2]['issues'], contains('png.file-budget-exceeded'));
  });
}

Future<ProcessResult> _run(Directory root, String mode) {
  return Process.run(
    'dart',
    <String>[
      _validatorPath,
      mode,
      '--root',
      root.path,
      '--manifest',
      '${root.path}/source-admission.json',
      '--json',
      '${root.path}/production-asset-readiness.json',
    ],
    workingDirectory: root.path,
  );
}

Map<String, dynamic> _readReport(Directory root) {
  return jsonDecode(
    File('${root.path}/production-asset-readiness.json').readAsStringSync(),
  ) as Map<String, dynamic>;
}
