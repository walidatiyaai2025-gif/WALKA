import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'pav_models.dart';

class PavPngInspector {
  const PavPngInspector();

  PavPngInspection inspect(Uint8List bytes) {
    final List<PavDiagnostic> diagnostics = <PavDiagnostic>[];
    final String fingerprint = pavFingerprint(bytes);
    if (bytes.length > pavHardFileBudgetBytes) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.file-budget-exceeded',
          message: 'Runtime product PNG exceeds the 1.2 MiB production budget.',
        ),
      );
    }

    if (!_hasSignature(bytes)) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.invalid-signature',
          message: 'File does not begin with the canonical PNG signature.',
        ),
      );
      return PavPngInspection(
        bytes: bytes.length,
        fingerprint: fingerprint,
        chunks: const <PavPngChunk>[],
        diagnostics: diagnostics,
      );
    }

    final _ChunkParseResult parsed = _parseChunks(bytes);
    diagnostics.addAll(parsed.diagnostics);
    final List<PavPngChunk> chunks = parsed.chunks;

    final List<PavPngChunk> ihdrChunks =
        chunks.where((PavPngChunk chunk) => chunk.type == 'IHDR').toList();
    final List<PavPngChunk> idatChunks =
        chunks.where((PavPngChunk chunk) => chunk.type == 'IDAT').toList();
    final List<PavPngChunk> iendChunks =
        chunks.where((PavPngChunk chunk) => chunk.type == 'IEND').toList();

    if (chunks.isEmpty || chunks.first.type != 'IHDR') {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.ihdr-not-first',
          message: 'IHDR must be the first PNG chunk.',
        ),
      );
    }
    if (ihdrChunks.isEmpty) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.ihdr-missing',
          message: 'PNG is missing its IHDR chunk.',
        ),
      );
    } else if (ihdrChunks.length > 1) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.ihdr-duplicate',
          message: 'PNG contains more than one IHDR chunk.',
        ),
      );
    }
    if (idatChunks.isEmpty) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.idat-missing',
          message: 'PNG contains no IDAT image payload.',
        ),
      );
    }
    if (iendChunks.isEmpty) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.iend-missing',
          message: 'PNG is missing its IEND chunk.',
        ),
      );
    } else if (iendChunks.length > 1) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.iend-duplicate',
          message: 'PNG contains more than one IEND chunk.',
        ),
      );
    }
    if (chunks.isNotEmpty && chunks.last.type != 'IEND') {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.iend-not-final',
          message: 'IEND must be the final PNG chunk.',
        ),
      );
    }

    for (final PavPngChunk chunk in chunks) {
      if (!chunk.crcValid) {
        diagnostics.add(
          PavDiagnostic(
            code: 'png.crc-mismatch',
            message: 'CRC mismatch in ${chunk.type} chunk at byte ${chunk.offset}.',
          ),
        );
      }
      if (_animationChunks.contains(chunk.type)) {
        diagnostics.add(
          PavDiagnostic(
            code: 'png.animation-not-allowed',
            message: 'Animated PNG chunk ${chunk.type} is not allowed.',
          ),
        );
      }
      if (_textChunks.contains(chunk.type)) {
        diagnostics.add(
          PavDiagnostic(
            code: 'png.text-metadata-not-allowed',
            message: 'Text metadata chunk ${chunk.type} is not allowed in runtime product assets.',
          ),
        );
      }
      if (chunk.critical && !_knownCriticalChunks.contains(chunk.type)) {
        diagnostics.add(
          PavDiagnostic(
            code: 'png.unknown-critical-chunk',
            message: 'Unsupported critical PNG chunk ${chunk.type}.',
          ),
        );
      }
    }

    int? width;
    int? height;
    int? bitDepth;
    int? colorType;
    int? compressionMethod;
    int? filterMethod;
    int? interlaceMethod;

    if (ihdrChunks.isNotEmpty) {
      final PavPngChunk ihdr = ihdrChunks.first;
      if (ihdr.length != 13 || ihdr.data.length != 13) {
        diagnostics.add(
          const PavDiagnostic(
            code: 'png.ihdr-invalid-length',
            message: 'IHDR must contain exactly 13 bytes.',
          ),
        );
      } else {
        final ByteData data = ByteData.sublistView(ihdr.data);
        width = data.getUint32(0, Endian.big);
        height = data.getUint32(4, Endian.big);
        bitDepth = ihdr.data[8];
        colorType = ihdr.data[9];
        compressionMethod = ihdr.data[10];
        filterMethod = ihdr.data[11];
        interlaceMethod = ihdr.data[12];

        if (width != pavCanonicalWidth || height != pavCanonicalHeight) {
          diagnostics.add(
            PavDiagnostic(
              code: 'png.canvas-not-canonical',
              message: 'Canonical runtime canvas must be ${pavCanonicalWidth}x$pavCanonicalHeight; found ${width}x$height.',
            ),
          );
        }
        if (bitDepth != pavCanonicalBitDepth) {
          diagnostics.add(
            PavDiagnostic(
              code: 'png.bit-depth-not-8',
              message: 'Canonical runtime PNG must be 8-bit; found $bitDepth.',
            ),
          );
        }
        if (colorType != pavCanonicalColorType) {
          diagnostics.add(
            PavDiagnostic(
              code: 'png.color-type-not-rgba',
              message: 'Canonical runtime PNG must use RGBA color type 6; found $colorType.',
            ),
          );
        }
        if (compressionMethod != 0) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.compression-method-invalid',
              message: 'PNG compression method must be 0.',
            ),
          );
        }
        if (filterMethod != 0) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.filter-method-invalid',
              message: 'PNG filter method must be 0.',
            ),
          );
        }
        if (interlaceMethod != 0) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.interlace-not-allowed',
              message: 'Canonical runtime PNG must be non-interlaced.',
            ),
          );
        }
      }
    }

    final bool hasColorProfile = chunks.any(
      (PavPngChunk chunk) => chunk.type == 'sRGB' || chunk.type == 'iCCP',
    );
    if (!hasColorProfile) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.color-profile-missing',
          message: 'Canonical runtime PNG must carry sRGB or iCCP color-profile metadata.',
        ),
      );
    }

    Uint8List? rgba;
    PavAlphaMetrics? alphaMetrics;
    final bool formatDecodable =
        width != null &&
        height != null &&
        width > 0 &&
        height > 0 &&
        width <= 8192 &&
        height <= 8192 &&
        bitDepth == 8 &&
        colorType == 6 &&
        compressionMethod == 0 &&
        filterMethod == 0 &&
        interlaceMethod == 0 &&
        idatChunks.isNotEmpty;

    if (formatDecodable) {
      final _DecodeResult decoded = _decodeRgba(
        width: width!,
        height: height!,
        idatChunks: idatChunks,
      );
      diagnostics.addAll(decoded.diagnostics);
      rgba = decoded.rgba;
      if (rgba != null) {
        alphaMetrics = _measureAlpha(width, height, rgba);
        if (!alphaMetrics.hasTransparentPixels) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.alpha-transparency-missing',
              message: 'Product cutout contains no transparent pixels.',
            ),
          );
        }
        if (!alphaMetrics.perimeterTransparent) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.perimeter-not-transparent',
              message: 'Outer canvas perimeter must be fully transparent.',
            ),
          );
        }
        if (alphaMetrics.visiblePixelCount == 0 || alphaMetrics.bounds == null) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.visible-content-missing',
              message: 'Product cutout contains no visible pixels.',
            ),
          );
        } else if (alphaMetrics.safeMargins != null && !alphaMetrics.safeMargins!.passes) {
          diagnostics.add(
            PavDiagnostic(
              code: 'png.safe-margin-too-small',
              message: 'Visible content must keep at least floor(5%) transparent safe margin; nearest edge is ${alphaMetrics.safeMargins!.nearest}px.',
            ),
          );
        }
        if (alphaMetrics.alphaCoverageRatio < 0.03) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.coverage-unusually-low',
              message: 'Visible alpha coverage is unusually low for a primary product cutout.',
              severity: PavSeverity.warning,
            ),
          );
        }
        if (alphaMetrics.alphaCoverageRatio > 0.88) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.coverage-unusually-high',
              message: 'Visible alpha coverage is unusually high for a reusable product cutout.',
              severity: PavSeverity.warning,
            ),
          );
        }
        if (alphaMetrics.opticalCenterOffsetX.abs() > 0.16 ||
            alphaMetrics.opticalCenterOffsetY.abs() > 0.16) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.optical-center-offset-high',
              message: 'Visible content is strongly offset from the canvas optical center.',
              severity: PavSeverity.warning,
            ),
          );
        }
      }
    }

    return PavPngInspection(
      bytes: bytes.length,
      fingerprint: fingerprint,
      chunks: chunks,
      diagnostics: diagnostics,
      width: width,
      height: height,
      bitDepth: bitDepth,
      colorType: colorType,
      compressionMethod: compressionMethod,
      filterMethod: filterMethod,
      interlaceMethod: interlaceMethod,
      hasColorProfile: hasColorProfile,
      rgba: rgba,
      alphaMetrics: alphaMetrics,
    );
  }

  bool _hasSignature(Uint8List bytes) {
    if (bytes.length < pavPngSignature.length) return false;
    for (int index = 0; index < pavPngSignature.length; index += 1) {
      if (bytes[index] != pavPngSignature[index]) return false;
    }
    return true;
  }

  _ChunkParseResult _parseChunks(Uint8List bytes) {
    final List<PavPngChunk> chunks = <PavPngChunk>[];
    final List<PavDiagnostic> diagnostics = <PavDiagnostic>[];
    int offset = pavPngSignature.length;
    bool sawIend = false;

    while (offset < bytes.length) {
      if (bytes.length - offset < 12) {
        diagnostics.add(
          const PavDiagnostic(
            code: 'png.chunk-truncated',
            message: 'PNG ended before a complete chunk header/data/CRC could be read.',
          ),
        );
        break;
      }
      final ByteData header = ByteData.sublistView(bytes, offset, offset + 8);
      final int length = header.getUint32(0, Endian.big);
      final int dataStart = offset + 8;
      final int dataEnd = dataStart + length;
      final int crcEnd = dataEnd + 4;
      if (dataEnd < dataStart || crcEnd < dataEnd || crcEnd > bytes.length) {
        diagnostics.add(
          const PavDiagnostic(
            code: 'png.chunk-length-out-of-bounds',
            message: 'PNG chunk length extends beyond the file boundary.',
          ),
        );
        break;
      }

      final Uint8List typeBytes = Uint8List.sublistView(bytes, offset + 4, offset + 8);
      final bool typeValid = typeBytes.every(
        (int value) =>
            (value >= 65 && value <= 90) || (value >= 97 && value <= 122),
      );
      final String type = ascii.decode(typeBytes, allowInvalid: true);
      if (!typeValid) {
        diagnostics.add(
          const PavDiagnostic(
            code: 'png.chunk-type-invalid',
            message: 'PNG chunk type must contain four ASCII letters.',
          ),
        );
      }

      final Uint8List data = Uint8List.sublistView(bytes, dataStart, dataEnd);
      final int storedCrc = ByteData.sublistView(bytes, dataEnd, crcEnd).getUint32(0, Endian.big);
      final Uint8List crcInput = Uint8List(typeBytes.length + data.length)
        ..setRange(0, typeBytes.length, typeBytes)
        ..setRange(typeBytes.length, typeBytes.length + data.length, data);
      final int computedCrc = pavCrc32(crcInput);
      chunks.add(
        PavPngChunk(
          type: type,
          length: length,
          offset: offset,
          storedCrc: storedCrc,
          computedCrc: computedCrc,
          data: Uint8List.fromList(data),
        ),
      );

      offset = crcEnd;
      if (type == 'IEND') {
        sawIend = true;
        if (length != 0) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.iend-invalid-length',
              message: 'IEND chunk length must be zero.',
            ),
          );
        }
        if (offset != bytes.length) {
          diagnostics.add(
            const PavDiagnostic(
              code: 'png.trailing-bytes-after-iend',
              message: 'Bytes are present after the final IEND chunk.',
            ),
          );
        }
        break;
      }
    }

    if (!sawIend && offset == bytes.length) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'png.iend-missing',
          message: 'PNG ended without an IEND chunk.',
        ),
      );
    }

    return _ChunkParseResult(chunks: chunks, diagnostics: diagnostics);
  }

  _DecodeResult _decodeRgba({
    required int width,
    required int height,
    required List<PavPngChunk> idatChunks,
  }) {
    final List<PavDiagnostic> diagnostics = <PavDiagnostic>[];
    final BytesBuilder compressedBuilder = BytesBuilder(copy: false);
    for (final PavPngChunk chunk in idatChunks) {
      compressedBuilder.add(chunk.data);
    }

    late final Uint8List inflated;
    try {
      inflated = Uint8List.fromList(
        const ZLibDecoder().convert(compressedBuilder.takeBytes()),
      );
    } on Object catch (error) {
      diagnostics.add(
        PavDiagnostic(
          code: 'png.idat-zlib-invalid',
          message: 'Unable to inflate PNG IDAT payload: $error',
        ),
      );
      return _DecodeResult(rgba: null, diagnostics: diagnostics);
    }

    const int bytesPerPixel = 4;
    final int rowBytes = width * bytesPerPixel;
    final int expectedBytes = height * (rowBytes + 1);
    if (inflated.length != expectedBytes) {
      diagnostics.add(
        PavDiagnostic(
          code: 'png.scanline-length-invalid',
          message: 'Expected $expectedBytes decompressed scanline bytes, found ${inflated.length}.',
        ),
      );
      return _DecodeResult(rgba: null, diagnostics: diagnostics);
    }

    final Uint8List rgba = Uint8List(width * height * bytesPerPixel);
    Uint8List previous = Uint8List(rowBytes);
    int inputOffset = 0;
    for (int y = 0; y < height; y += 1) {
      final int filter = inflated[inputOffset++];
      final Uint8List raw = Uint8List.sublistView(
        inflated,
        inputOffset,
        inputOffset + rowBytes,
      );
      inputOffset += rowBytes;
      final Uint8List reconstructed = Uint8List(rowBytes);
      if (filter < 0 || filter > 4) {
        diagnostics.add(
          PavDiagnostic(
            code: 'png.scanline-filter-unsupported',
            message: 'Unsupported PNG scanline filter $filter at row $y.',
          ),
        );
        return _DecodeResult(rgba: null, diagnostics: diagnostics);
      }
      for (int x = 0; x < rowBytes; x += 1) {
        final int left = x >= bytesPerPixel ? reconstructed[x - bytesPerPixel] : 0;
        final int up = previous[x];
        final int upLeft = x >= bytesPerPixel ? previous[x - bytesPerPixel] : 0;
        final int predictor = switch (filter) {
          0 => 0,
          1 => left,
          2 => up,
          3 => (left + up) ~/ 2,
          4 => _paeth(left, up, upLeft),
          _ => 0,
        };
        reconstructed[x] = (raw[x] + predictor) & 0xff;
      }
      rgba.setRange(y * rowBytes, (y + 1) * rowBytes, reconstructed);
      previous = reconstructed;
    }
    return _DecodeResult(rgba: rgba, diagnostics: diagnostics);
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

  PavAlphaMetrics _measureAlpha(int width, int height, Uint8List rgba) {
    bool hasTransparent = false;
    bool perimeterTransparent = true;
    int visible = 0;
    int minX = width;
    int minY = height;
    int maxX = -1;
    int maxY = -1;
    double weightedX = 0;
    double weightedY = 0;
    double alphaWeight = 0;

    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        final int alpha = rgba[(y * width + x) * 4 + 3];
        if (alpha < 255) hasTransparent = true;
        if ((x == 0 || y == 0 || x == width - 1 || y == height - 1) && alpha != 0) {
          perimeterTransparent = false;
        }
        if (alpha > 0) {
          visible += 1;
          minX = math.min(minX, x);
          minY = math.min(minY, y);
          maxX = math.max(maxX, x);
          maxY = math.max(maxY, y);
          final double weight = alpha / 255.0;
          alphaWeight += weight;
          weightedX += x * weight;
          weightedY += y * weight;
        }
      }
    }

    PavBounds? bounds;
    PavSafeMargins? margins;
    if (visible > 0) {
      bounds = PavBounds(left: minX, top: minY, right: maxX, bottom: maxY);
      margins = PavSafeMargins(
        left: minX,
        top: minY,
        right: width - 1 - maxX,
        bottom: height - 1 - maxY,
        minimumHorizontal: width ~/ 20,
        minimumVertical: height ~/ 20,
      );
    }

    final double centerX = alphaWeight == 0 ? (width - 1) / 2 : weightedX / alphaWeight;
    final double centerY = alphaWeight == 0 ? (height - 1) / 2 : weightedY / alphaWeight;
    return PavAlphaMetrics(
      hasTransparentPixels: hasTransparent,
      perimeterTransparent: perimeterTransparent,
      visiblePixelCount: visible,
      alphaCoverageRatio: visible / (width * height),
      opticalCenterOffsetX: (centerX - (width - 1) / 2) / width,
      opticalCenterOffsetY: (centerY - (height - 1) / 2) / height,
      bounds: bounds,
      safeMargins: margins,
    );
  }
}

