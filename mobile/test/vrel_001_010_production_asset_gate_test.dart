import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const List<String> _paths = <String>[
  'assets/products/drawer/white.png',
  'assets/products/drawer/gray.png',
  'assets/products/lunch/blue.png',
  'assets/products/lunch/pink.png',
  'assets/products/lunch/green.png',
];

late String _validatorPath;

void main() {
  setUpAll(() {
    _validatorPath = File('tool/verify_production_assets.dart').absolute.path;
  });

  test('report mode names all five missing variants without failing PR validation', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-vrel-report-');
    addTearDown(() => root.delete(recursive: true));

    final ProcessResult result = await _run(root, '--report');
    expect(result.exitCode, 0);

    final Map<String, dynamic> report = _readReport(root);
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

    final ProcessResult result = await _run(root, '--enforce');
    expect(result.exitCode, 1);
    expect(result.stderr, contains('stable owner-visible APK publication is blocked'));
  });

  test('five sane RGBA PNG headers satisfy the structural production gate', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-vrel-pass-');
    addTearDown(() => root.delete(recursive: true));
    for (final String path in _paths) {
      await _writePngHeader(root, path, width: 1024, height: 1024, colorType: 6);
    }

    final ProcessResult result = await _run(root, '--enforce');
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

    final Map<String, dynamic> report = _readReport(root);
    expect(report['ready'], isTrue);
    expect(report['readyCount'], 5);
    final List<dynamic> assets = report['assets'] as List<dynamic>;
    expect(assets.every((dynamic row) => row['width'] == 1024), isTrue);
    expect(assets.every((dynamic row) => row['colorType'] == 6), isTrue);
  });

  test('invalid signature, missing alpha and oversize files are rejected', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-vrel-invalid-');
    addTearDown(() => root.delete(recursive: true));

    for (final String path in _paths) {
      await _writePngHeader(root, path, width: 1024, height: 1024, colorType: 6);
    }
    await File('${root.path}/${_paths[0]}').writeAsBytes(<int>[1, 2, 3], flush: true);
    await _writePngHeader(root, _paths[1], width: 1024, height: 1024, colorType: 2);
    final File oversize = File('${root.path}/${_paths[2]}');
    await oversize.writeAsBytes(
      <int>[
        ..._pngHeader(width: 1024, height: 1024, colorType: 6),
        ...List<int>.filled(1258292, 0),
      ],
      flush: true,
    );

    final ProcessResult result = await _run(root, '--enforce');
    expect(result.exitCode, 1);
    final Map<String, dynamic> report = _readReport(root);
    final List<dynamic> assets = report['assets'] as List<dynamic>;
    expect(assets[0]['issues'], contains('truncated-png-header'));
    expect(assets[1]['issues'], contains('alpha-required-color-type-2'));
    expect(assets[2]['issues'], contains('over-1.2mb-production-budget'));
  });
}

Future<ProcessResult> _run(Directory root, String mode) {
  return Process.run(
    Platform.resolvedExecutable,
    <String>[_validatorPath, mode, '--json', 'production-asset-readiness.json'],
    workingDirectory: root.path,
  );
}

Map<String, dynamic> _readReport(Directory root) {
  return jsonDecode(
    File('${root.path}/production-asset-readiness.json').readAsStringSync(),
  ) as Map<String, dynamic>;
}

Future<void> _writePngHeader(
  Directory root,
  String path, {
  required int width,
  required int height,
  required int colorType,
}) async {
  final File file = File('${root.path}/$path');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(
    _pngHeader(width: width, height: height, colorType: colorType),
    flush: true,
  );
}

List<int> _pngHeader({
  required int width,
  required int height,
  required int colorType,
}) {
  final Uint8List bytes = Uint8List(33);
  bytes.setAll(0, <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  final ByteData data = ByteData.sublistView(bytes);
  data.setUint32(8, 13, Endian.big);
  bytes.setAll(12, ascii.encode('IHDR'));
  data.setUint32(16, width, Endian.big);
  data.setUint32(20, height, Endian.big);
  bytes[24] = 8;
  bytes[25] = colorType;
  bytes[26] = 0;
  bytes[27] = 0;
  bytes[28] = 0;
  return bytes;
}
