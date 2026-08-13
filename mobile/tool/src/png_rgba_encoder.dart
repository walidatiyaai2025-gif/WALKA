import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'png_asset_inspector.dart' show pavCrc32;

/// Minimal deterministic PNG encoder for 8-bit RGBA review candidates.
///
/// It deliberately emits only IHDR, sRGB, IDAT and IEND, uses filter 0 for
/// every scanline and never changes caller-provided pixel bytes.
abstract final class PavRgbaPngEncoder {
  static Uint8List encode({
    required int width,
    required int height,
    required Uint8List rgba,
  }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('PNG width and height must be positive.');
    }
    if (rgba.length != width * height * 4) {
      throw ArgumentError('RGBA buffer length must equal width*height*4.');
    }

    final BytesBuilder out = BytesBuilder(copy: false)
      ..add(const <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

    final ByteData ihdr = ByteData(13)
      ..setUint32(0, width, Endian.big)
      ..setUint32(4, height, Endian.big)
      ..setUint8(8, 8)
      ..setUint8(9, 6)
      ..setUint8(10, 0)
      ..setUint8(11, 0)
      ..setUint8(12, 0);
    _writeChunk(out, 'IHDR', ihdr.buffer.asUint8List());

    // Rendering intent 0 = perceptual. Presence of this chunk satisfies the
    // repository's canonical sRGB/iCCP profile requirement.
    _writeChunk(out, 'sRGB', Uint8List.fromList(const <int>[0]));

    final int rowBytes = width * 4;
    final Uint8List scanlines = Uint8List(height * (rowBytes + 1));
    int src = 0;
    int dst = 0;
    for (int y = 0; y < height; y += 1) {
      scanlines[dst++] = 0; // PNG filter type 0.
      scanlines.setRange(dst, dst + rowBytes, rgba, src);
      src += rowBytes;
      dst += rowBytes;
    }
    final Uint8List compressed = Uint8List.fromList(
      ZLibEncoder(level: 9).convert(scanlines),
    );
    _writeChunk(out, 'IDAT', compressed);
    _writeChunk(out, 'IEND', Uint8List(0));
    return out.takeBytes();
  }

  static void _writeChunk(BytesBuilder out, String type, Uint8List data) {
    final Uint8List typeBytes = Uint8List.fromList(ascii.encode(type));
    if (typeBytes.length != 4) {
      throw ArgumentError('PNG chunk type must contain exactly four bytes.');
    }

    final ByteData length = ByteData(4)..setUint32(0, data.length, Endian.big);
    final Uint8List crcInput = Uint8List(typeBytes.length + data.length)
      ..setRange(0, typeBytes.length, typeBytes)
      ..setRange(typeBytes.length, typeBytes.length + data.length, data);
    final ByteData crc = ByteData(4)
      ..setUint32(0, pavCrc32(crcInput), Endian.big);

    out
      ..add(length.buffer.asUint8List())
      ..add(typeBytes)
      ..add(data)
      ..add(crc.buffer.asUint8List());
  }
}
