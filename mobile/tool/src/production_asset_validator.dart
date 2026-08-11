import 'dart:io';
import 'dart:typed_data';

import 'pav_models.dart';
import 'png_asset_inspector.dart';
import 'source_admission_manifest.dart';

class ProductionAssetValidator {
  const ProductionAssetValidator({
    this.pngInspector = const PavPngInspector(),
    this.manifestReader = const PavSourceAdmissionReader(),
  });

  final PavPngInspector pngInspector;
  final PavSourceAdmissionReader manifestReader;

  Future<PavValidationReport> validate({
    required String rootPath,
    required String manifestPath,
    required String mode,
    bool strictWarnings = false,
  }) async {
    final PavManifestInspection manifest = await manifestReader.inspect(manifestPath);
    final List<PavAssetResult> assets = <PavAssetResult>[];

    for (final PavAssetContract contract in pavRequiredAssets) {
      final String resolvedPath = _join(rootPath, contract.path);
      final List<PavDiagnostic> diagnostics = <PavDiagnostic>[];
      final PavManifestVariant? source = manifest.variantFor(contract.variantId);

      if (source == null) {
        diagnostics.add(
          PavDiagnostic(
            code: 'source.variant-not-admitted',
            message: '${contract.variantId} has no source-admission manifest row.',
          ),
        );
      } else {
        if (source.sourceState != 'APPROVED') {
          diagnostics.add(
            PavDiagnostic(
              code: 'source.not-approved',
              message: '${contract.variantId} source state is ${source.sourceState}; APPROVED is required before runtime admission.',
            ),
          );
        }
        if (!source.canonicalExportPresent) {
          diagnostics.add(
            PavDiagnostic(
              code: 'source.canonical-export-not-confirmed',
              message: '${contract.variantId} manifest has canonicalExportPresent=false.',
            ),
          );
        }
        if (source.canonicalPath != contract.path) {
          diagnostics.add(
            PavDiagnostic(
              code: 'source.canonical-path-mismatch',
              message: '${contract.variantId} source admission points to ${source.canonicalPath}, expected ${contract.path}.',
            ),
          );
        }
      }

      final File file = File(resolvedPath);
      PavPngInspection? png;
      if (!await file.exists()) {
        diagnostics.add(
          PavDiagnostic(
            code: 'asset.missing',
            message: '${contract.variantId} canonical production PNG is missing at ${contract.path}.',
          ),
        );
      } else {
        final Uint8List bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          diagnostics.add(
            PavDiagnostic(
              code: 'asset.empty',
              message: '${contract.variantId} canonical production PNG is empty.',
            ),
          );
        } else {
          png = pngInspector.inspect(bytes);
          diagnostics.addAll(png.diagnostics);
        }
      }

      assets.add(
        PavAssetResult(
          contract: contract,
          path: resolvedPath,
          diagnostics: diagnostics,
          png: png,
          source: source,
        ),
      );
    }

    final List<PavDiagnostic> crossDiagnostics = <PavDiagnostic>[];
    _applyDuplicateChecks(assets, crossDiagnostics);
    _applySiblingChecks(assets, crossDiagnostics);

    return PavValidationReport(
      mode: mode,
      strictWarnings: strictWarnings,
      rootPath: rootPath,
      manifest: manifest,
      assets: assets,
      crossDiagnostics: crossDiagnostics,
    );
  }

  void _applyDuplicateChecks(
    List<PavAssetResult> assets,
    List<PavDiagnostic> crossDiagnostics,
  ) {
    final Map<String, List<PavAssetResult>> byFingerprint =
        <String, List<PavAssetResult>>{};
    for (final PavAssetResult asset in assets) {
      final PavPngInspection? png = asset.png;
      if (png == null) continue;
      byFingerprint.putIfAbsent(png.fingerprint, () => <PavAssetResult>[]).add(asset);
    }

    for (final MapEntry<String, List<PavAssetResult>> entry in byFingerprint.entries) {
      if (entry.value.length < 2) continue;
      final String variants = entry.value
          .map((PavAssetResult asset) => asset.contract.variantId)
          .join(', ');
      final PavDiagnostic diagnostic = PavDiagnostic(
        code: 'cross.duplicate-canonical-binary',
        message: 'Released variants share byte-identical canonical PNG data ($variants), fingerprint ${entry.key}.',
      );
      crossDiagnostics.add(diagnostic);
      for (final PavAssetResult asset in entry.value) {
        asset.diagnostics.add(diagnostic);
      }
    }
  }

  void _applySiblingChecks(
    List<PavAssetResult> assets,
    List<PavDiagnostic> crossDiagnostics,
  ) {
    for (final String family in <String>['Drawer Organizer', 'Lunch Box']) {
      final List<PavAssetResult> siblings = assets
          .where((PavAssetResult asset) => asset.contract.family == family)
          .toList(growable: false);
      if (siblings.length < 2) continue;

      final List<PavAssetResult> measurable = siblings.where((PavAssetResult asset) {
        final PavPngInspection? png = asset.png;
        return png?.width != null &&
            png?.height != null &&
            png?.alphaMetrics?.bounds != null;
      }).toList(growable: false);
      if (measurable.length < 2) continue;

      final Set<String> canvases = measurable
          .map((PavAssetResult asset) => '${asset.png!.width}x${asset.png!.height}')
          .toSet();
      if (canvases.length > 1) {
        crossDiagnostics.add(
          PavDiagnostic(
            code: 'cross.sibling-canvas-mismatch',
            message: '$family sibling assets do not share one canonical canvas: ${canvases.join(', ')}.',
          ),
        );
      }

      final List<double> visibleRatios = measurable.map((PavAssetResult asset) {
        final PavPngInspection png = asset.png!;
        final PavBounds bounds = png.alphaMetrics!.bounds!;
        return bounds.area / ((png.width ?? 1) * (png.height ?? 1));
      }).where((double value) => value > 0).toList(growable: false);
      if (visibleRatios.length < 2) continue;
      final double minRatio = visibleRatios.reduce((double a, double b) => a < b ? a : b);
      final double maxRatio = visibleRatios.reduce((double a, double b) => a > b ? a : b);
      final double scaleRatio = minRatio == 0 ? double.infinity : maxRatio / minRatio;
      if (scaleRatio > 1.35) {
        crossDiagnostics.add(
          PavDiagnostic(
            code: 'cross.sibling-visible-scale-mismatch',
            message: '$family sibling visible-area ratio is ${scaleRatio.toStringAsFixed(3)} (> 1.35); review framing parity before visual acceptance.',
            severity: PavSeverity.warning,
          ),
        );
      }
    }
  }

  String _join(String root, String relative) {
    final String normalized = relative.replaceAll('/', Platform.pathSeparator);
    if (root.isEmpty || root == '.') return normalized;
    if (root.endsWith(Platform.pathSeparator)) return '$root$normalized';
    return '$root${Platform.pathSeparator}$normalized';
  }
}