const Set<String> _knownCriticalChunks = <String>{'IHDR', 'PLTE', 'IDAT', 'IEND'};
const Set<String> _animationChunks = <String>{'acTL', 'fcTL', 'fdAT'};
const Set<String> _textChunks = <String>{'tEXt', 'zTXt', 'iTXt'};

class _ChunkParseResult {
  const _ChunkParseResult({required this.chunks, required this.diagnostics});

  final List<PavPngChunk> chunks;
  final List<PavDiagnostic> diagnostics;
}

class _DecodeResult {
  const _DecodeResult({required this.rgba, required this.diagnostics});

  final Uint8List? rgba;
  final List<PavDiagnostic> diagnostics;
}

int pavCrc32(List<int> bytes) {
  int crc = 0xffffffff;
  for (final int byte in bytes) {
    crc ^= byte;
    for (int bit = 0; bit < 8; bit += 1) {
      final int mask = -(crc & 1);
      crc = (crc >> 1) ^ (0xedb88320 & mask);
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}

String pavFingerprint(List<int> bytes) {
  const int offsetBasis = 0xcbf29ce484222325;
  const int prime = 0x100000001b3;
  const int mask = 0xffffffffffffffff;
  int hash = offsetBasis;
  for (final int byte in bytes) {
    hash ^= byte;
    hash = (hash * prime) & mask;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
