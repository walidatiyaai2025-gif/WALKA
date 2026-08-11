import 'dart:typed_data';

const int pavHardFileBudgetBytes = 1258291; // 1.2 MiB review ceiling.
const int pavCanonicalWidth = 1024;
const int pavCanonicalHeight = 1024;
const int pavCanonicalBitDepth = 8;
const int pavCanonicalColorType = 6;

const List<int> pavPngSignature = <int>[
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
];

enum PavSeverity { blocker, warning }

class PavDiagnostic {
  const PavDiagnostic({
    required this.code,
    required this.message,
    this.severity = PavSeverity.blocker,
  });

  final String code;
  final String message;
  final PavSeverity severity;

  bool get isBlocker => severity == PavSeverity.blocker;
  bool get isWarning => severity == PavSeverity.warning;

  Map<String, Object?> toJson() => <String, Object?>{
        'code': code,
        'message': message,
        'severity': severity.name,
      };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PavDiagnostic &&
            other.code == code &&
            other.message == message &&
            other.severity == severity;
  }

  @override
  int get hashCode => Object.hash(code, message, severity);
}

class PavAssetContract {
  const PavAssetContract({
    required this.variantId,
    required this.legacyId,
    required this.family,
    required this.variant,
    required this.path,
  });

  final String variantId;
  final String legacyId;
  final String family;
  final String variant;
  final String path;

  Map<String, Object?> toJson() => <String, Object?>{
        'variantId': variantId,
        'legacyId': legacyId,
        'family': family,
        'variant': variant,
        'path': path,
      };
}

const List<PavAssetContract> pavRequiredAssets = <PavAssetContract>[
  PavAssetContract(
    variantId: 'drawer-organizer:white',
    legacyId: 'drawer-white',
    family: 'Drawer Organizer',
    variant: 'White',
    path: 'assets/products/drawer/white.png',
  ),
  PavAssetContract(
    variantId: 'drawer-organizer:gray',
    legacyId: 'drawer-gray',
    family: 'Drawer Organizer',
    variant: 'Gray',
    path: 'assets/products/drawer/gray.png',
  ),
  PavAssetContract(
    variantId: 'lunch-box:blue',
    legacyId: 'lunch-blue',
    family: 'Lunch Box',
    variant: 'Blue',
    path: 'assets/products/lunch/blue.png',
  ),
  PavAssetContract(
    variantId: 'lunch-box:pink',
    legacyId: 'lunch-pink',
    family: 'Lunch Box',
    variant: 'Pink',
    path: 'assets/products/lunch/pink.png',
  ),
  PavAssetContract(
    variantId: 'lunch-box:green',
    legacyId: 'lunch-green',
    family: 'Lunch Box',
    variant: 'Green',
    path: 'assets/products/lunch/green.png',
  ),
];

class PavPngChunk {
  const PavPngChunk({
    required this.type,
    required this.length,
    required this.offset,
    required this.storedCrc,
    required this.computedCrc,
    required this.data,
  });

  final String type;
  final int length;
  final int offset;
  final int storedCrc;
  final int computedCrc;
  final Uint8List data;

  bool get crcValid => storedCrc == computedCrc;

  bool get critical {
    if (type.isEmpty) return false;
    return (type.codeUnitAt(0) & 0x20) == 0;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        'length': length,
        'offset': offset,
        'crcValid': crcValid,
      };
}

class PavBounds {
  const PavBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final int left;
  final int top;
  final int right;
  final int bottom;

  int get width => right - left + 1;
  int get height => bottom - top + 1;
  int get area => width * height;

  Map<String, Object?> toJson() => <String, Object?>{
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
        'width': width,
        'height': height,
      };
}

class PavSafeMargins {
  const PavSafeMargins({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.minimumHorizontal,
    required this.minimumVertical,
  });

  final int left;
  final int top;
  final int right;
  final int bottom;
  final int minimumHorizontal;
  final int minimumVertical;

  int get nearest => <int>[left, top, right, bottom].reduce(
        (int a, int b) => a < b ? a : b,
      );

  bool get passes =>
      left >= minimumHorizontal &&
      right >= minimumHorizontal &&
      top >= minimumVertical &&
      bottom >= minimumVertical;

  Map<String, Object?> toJson() => <String, Object?>{
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
        'nearest': nearest,
        'minimumHorizontal': minimumHorizontal,
        'minimumVertical': minimumVertical,
        'passes': passes,
      };
}

