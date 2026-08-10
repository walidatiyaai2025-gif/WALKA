import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const int _hardFileBudgetBytes = 1258291; // 1.2 MiB review ceiling.
const int _minimumHeaderBytes = 33;
const List<int> _pngSignature = <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
const List<int> _alphaCapableColorTypes = <int>[4, 6];

const List<_RequiredAsset> _requiredAssets = <_RequiredAsset>[
  _RequiredAsset('drawer-white', 'assets/products/drawer/white.png'),
  _RequiredAsset('drawer-gray', 'assets/products/drawer/gray.png'),
  _RequiredAsset('lunch-blue', 'assets/products/lunch/blue.png'),
  _RequiredAsset('lunch-pink', 'assets/products/lunch/pink.png'),
  _RequiredAsset('lunch-green', 'assets/products/lunch/green.png'),
];

Future<void> main(List<String> args) async {
  final _Options options = _Options.parse(args);
  final List<_AssetResult> results = <_AssetResult>[];
  for (final _RequiredAsset asset in _requiredAssets) {
    results.add(await _inspect(asset));
  }

  final bool ready = results.every((_AssetResult result) => result.ready);
  final Map<String, Object?> report = <String, Object?>{
    'schemaVersion': 1,
    'mode': options.enforce ? 'enforce' : 'report',
    'ready': ready,
    'requiredCount': _requiredAssets.length,
    'readyCount': results.where((_AssetResult result) => result.ready).length,
    'hardFileBudgetBytes': _hardFileBudgetBytes,
    'assets': results.map((_AssetResult result) => result.toJson()).toList(),
  };

  final String encoded = const JsonEncoder.withIndent('  ').convert(report);
  final File reportFile = File(options.jsonPath);
  await reportFile.parent.create(recursive: true);
  await reportFile.writeAsString('$encoded\n');

  stdout.writeln('WALKA production product asset gate');
  stdout.writeln('Mode: ${options.enforce ? 'ENFORCE' : 'REPORT'}');
  stdout.writeln('Ready: ${ready ? 'YES' : 'NO'}');
  stdout.writeln('Valid: ${report['readyCount']}/${report['requiredCount']}');
  stdout.writeln('Report: ${options.jsonPath}');
  for (final _AssetResult result in results) {
    stdout.writeln(result.summary);
  }

  if (options.enforce && !ready) {
    stderr.writeln(
      'FAIL: stable owner-visible APK publication is blocked until every '
      'released product variant has a valid approved canonical production PNG.',
    );
    exitCode = 1;
  }
}

Future<_AssetResult> _inspect(_RequiredAsset asset) async {
  final File file = File(asset.path);
  if (!await file.exists()) {
    return _AssetResult(asset: asset, issues: const <String>['missing']);
  }

  final int bytes = await file.length();
  if (bytes == 0) {
    return _AssetResult(asset: asset, bytes: 0, issues: const <String>['empty']);
  }

  final RandomAccessFile handle = await file.open();
  late final Uint8List header;
  try {
    header = await handle.read(_minimumHeaderBytes);
  } finally {
    await handle.close();
  }

  final List<String> issues = <String>[];
  if (header.length < _minimumHeaderBytes) {
    issues.add('truncated-png-header');
    return _AssetResult(asset: asset, bytes: bytes, issues: issues);
  }

  if (!_matchesSignature(header)) {
    issues.add('invalid-png-signature');
    return _AssetResult(asset: asset, bytes: bytes, issues: issues);
  }

  final String chunkType = ascii.decode(header.sublist(12, 16), allowInvalid: true);
  if (chunkType != 'IHDR') {
    issues.add('missing-ihdr');
    return _AssetResult(asset: asset, bytes: bytes, issues: issues);
  }

  final ByteData data = ByteData.sublistView(header);
  final int width = data.getUint32(16, Endian.big);
  final int height = data.getUint32(20, Endian.big);
  final int bitDepth = header[24];
  final int colorType = header[25];

  if (width <= 0 || height <= 0 || width > 8192 || height > 8192) {
    issues.add('invalid-dimensions');
  }
  if (!_alphaCapableColorTypes.contains(colorType)) {
    issues.add('alpha-required-color-type-$colorType');
  }
  if (bytes > _hardFileBudgetBytes) {
    issues.add('over-1.2mb-production-budget');
  }

  return _AssetResult(
    asset: asset,
    bytes: bytes,
    width: width,
    height: height,
    bitDepth: bitDepth,
    colorType: colorType,
    issues: issues,
  );
}

bool _matchesSignature(Uint8List bytes) {
  for (int index = 0; index < _pngSignature.length; index += 1) {
    if (bytes[index] != _pngSignature[index]) {
      return false;
    }
  }
  return true;
}

class _RequiredAsset {
  const _RequiredAsset(this.variantId, this.path);

  final String variantId;
  final String path;
}

class _AssetResult {
  const _AssetResult({
    required this.asset,
    required this.issues,
    this.bytes,
    this.width,
    this.height,
    this.bitDepth,
    this.colorType,
  });

  final _RequiredAsset asset;
  final List<String> issues;
  final int? bytes;
  final int? width;
  final int? height;
  final int? bitDepth;
  final int? colorType;

  bool get ready => issues.isEmpty;

  String get summary {
    final String details = width == null
        ? ''
        : ' ${width}x$height ${bytes ?? 0}B colorType=$colorType';
    final String state = ready ? 'PASS' : 'BLOCKED(${issues.join(',')})';
    return '- ${asset.variantId}: $state$details — ${asset.path}';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'variantId': asset.variantId,
        'path': asset.path,
        'ready': ready,
        'issues': issues,
        if (bytes != null) 'bytes': bytes,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (bitDepth != null) 'bitDepth': bitDepth,
        if (colorType != null) 'colorType': colorType,
      };
}

class _Options {
  const _Options({required this.enforce, required this.jsonPath});

  final bool enforce;
  final String jsonPath;

  static _Options parse(List<String> args) {
    bool enforce = false;
    String jsonPath = 'production-asset-readiness.json';

    for (int index = 0; index < args.length; index += 1) {
      final String arg = args[index];
      switch (arg) {
        case '--report':
          enforce = false;
          break;
        case '--enforce':
          enforce = true;
          break;
        case '--json':
          if (index + 1 >= args.length) {
            stderr.writeln('Missing path after --json.');
            exit(2);
          }
          jsonPath = args[++index];
          break;
        default:
          stderr.writeln('Unknown argument: $arg');
          exit(2);
      }
    }

    return _Options(enforce: enforce, jsonPath: jsonPath);
  }
}
