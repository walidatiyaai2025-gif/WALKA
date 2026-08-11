import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../tool/src/pav_models.dart';
import '../../tool/src/png_asset_inspector.dart';

Future<void> writePavManifest(
  Directory root, {
  Map<String, String> sourceStates = const <String, String>{},
  Map<String, bool> exportPresence = const <String, bool>{},
}) async {
  final Map<String, Object?> manifest = <String, Object?>{
    'schemaVersion': 1,
    'allowedSourceStates': <String>['APPROVED', 'BLOCKED', 'REPLACE'],
    'protectedRuntimeSourcePrefixes': <String>['Images/'],
    'variants': pavRequiredAssets.map((PavAssetContract contract) {
      return <String, Object?>{
        'variantId': contract.variantId,
        'family': contract.family,
        'variant': contract.variant,
        'sourceId': 'TEST-${contract.legacyId.toUpperCase()}',
        'sourceFilename': '${contract.legacyId}.jpg',
        'sourceState': sourceStates[contract.variantId] ?? 'APPROVED',
        'canonicalPath': contract.path,
        'canonicalExportPresent': exportPresence[contract.variantId] ?? true,
      };
    }).toList(),
  };
  final File file = File('${root.path}/source-admission.json');
  await file.writeAsString('${const JsonEncoder.withIndent('  ').convert(manifest)}\n');
}

Future<void> writeCanonicalPavAssets(
  Directory root, {
  int filter = 0,
}) async {
  const List<List<int>> colors = <List<int>>[
    <int>[238, 236, 229, 255],
    <int>[160, 165, 168, 255],
    <int>[90, 120, 155, 255],
    <int>[225, 150, 174, 255],
    <int>[163, 168, 94, 255],
  ];
  for (int index = 0; index < pavRequiredAssets.length; index += 1) {
    final PavAssetContract contract = pavRequiredAssets[index];
    final File file = File('${root.path}/${contract.path}');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(
      buildPavPng(
        rgba: colors[index],
        filter: filter,
      ),
      flush: true,
    );
  }
}

Uint8List buildPavPng({
  int width = pavCanonicalWidth,
  int height = pavCanonicalHeight,
  int colorType = pavCanonicalColorType,
  int bitDepth = pavCanonicalBitDepth,
  int filter = 0,
  List<int> rgba = const <int>[30, 80, 130, 255],
  int left = 96,
  int top = 192,
  int right = 927,
  int bottom = 831,
  bool includeColorProfile = true,
  bool includeText = false,
}) {
  final Uint8List ihdr = Uint8List(13);
  final ByteData ihdrData = ByteData.sublistView(ihdr);
  ihdrData.setUint32(0, width, Endian.big);
  ihdrData.setUint32(4, height, Endian.big);
  ihdr[8] = bitDepth;
  ihdr[9] = colorType;
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;

  final Uint8List reconstructed = Uint8List(width * height * 4);
  for (int y = 0; y < height; y += 1) {
    for (int x = 0; x < width; x += 1) {
      final int offset = (y * width + x) * 4;
      final bool visible = x >= left && x <= right && y >= top && y <= bottom;
      if (visible) {
        reconstructed[offset] = rgba[0];
        reconstructed[offset + 1] = rgba[1];
        reconstructed[offset + 2] = rgba[2];
        reconstructed[offset + 3] = rgba[3];
      }
    }
  }

  final Uint8List filtered = _encodeScanlines(
    reconstructed,
    width: width,
    height: height,
    filter: filter,
  );
  final List<int> compressed = const ZLibEncoder().convert(filtered);

  final BytesBuilder output = BytesBuilder(copy: false)..add(pavPngSignature);
  output.add(_chunk('IHDR', ihdr));
  if (includeColorProfile) {
    output.add(_chunk('sRGB', Uint8List.fromList(<int>[0])));
  }
  if (includeText) {
    output.add(_chunk('tEXt', Uint8List.fromList(utf8.encode('note\u0000fixture'))));
  }
  output.add(_chunk('IDAT', Uint8List.fromList(compressed)));
  output.add(_chunk('IEND', Uint8List(0)));
  return output.takeBytes();
}

Uint8List _encodeScanlines(
  Uint8List rgba, {
  required int width,
  required int height,
  required int filter,
}) {
  const int bytesPerPixel = 4;
  final int rowBytes = width * bytesPerPixel;
  final Uint8List encoded = Uint8List(height * (rowBytes + 1));
  Uint8List previous = Uint8List(rowBytes);
  int outputOffset = 0;
  for (int y = 0; y < height; y += 1) {
    final int rowFilter = filter == 5 ? y % 5 : filter;
    encoded[outputOffset++] = rowFilter;
    final Uint8List current = Uint8List.sublistView(
      rgba,
      y * rowBytes,
      (y + 1) * rowBytes,
    );
    for (int x = 0; x < rowBytes; x += 1) {
      final int left = x >= bytesPerPixel ? current[x - bytesPerPixel] : 0;
      final int up = previous[x];
      final int upLeft = x >= bytesPerPixel ? previous[x - bytesPerPixel] : 0;
      final int predictor = switch (rowFilter) {
        0 => 0,
        1 => left,
        2 => up,
        3 => (left + up) ~/ 2,
        4 => _paeth(left, up, upLeft),
        _ => 0,
      };
      encoded[outputOffset++] = (current[x] - predictor) & 0xff;
    }
    previous = Uint8List.fromList(current);
  }
  return encoded;
}

int _paeth(int left, int up, int upLeft) {
  final int p = left + up - upLeft;
  final int pa = (p - left).abs();
  final int pb = (p - up).abs();
  final int pc = (p - upLeft).abs();
  if (pa <= pb && pa <= pc) return left;
  if (pb <= pc) return up;
  return upLeft;
}

Uint8List _chunk(String type, Uint8List data) {
  final Uint8List typeBytes = Uint8List.fromList(ascii.encode(type));
  final Uint8List crcInput = Uint8List(typeBytes.length + data.length)
    ..setRange(0, typeBytes.length, typeBytes)
    ..setRange(typeBytes.length, typeBytes.length + data.length, data);
  final int crc = pavCrc32(crcInput);
  final Uint8List output = Uint8List(12 + data.length);
  final ByteData byteData = ByteData.sublistView(output);
  byteData.setUint32(0, data.length, Endian.big);
  output.setRange(4, 8, typeBytes);
  output.setRange(8, 8 + data.length, data);
  byteData.setUint32(8 + data.length, crc, Endian.big);
  return output;
}