class PavAlphaMetrics {
  const PavAlphaMetrics({
    required this.hasTransparentPixels,
    required this.perimeterTransparent,
    required this.visiblePixelCount,
    required this.alphaCoverageRatio,
    required this.opticalCenterOffsetX,
    required this.opticalCenterOffsetY,
    this.bounds,
    this.safeMargins,
  });

  final bool hasTransparentPixels;
  final bool perimeterTransparent;
  final int visiblePixelCount;
  final double alphaCoverageRatio;
  final double opticalCenterOffsetX;
  final double opticalCenterOffsetY;
  final PavBounds? bounds;
  final PavSafeMargins? safeMargins;

  Map<String, Object?> toJson() => <String, Object?>{
        'hasTransparentPixels': hasTransparentPixels,
        'perimeterTransparent': perimeterTransparent,
        'visiblePixelCount': visiblePixelCount,
        'alphaCoverageRatio': alphaCoverageRatio,
        'opticalCenterOffsetX': opticalCenterOffsetX,
        'opticalCenterOffsetY': opticalCenterOffsetY,
        if (bounds != null) 'visibleBounds': bounds!.toJson(),
        if (safeMargins != null) 'safeMargins': safeMargins!.toJson(),
      };
}

class PavPngInspection {
  const PavPngInspection({
    required this.bytes,
    required this.fingerprint,
    required this.chunks,
    required this.diagnostics,
    this.width,
    this.height,
    this.bitDepth,
    this.colorType,
    this.compressionMethod,
    this.filterMethod,
    this.interlaceMethod,
    this.hasColorProfile = false,
    this.rgba,
    this.alphaMetrics,
  });

  final int bytes;
  final String fingerprint;
  final List<PavPngChunk> chunks;
  final List<PavDiagnostic> diagnostics;
  final int? width;
  final int? height;
  final int? bitDepth;
  final int? colorType;
  final int? compressionMethod;
  final int? filterMethod;
  final int? interlaceMethod;
  final bool hasColorProfile;
  final Uint8List? rgba;
  final PavAlphaMetrics? alphaMetrics;

  bool get hasBlockers => diagnostics.any((PavDiagnostic item) => item.isBlocker);
  int get blockerCount => diagnostics.where((PavDiagnostic item) => item.isBlocker).length;
  int get warningCount => diagnostics.where((PavDiagnostic item) => item.isWarning).length;

  Map<String, Object?> toJson() => <String, Object?>{
        'bytes': bytes,
        'fingerprint': fingerprint,
        'chunks': chunks.map((PavPngChunk chunk) => chunk.toJson()).toList(),
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (bitDepth != null) 'bitDepth': bitDepth,
        if (colorType != null) 'colorType': colorType,
        if (compressionMethod != null) 'compressionMethod': compressionMethod,
        if (filterMethod != null) 'filterMethod': filterMethod,
        if (interlaceMethod != null) 'interlaceMethod': interlaceMethod,
        'hasColorProfile': hasColorProfile,
        if (alphaMetrics != null) 'alpha': alphaMetrics!.toJson(),
        'blockerCount': blockerCount,
        'warningCount': warningCount,
      };
}

class PavManifestVariant {
  const PavManifestVariant({
    required this.variantId,
    required this.family,
    required this.variant,
    required this.sourceId,
    required this.sourceFilename,
    required this.sourceState,
    required this.canonicalPath,
    required this.canonicalExportPresent,
  });

  final String variantId;
  final String family;
  final String variant;
  final String sourceId;
  final String sourceFilename;
  final String sourceState;
  final String canonicalPath;
  final bool canonicalExportPresent;

  Map<String, Object?> toJson() => <String, Object?>{
        'variantId': variantId,
        'family': family,
        'variant': variant,
        'sourceId': sourceId,
        'sourceFilename': sourceFilename,
        'sourceState': sourceState,
        'canonicalPath': canonicalPath,
        'canonicalExportPresent': canonicalExportPresent,
      };
}

class PavManifestInspection {
  const PavManifestInspection({
    required this.path,
    required this.schemaVersion,
    required this.allowedSourceStates,
    required this.protectedRuntimeSourcePrefixes,
    required this.variants,
    required this.diagnostics,
  });

