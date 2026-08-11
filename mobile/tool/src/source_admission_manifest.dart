import 'dart:convert';
import 'dart:io';

import 'pav_models.dart';

class PavSourceAdmissionReader {
  const PavSourceAdmissionReader();

  Future<PavManifestInspection> inspect(String path) async {
    final List<PavDiagnostic> diagnostics = <PavDiagnostic>[];
    final File file = File(path);
    if (!await file.exists()) {
      diagnostics.add(
        PavDiagnostic(
          code: 'manifest.missing',
          message: 'Production source admission manifest not found at $path.',
        ),
      );
      return PavManifestInspection(
        path: path,
        schemaVersion: null,
        allowedSourceStates: const <String>[],
        protectedRuntimeSourcePrefixes: const <String>[],
        variants: const <PavManifestVariant>[],
        diagnostics: diagnostics,
      );
    }

    Object? decoded;
    try {
      decoded = jsonDecode(await file.readAsString());
    } on Object catch (error) {
      diagnostics.add(
        PavDiagnostic(
          code: 'manifest.invalid-json',
          message: 'Unable to parse production source admission JSON: $error',
        ),
      );
    }
    if (decoded is! Map<String, dynamic>) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'manifest.root-not-object',
          message: 'Production source admission manifest root must be a JSON object.',
        ),
      );
      return PavManifestInspection(
        path: path,
        schemaVersion: null,
        allowedSourceStates: const <String>[],
        protectedRuntimeSourcePrefixes: const <String>[],
        variants: const <PavManifestVariant>[],
        diagnostics: diagnostics,
      );
    }

    final int? schemaVersion = decoded['schemaVersion'] is int
        ? decoded['schemaVersion'] as int
        : null;
    if (schemaVersion != 1) {
      diagnostics.add(
        PavDiagnostic(
          code: 'manifest.schema-version-invalid',
          message: 'Production source admission schemaVersion must be 1; found $schemaVersion.',
        ),
      );
    }

    final List<String> allowedStates = _stringList(decoded['allowedSourceStates']);
    const Set<String> expectedStates = <String>{'APPROVED', 'BLOCKED', 'REPLACE'};
    if (!allowedStates.toSet().containsAll(expectedStates)) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'manifest.allowed-states-incomplete',
          message: 'allowedSourceStates must include APPROVED, BLOCKED and REPLACE.',
        ),
      );
    }

    final List<String> protectedPrefixes =
        _stringList(decoded['protectedRuntimeSourcePrefixes']);
    if (!protectedPrefixes.contains('Images/')) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'manifest.protected-prefix-missing',
          message: 'Protected runtime source prefixes must include Images/.',
        ),
      );
    }

    final List<PavManifestVariant> variants = <PavManifestVariant>[];
    final Object? rawVariants = decoded['variants'];
    if (rawVariants is! List<dynamic>) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'manifest.variants-not-array',
          message: 'Manifest variants must be an array.',
        ),
      );
    } else {
      for (int index = 0; index < rawVariants.length; index += 1) {
        final Object? row = rawVariants[index];
        if (row is! Map<String, dynamic>) {
          diagnostics.add(
            PavDiagnostic(
              code: 'manifest.variant-row-invalid',
              message: 'Manifest variant row $index must be an object.',
            ),
          );
          continue;
        }
        final String? variantId = _string(row['variantId']);
        final String? family = _string(row['family']);
        final String? variant = _string(row['variant']);
        final String? sourceId = _string(row['sourceId']);
        final String? sourceFilename = _string(row['sourceFilename']);
        final String? sourceState = _string(row['sourceState']);
        final String? canonicalPath = _string(row['canonicalPath']);
        final bool? exportPresent = row['canonicalExportPresent'] is bool
            ? row['canonicalExportPresent'] as bool
            : null;

        if (<Object?>[
          variantId,
          family,
          variant,
          sourceId,
          sourceFilename,
          sourceState,
          canonicalPath,
          exportPresent,
        ].any((Object? value) => value == null)) {
          diagnostics.add(
            PavDiagnostic(
              code: 'manifest.variant-fields-missing',
              message: 'Manifest variant row $index is missing required typed fields.',
            ),
          );
          continue;
        }
        variants.add(
          PavManifestVariant(
            variantId: variantId!,
            family: family!,
            variant: variant!,
            sourceId: sourceId!,
            sourceFilename: sourceFilename!,
            sourceState: sourceState!,
            canonicalPath: canonicalPath!,
            canonicalExportPresent: exportPresent!,
          ),
        );
      }
    }

    _validateRows(
      variants: variants,
      allowedStates: allowedStates,
      protectedPrefixes: protectedPrefixes,
      diagnostics: diagnostics,
    );

    return PavManifestInspection(
      path: path,
      schemaVersion: schemaVersion,
      allowedSourceStates: allowedStates,
      protectedRuntimeSourcePrefixes: protectedPrefixes,
      variants: variants,
      diagnostics: diagnostics,
    );
  }

  void _validateRows({
    required List<PavManifestVariant> variants,
    required List<String> allowedStates,
    required List<String> protectedPrefixes,
    required List<PavDiagnostic> diagnostics,
  }) {
    final List<String> ids = variants.map((PavManifestVariant row) => row.variantId).toList();
    final Set<String> actualIds = ids.toSet();
    final Set<String> expectedIds =
        pavRequiredAssets.map((PavAssetContract asset) => asset.variantId).toSet();
    if (ids.length != pavRequiredAssets.length ||
        actualIds.length != expectedIds.length ||
        !actualIds.containsAll(expectedIds)) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'manifest.released-variant-set-invalid',
          message: 'Manifest must contain exactly the five released WALKA variant IDs.',
        ),
      );
    }

    final List<String> sourceIds = variants.map((PavManifestVariant row) => row.sourceId).toList();
    if (sourceIds.toSet().length != sourceIds.length) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'manifest.source-id-duplicate',
          message: 'Every admitted production source must have a unique sourceId.',
        ),
      );
    }

    final List<String> paths = variants.map((PavManifestVariant row) => row.canonicalPath).toList();
    if (paths.toSet().length != paths.length) {
      diagnostics.add(
        const PavDiagnostic(
          code: 'manifest.canonical-path-duplicate',
          message: 'Every released variant must own a unique canonical runtime path.',
        ),
      );
    }

    for (final PavManifestVariant row in variants) {
      if (!allowedStates.contains(row.sourceState)) {
        diagnostics.add(
          PavDiagnostic(
            code: 'manifest.source-state-invalid',
            message: '${row.variantId} uses unsupported sourceState ${row.sourceState}.',
          ),
        );
      }
      for (final String prefix in protectedPrefixes) {
        final String normalized = row.sourceFilename.replaceAll('\\', '/');
        if (normalized.startsWith(prefix)) {
          diagnostics.add(
            PavDiagnostic(
              code: 'manifest.protected-source-path',
              message: '${row.variantId} points into protected source prefix $prefix.',
            ),
          );
        }
      }

      PavAssetContract? contract;
      for (final PavAssetContract candidate in pavRequiredAssets) {
        if (candidate.variantId == row.variantId) {
          contract = candidate;
          break;
        }
      }
      if (contract == null) continue;
      if (row.canonicalPath != contract.path) {
        diagnostics.add(
          PavDiagnostic(
            code: 'manifest.canonical-path-mismatch',
            message: '${row.variantId} must map to ${contract.path}; found ${row.canonicalPath}.',
          ),
        );
      }
      if (row.family != contract.family || row.variant != contract.variant) {
        diagnostics.add(
          PavDiagnostic(
            code: 'manifest.variant-metadata-mismatch',
            message: '${row.variantId} family/variant metadata does not match the released runtime contract.',
          ),
        );
      }
    }
  }

  List<String> _stringList(Object? value) {
    if (value is! List<dynamic>) return const <String>[];
    return value.whereType<String>().toList(growable: false);
  }

  String? _string(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value;
  }
}
