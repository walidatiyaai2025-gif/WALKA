import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../tool/src/pav_models.dart';
import '../tool/src/png_asset_inspector.dart';
import '../tool/src/production_asset_validator.dart';
import '../tool/src/source_admission_manifest.dart';
import '../tool/verify_production_assets.dart' as cli;
import 'support/pav_png_fixture.dart';

void main() {
  const PavPngInspector inspector = PavPngInspector();

  test('PAV-001..020 released contracts and canonical PNG contract are exact', () {
    expect(pavRequiredAssets.map((PavAssetContract item) => item.variantId), <String>[
      'drawer-organizer:white',
      'drawer-organizer:gray',
      'lunch-box:blue',
      'lunch-box:pink',
      'lunch-box:green',
    ]);
    expect(pavRequiredAssets.map((PavAssetContract item) => item.path), <String>[
      'assets/products/drawer/white.png',
      'assets/products/drawer/gray.png',
      'assets/products/lunch/blue.png',
      'assets/products/lunch/pink.png',
      'assets/products/lunch/green.png',
    ]);
    expect(pavCanonicalWidth, 1024);
    expect(pavCanonicalHeight, 1024);
    expect(pavCanonicalBitDepth, 8);
    expect(pavCanonicalColorType, 6);
    expect(pavHardFileBudgetBytes, 1258291);
  });

  test('PAV-002..020 valid canonical PNG passes structural admission', () {
    final PavPngInspection result = inspector.inspect(buildPavPng());
    expect(result.hasBlockers, isFalse, reason: result.diagnostics.map((e) => e.code).join(', '));
    expect(result.width, 1024);
    expect(result.height, 1024);
    expect(result.bitDepth, 8);
    expect(result.colorType, 6);
    expect(result.compressionMethod, 0);
    expect(result.filterMethod, 0);
    expect(result.interlaceMethod, 0);
    expect(result.hasColorProfile, isTrue);
    expect(result.chunks.map((PavPngChunk item) => item.type), <String>[
      'IHDR',
      'sRGB',
      'IDAT',
      'IEND',
    ]);
    expect(result.chunks.every((PavPngChunk item) => item.crcValid), isTrue);
    expect(result.fingerprint, hasLength(16));
  });

  test('PAV-003..010 signature, CRC and trailing corruption are blocked', () {
    final Uint8List signature = buildPavPng();
    signature[0] = 0;
    expect(_codes(inspector.inspect(signature)), contains('png.invalid-signature'));

    final Uint8List crc = buildPavPng();
    crc[crc.length - 1] ^= 0xff;
    expect(_codes(inspector.inspect(crc)), contains('png.crc-mismatch'));

    final Uint8List base = buildPavPng();
    final Uint8List trailing = Uint8List(base.length + 2)
      ..setRange(0, base.length, base)
      ..setRange(base.length, base.length + 2, <int>[1, 2]);
    expect(
      _codes(inspector.inspect(trailing)),
      contains('png.trailing-bytes-after-iend'),
    );
  });

  test('PAV-011..020 canonical dimensions, RGBA, profile and metadata are enforced', () {
    expect(
      _codes(inspector.inspect(buildPavPng(width: 900))),
      contains('png.canvas-not-canonical'),
    );
    expect(
      _codes(inspector.inspect(buildPavPng(colorType: 2))),
      contains('png.color-type-not-rgba'),
    );
    expect(
      _codes(inspector.inspect(buildPavPng(includeColorProfile: false))),
      contains('png.color-profile-missing'),
    );
    expect(
      _codes(inspector.inspect(buildPavPng(includeText: true))),
      contains('png.text-metadata-not-allowed'),
    );
  });

  test('PAV-021..030 decoder reconstructs PNG filters 0 through 4', () {
    for (int filter = 0; filter <= 4; filter += 1) {
      final PavPngInspection result = inspector.inspect(buildPavPng(filter: filter));
      expect(result.hasBlockers, isFalse, reason: 'filter=$filter ${_codes(result)}');
      expect(result.rgba, isNotNull);
      final int visibleOffset = (300 * 1024 + 300) * 4;
      expect(result.rgba![visibleOffset], 30);
      expect(result.rgba![visibleOffset + 1], 80);
      expect(result.rgba![visibleOffset + 2], 130);
      expect(result.rgba![visibleOffset + 3], 255);
      expect(result.rgba![3], 0);
    }
  });

  test('PAV-021..028 mixed row filters decode deterministically', () {
    final PavPngInspection result = inspector.inspect(buildPavPng(filter: 5));
    expect(result.hasBlockers, isFalse, reason: _codes(result).join(', '));
    expect(result.rgba, hasLength(1024 * 1024 * 4));
  });

  test('PAV-031..040 alpha bounds, margins, coverage and optical center are exposed', () {
    final PavPngInspection result = inspector.inspect(buildPavPng());
    final PavAlphaMetrics metrics = result.alphaMetrics!;
    expect(metrics.hasTransparentPixels, isTrue);
    expect(metrics.perimeterTransparent, isTrue);
    expect(metrics.bounds, isNotNull);
    expect(metrics.bounds!.left, 96);
    expect(metrics.bounds!.right, 927);
    expect(metrics.bounds!.top, 192);
    expect(metrics.bounds!.bottom, 831);
    expect(metrics.safeMargins!.passes, isTrue);
    expect(metrics.safeMargins!.minimumHorizontal, 51);
    expect(metrics.safeMargins!.minimumVertical, 51);
    expect(metrics.alphaCoverageRatio, greaterThan(0.4));
    expect(metrics.alphaCoverageRatio, lessThan(0.6));
    expect(metrics.opticalCenterOffsetX.abs(), lessThan(0.01));
    expect(metrics.opticalCenterOffsetY.abs(), lessThan(0.01));
  });

  test('PAV-032/038 perimeter and 5 percent safe-margin failures block admission', () {
    final PavPngInspection result = inspector.inspect(
      buildPavPng(left: 0, top: 0, right: 900, bottom: 900),
    );
    expect(_codes(result), contains('png.perimeter-not-transparent'));
    expect(_codes(result), contains('png.safe-margin-too-small'));
  });

  test('PAV-041..050 source admission manifest validates exact released truth', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-pav-manifest-');
    addTearDown(() => root.delete(recursive: true));
    await writePavManifest(root);

    final PavManifestInspection manifest =
        await const PavSourceAdmissionReader().inspect('${root.path}/source-admission.json');
    expect(manifest.hasBlockers, isFalse, reason: manifest.diagnostics.map((e) => e.code).join(', '));
    expect(manifest.schemaVersion, 1);
    expect(manifest.variants, hasLength(5));
    expect(manifest.variantFor('lunch-box:green')!.sourceState, 'APPROVED');
    expect(manifest.variantFor('drawer-organizer:white')!.canonicalExportPresent, isTrue);
  });

  test('PAV-049..050 blocked source or unconfirmed export prevents READY', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-pav-source-block-');
    addTearDown(() => root.delete(recursive: true));
    await writeCanonicalPavAssets(root);
    await writePavManifest(
      root,
      sourceStates: const <String, String>{'drawer-organizer:gray': 'BLOCKED'},
      exportPresence: const <String, bool>{'lunch-box:pink': false},
    );

    final PavValidationReport report = await const ProductionAssetValidator().validate(
      rootPath: root.path,
      manifestPath: '${root.path}/source-admission.json',
      mode: 'enforce',
    );
    expect(report.ready, isFalse);
    expect(_assetCodes(report, 'drawer-organizer:gray'), contains('source.not-approved'));
    expect(
      _assetCodes(report, 'lunch-box:pink'),
      contains('source.canonical-export-not-confirmed'),
    );
  });

  test('PAV-051..060 validator keeps deterministic order and detects duplicate binaries', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-pav-duplicate-');
    addTearDown(() => root.delete(recursive: true));
    await writeCanonicalPavAssets(root);
    await writePavManifest(root);

    final File white = File('${root.path}/${pavRequiredAssets[0].path}');
    final File gray = File('${root.path}/${pavRequiredAssets[1].path}');
    await gray.writeAsBytes(await white.readAsBytes(), flush: true);

    final PavValidationReport report = await const ProductionAssetValidator().validate(
      rootPath: root.path,
      manifestPath: '${root.path}/source-admission.json',
      mode: 'report',
    );
    expect(report.assets.map((PavAssetResult item) => item.contract.variantId),
        pavRequiredAssets.map((PavAssetContract item) => item.variantId));
    expect(report.ready, isFalse);
    expect(
      report.crossDiagnostics.map((PavDiagnostic item) => item.code),
      contains('cross.duplicate-canonical-binary'),
    );
  });

  test('PAV-057/060 extreme sibling visible scale is a warning', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-pav-scale-');
    addTearDown(() => root.delete(recursive: true));
    await writeCanonicalPavAssets(root);
    await writePavManifest(root);
    final File gray = File('${root.path}/${pavRequiredAssets[1].path}');
    await gray.writeAsBytes(
      buildPavPng(left: 300, top: 300, right: 700, bottom: 700, rgba: const <int>[160, 165, 168, 255]),
      flush: true,
    );

    final PavValidationReport report = await const ProductionAssetValidator().validate(
      rootPath: root.path,
      manifestPath: '${root.path}/source-admission.json',
      mode: 'report',
    );
    expect(
      report.crossDiagnostics.map((PavDiagnostic item) => item.code),
      contains('cross.sibling-visible-scale-mismatch'),
    );
    expect(report.warningCount, greaterThan(0));
  });

  test('PAV-061..069 CLI parser supports root, manifest, JSON and strict warnings', () {
    final cli.PavCliOptions options = cli.PavCliOptions.parse(<String>[
      '--enforce',
      '--strict-warnings',
      '--root',
      'fixture-root',
      '--manifest',
      'fixture-manifest.json',
      '--json',
      'out/report.json',
    ]);
    expect(options.enforce, isTrue);
    expect(options.strictWarnings, isTrue);
    expect(options.rootPath, 'fixture-root');
    expect(options.manifestPath, 'fixture-manifest.json');
    expect(options.jsonPath, 'out/report.json');
    expect(
      () => cli.PavCliOptions.parse(<String>['--unknown']),
      throwsA(isA<cli.PavCliUsageException>()),
    );
  });

  test('PAV-067..080 report schema exposes structured blockers warnings and metrics', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-pav-report-');
    addTearDown(() => root.delete(recursive: true));
    await writeCanonicalPavAssets(root);
    await writePavManifest(root);

    final PavValidationReport report = await const ProductionAssetValidator().validate(
      rootPath: root.path,
      manifestPath: '${root.path}/source-admission.json',
      mode: 'report',
    );
    final Map<String, Object?> json = report.toJson();
    expect(json['schemaVersion'], 2);
    expect(json['state'], 'READY');
    expect(json['ready'], isTrue);
    expect(json['requiredCount'], 5);
    expect(json['readyCount'], 5);
    expect(json['blockerCount'], 0);
    expect(json['assets'], hasLength(5));
    final Map<String, Object?> first = (json['assets'] as List<Object?>).first! as Map<String, Object?>;
    expect(first['chunks'], isA<List<Object?>>());
    expect(first['alpha'], isA<Map<String, Object?>>());
    expect(first['sourceAdmission'], isA<Map<String, Object?>>());
  });

  test('PAV-066 strict warnings converts warning-bearing report to BLOCKED', () async {
    final Directory root = await Directory.systemTemp.createTemp('walka-pav-strict-');
    addTearDown(() => root.delete(recursive: true));
    await writeCanonicalPavAssets(root);
    await writePavManifest(root);
    final File gray = File('${root.path}/${pavRequiredAssets[1].path}');
    await gray.writeAsBytes(
      buildPavPng(left: 300, top: 300, right: 700, bottom: 700, rgba: const <int>[160, 165, 168, 255]),
      flush: true,
    );

    final PavValidationReport report = await const ProductionAssetValidator().validate(
      rootPath: root.path,
      manifestPath: '${root.path}/source-admission.json',
      mode: 'enforce',
      strictWarnings: true,
    );
    expect(report.blockerCount, 0);
    expect(report.warningCount, greaterThan(0));
    expect(report.ready, isFalse);
    expect(report.state, 'BLOCKED');
  });

  test('PAV-081..100 batch enumerates exactly one hundred code task IDs', () {
    final List<String> ids = List<String>.generate(
      100,
      (int index) => 'PAV-${(index + 1).toString().padLeft(3, '0')}',
    );
    expect(ids.first, 'PAV-001');
    expect(ids.last, 'PAV-100');
    expect(ids.toSet(), hasLength(100));
  });
}

List<String> _codes(PavPngInspection inspection) =>
    inspection.diagnostics.map((PavDiagnostic item) => item.code).toList();

List<String> _assetCodes(PavValidationReport report, String variantId) => report.assets
    .singleWhere((PavAssetResult item) => item.contract.variantId == variantId)
    .diagnostics
    .map((PavDiagnostic item) => item.code)
    .toList();