  final String path;
  final int? schemaVersion;
  final List<String> allowedSourceStates;
  final List<String> protectedRuntimeSourcePrefixes;
  final List<PavManifestVariant> variants;
  final List<PavDiagnostic> diagnostics;

  bool get hasBlockers => diagnostics.any((PavDiagnostic item) => item.isBlocker);

  PavManifestVariant? variantFor(String variantId) {
    for (final PavManifestVariant item in variants) {
      if (item.variantId == variantId) return item;
    }
    return null;
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        if (schemaVersion != null) 'schemaVersion': schemaVersion,
        'allowedSourceStates': allowedSourceStates,
        'protectedRuntimeSourcePrefixes': protectedRuntimeSourcePrefixes,
        'variants': variants.map((PavManifestVariant item) => item.toJson()).toList(),
        'diagnostics': diagnostics.map((PavDiagnostic item) => item.toJson()).toList(),
      };
}

class PavAssetResult {
  PavAssetResult({
    required this.contract,
    required this.path,
    required this.diagnostics,
    this.png,
    this.source,
  });

  final PavAssetContract contract;
  final String path;
  final List<PavDiagnostic> diagnostics;
  final PavPngInspection? png;
  final PavManifestVariant? source;

  bool get ready => !diagnostics.any((PavDiagnostic item) => item.isBlocker);
  int get blockerCount => diagnostics.where((PavDiagnostic item) => item.isBlocker).length;
  int get warningCount => diagnostics.where((PavDiagnostic item) => item.isWarning).length;

  String get summary {
    final String state = ready ? 'READY' : 'BLOCKED';
    final String detail = png == null || png!.width == null
        ? ''
        : ' ${png!.width}x${png!.height} ${png!.bytes}B';
    final String issueText = diagnostics.isEmpty
        ? ''
        : ' [${diagnostics.map((PavDiagnostic item) => item.code).join(',')}]';
    return '- ${contract.legacyId}: $state$detail$issueText — ${contract.path}';
  }

  Map<String, Object?> toJson() => <String, Object?>{
        ...contract.toJson(),
        'resolvedPath': path,
        'ready': ready,
        'issues': diagnostics.map((PavDiagnostic item) => item.code).toList(),
        'diagnostics': diagnostics.map((PavDiagnostic item) => item.toJson()).toList(),
        'blockerCount': blockerCount,
        'warningCount': warningCount,
        if (png != null) ...png!.toJson(),
        if (source != null) 'sourceAdmission': source!.toJson(),
      };
}

class PavValidationReport {
  const PavValidationReport({
    required this.mode,
    required this.strictWarnings,
    required this.rootPath,
    required this.manifest,
    required this.assets,
    required this.crossDiagnostics,
  });

  final String mode;
  final bool strictWarnings;
  final String rootPath;
  final PavManifestInspection manifest;
  final List<PavAssetResult> assets;
  final List<PavDiagnostic> crossDiagnostics;

  int get requiredCount => pavRequiredAssets.length;
  int get readyCount => assets.where((PavAssetResult item) => item.ready).length;
  int get blockerCount =>
      manifest.diagnostics.where((PavDiagnostic item) => item.isBlocker).length +
      assets.fold<int>(0, (int count, PavAssetResult item) => count + item.blockerCount) +
      crossDiagnostics.where((PavDiagnostic item) => item.isBlocker).length;
  int get warningCount =>
      manifest.diagnostics.where((PavDiagnostic item) => item.isWarning).length +
      assets.fold<int>(0, (int count, PavAssetResult item) => count + item.warningCount) +
      crossDiagnostics.where((PavDiagnostic item) => item.isWarning).length;

  bool get ready =>
      blockerCount == 0 &&
      readyCount == requiredCount &&
      (!strictWarnings || warningCount == 0);

  String get state => ready ? 'READY' : 'BLOCKED';

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': 2,
        'mode': mode,
        'state': state,
        'ready': ready,
        'strictWarnings': strictWarnings,
        'rootPath': rootPath,
        'manifestPath': manifest.path,
        'requiredCount': requiredCount,
        'readyCount': readyCount,
        'blockerCount': blockerCount,
        'warningCount': warningCount,
        'hardFileBudgetBytes': pavHardFileBudgetBytes,
        'manifest': manifest.toJson(),
        'assets': assets.map((PavAssetResult item) => item.toJson()).toList(),
        'crossDiagnostics':
            crossDiagnostics.map((PavDiagnostic item) => item.toJson()).toList(),
      };
}
