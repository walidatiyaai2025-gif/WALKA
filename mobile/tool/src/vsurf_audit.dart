import 'dart:convert';
import 'dart:io';

enum VsurfSeverity { blocker, warning }

class VsurfDeviceTarget {
  const VsurfDeviceTarget(this.id, this.width, this.height,
      {this.safeArea = false, this.desktop = false});

  final String id;
  final int width;
  final int height;
  final bool safeArea;
  final bool desktop;

  Map<String, Object> toJson() => <String, Object>{
        'id': id,
        'width': width,
        'height': height,
        'safeArea': safeArea,
        'desktop': desktop,
      };
}

class VsurfSurfaceSlot {
  const VsurfSurfaceSlot({
    required this.id,
    required this.sourcePath,
    required this.surfaceToken,
    required this.deviceIds,
    this.requiredWidgetMarker = 'WalkaResolvedProductMedia(',
    this.requireSemanticLabel = true,
    this.prohibitDirectProductAssets = true,
    this.severity = VsurfSeverity.blocker,
  });

  final String id;
  final String sourcePath;
  final String surfaceToken;
  final List<String> deviceIds;
  final String requiredWidgetMarker;
  final bool requireSemanticLabel;
  final bool prohibitDirectProductAssets;
  final VsurfSeverity severity;

  Map<String, Object> toJson() => <String, Object>{
        'id': id,
        'sourcePath': sourcePath,
        'surfaceToken': surfaceToken,
        'deviceIds': deviceIds,
        'severity': severity.name,
      };
}

class VsurfAdmissionEntry {
  const VsurfAdmissionEntry({
    required this.variantId,
    required this.state,
    required this.sourceApproved,
    required this.canonicalExportPresent,
  });

  final String variantId;
  final String state;
  final bool sourceApproved;
  final bool canonicalExportPresent;

  bool get eligible =>
      state == 'admitted' && sourceApproved && canonicalExportPresent;

  Map<String, Object> toJson() => <String, Object>{
        'variantId': variantId,
        'state': state,
        'sourceApproved': sourceApproved,
        'canonicalExportPresent': canonicalExportPresent,
        'eligible': eligible,
      };
}

class VsurfViolation {
  const VsurfViolation({
    required this.code,
    required this.message,
    required this.severity,
    this.slotId,
    this.sourcePath,
    this.line,
  });

  final String code;
  final String message;
  final VsurfSeverity severity;
  final String? slotId;
  final String? sourcePath;
  final int? line;

  Map<String, Object?> toJson() => <String, Object?>{
        'code': code,
        'message': message,
        'severity': severity.name,
        'slotId': slotId,
        'sourcePath': sourcePath,
        'line': line,
      };
}

abstract final class VsurfContractRegistry {
  static const List<VsurfDeviceTarget> devices = <VsurfDeviceTarget>[
    VsurfDeviceTarget('compact-320x568', 320, 568),
    VsurfDeviceTarget('standard-390x844', 390, 844),
    VsurfDeviceTarget('large-430x932', 430, 932),
    VsurfDeviceTarget('ios-safe-area', 390, 844, safeArea: true),
    VsurfDeviceTarget('tablet', 768, 1024),
    VsurfDeviceTarget('desktop', 1440, 900, desktop: true),
  ];

  static const List<String> phoneTargets = <String>[
    'compact-320x568',
    'standard-390x844',
    'large-430x932',
    'ios-safe-area',
  ];

  static const List<String> adaptiveTargets = <String>[
    ...phoneTargets,
    'tablet',
    'desktop',
  ];

  static const List<VsurfSurfaceSlot> slots = <VsurfSurfaceSlot>[
    VsurfSurfaceSlot(
      id: 'home-hero',
      sourcePath: 'lib/features/storefront/presentation/widgets/home/walka_home_hero.dart',
      surfaceToken: 'WalkaProductMediaSurface.home',
      deviceIds: adaptiveTargets,
    ),
    VsurfSurfaceSlot(
      id: 'home-collection-card',
      sourcePath: 'lib/features/storefront/presentation/widgets/home/walka_home_collection_card.dart',
      surfaceToken: 'WalkaProductMediaSurface.home',
      deviceIds: adaptiveTargets,
    ),
    VsurfSurfaceSlot(
      id: 'home-small-changes',
      sourcePath: 'lib/features/storefront/presentation/widgets/home/walka_home_small_changes.dart',
      surfaceToken: 'WalkaProductMediaSurface.home',
      deviceIds: adaptiveTargets,
    ),
    VsurfSurfaceSlot(
      id: 'discovery-category-card',
      sourcePath: 'lib/features/storefront/presentation/widgets/discovery/walka_category_card.dart',
      surfaceToken: 'WalkaProductMediaSurface.discovery',
      deviceIds: adaptiveTargets,
    ),
    VsurfSurfaceSlot(
      id: 'discovery-product-row',
      sourcePath: 'lib/features/storefront/presentation/widgets/discovery/walka_discovery_product_row.dart',
      surfaceToken: 'WalkaProductMediaSurface.discovery',
      deviceIds: adaptiveTargets,
    ),
    VsurfSurfaceSlot(
      id: 'pdp-gallery',
      sourcePath: 'lib/features/products/presentation/widgets/walka_pdp_gallery_viewport.dart',
      surfaceToken: 'WalkaProductMediaSurface.pdp',
      deviceIds: adaptiveTargets,
    ),
    VsurfSurfaceSlot(
      id: 'pdp-fullscreen-gallery',
      sourcePath: 'lib/features/products/presentation/widgets/walka_pdp_fullscreen_gallery.dart',
      surfaceToken: 'WalkaProductMediaSurface.pdp',
      deviceIds: adaptiveTargets,
    ),
    VsurfSurfaceSlot(
      id: 'favorites-saved-card',
      sourcePath: 'lib/features/storefront/presentation/widgets/favorites/walka_saved_drawer_card.dart',
      surfaceToken: 'WalkaProductMediaSurface.favorites',
      deviceIds: phoneTargets,
    ),
    VsurfSurfaceSlot(
      id: 'about-product-story',
      sourcePath: 'lib/features/storefront/presentation/widgets/about/walka_about_product_story.dart',
      surfaceToken: 'WalkaProductMediaSurface.about',
      deviceIds: phoneTargets,
    ),
  ];
}

class VsurfReport {
  const VsurfReport({
    required this.slots,
    required this.admission,
    required this.matrix,
    required this.violations,
  });

  final List<VsurfSurfaceSlot> slots;
  final List<VsurfAdmissionEntry> admission;
  final Map<String, List<String>> matrix;
  final List<VsurfViolation> violations;

  int get blockerCount => violations
      .where((VsurfViolation v) => v.severity == VsurfSeverity.blocker)
      .length;
  int get warningCount => violations.length - blockerCount;
  int get admittedCount =>
      admission.where((VsurfAdmissionEntry entry) => entry.eligible).length;
  int get pendingCount =>
      admission.where((VsurfAdmissionEntry entry) => entry.state == 'pending').length;
  int get blockedCount =>
      admission.where((VsurfAdmissionEntry entry) => entry.state == 'blocked').length;
  bool get integrationReady => blockerCount == 0;
  bool get globalReleaseReady => integrationReady && admittedCount == 5;

  Map<String, Object> toJson() => <String, Object>{
        'schemaVersion': 1,
        'state': integrationReady ? 'READY' : 'BLOCKED',
        'globalReleaseState': globalReleaseReady ? 'READY' : 'BLOCKED',
        'slotCount': slots.length,
        'deviceTargetCount': VsurfContractRegistry.devices.length,
        'blockerCount': blockerCount,
        'warningCount': warningCount,
        'admittedCount': admittedCount,
        'pendingCount': pendingCount,
        'blockedCount': blockedCount,
        'slots': slots.map((VsurfSurfaceSlot slot) => slot.toJson()).toList(),
        'admission': admission
            .map((VsurfAdmissionEntry entry) => entry.toJson())
            .toList(),
        'matrix': matrix,
        'violations': violations.map((VsurfViolation v) => v.toJson()).toList(),
      };

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  String summary() =>
      'VSURF ${integrationReady ? 'READY' : 'BLOCKED'} | slots ${slots.length} | '
      'admitted $admittedCount/5 | pending $pendingCount | blocked $blockedCount | '
      'integration blockers $blockerCount | warnings $warningCount | '
      'global ${globalReleaseReady ? 'READY' : 'BLOCKED'}';
}

class VsurfAuditor {
  const VsurfAuditor({required this.mobileRoot});

  final Directory mobileRoot;

  VsurfReport audit() {
    final List<VsurfViolation> violations = <VsurfViolation>[];
    _validateRegistry(violations);
    for (final VsurfSurfaceSlot slot in VsurfContractRegistry.slots) {
      _scanSlot(slot, violations);
    }
    final List<VsurfAdmissionEntry> admission = _readAdmission(violations);
    _validateAdmission(admission, violations);
    final Map<String, List<String>> matrix = _buildMatrix(violations);
    violations.sort((VsurfViolation a, VsurfViolation b) {
      final int code = a.code.compareTo(b.code);
      if (code != 0) return code;
      return (a.slotId ?? '').compareTo(b.slotId ?? '');
    });
    return VsurfReport(
      slots: List<VsurfSurfaceSlot>.unmodifiable(VsurfContractRegistry.slots),
      admission: List<VsurfAdmissionEntry>.unmodifiable(admission),
      matrix: Map<String, List<String>>.unmodifiable(matrix),
      violations: List<VsurfViolation>.unmodifiable(violations),
    );
  }

  void _validateRegistry(List<VsurfViolation> out) {
    final Set<String> ids = <String>{};
    final Set<String> paths = <String>{};
    for (final VsurfSurfaceSlot slot in VsurfContractRegistry.slots) {
      if (!ids.add(slot.id)) {
        out.add(VsurfViolation(
          code: 'registry.duplicate-slot-id',
          message: 'Duplicate slot id ${slot.id}',
          severity: VsurfSeverity.blocker,
          slotId: slot.id,
        ));
      }
      if (!paths.add(slot.sourcePath)) {
        out.add(VsurfViolation(
          code: 'registry.duplicate-source-path',
          message: 'Duplicate source path ${slot.sourcePath}',
          severity: VsurfSeverity.blocker,
          slotId: slot.id,
          sourcePath: slot.sourcePath,
        ));
      }
    }
  }

  void _scanSlot(VsurfSurfaceSlot slot, List<VsurfViolation> out) {
    final File file = File('${mobileRoot.path}/${slot.sourcePath}');
    if (!file.existsSync()) {
      out.add(VsurfViolation(
        code: 'source.missing',
        message: 'Owner-visible source is missing',
        severity: slot.severity,
        slotId: slot.id,
        sourcePath: slot.sourcePath,
      ));
      return;
    }
    final String source = file.readAsStringSync();
    _requireToken(source, slot, slot.requiredWidgetMarker,
        'source.media-widget-missing', out);
    _requireToken(source, slot, 'mediaSurface:',
        'source.surface-declaration-missing', out);
    _requireToken(source, slot, slot.surfaceToken,
        'source.surface-token-mismatch', out);
    if (slot.requireSemanticLabel) {
      _requireToken(source, slot, 'semanticLabel:',
          'source.semantic-label-missing', out);
    }
    if (slot.prohibitDirectProductAssets) {
      final RegExp directAsset = RegExp(
        r'''Image\.asset\s*\(\s*['\"]assets/products/''',
        multiLine: true,
      );
      final Match? match = directAsset.firstMatch(source);
      if (match != null) {
        out.add(VsurfViolation(
          code: 'source.direct-product-asset-bypass',
          message: 'Direct canonical product Image.asset bypasses resolver/admission',
          severity: VsurfSeverity.blocker,
          slotId: slot.id,
          sourcePath: slot.sourcePath,
          line: _lineForOffset(source, match.start),
        ));
      }
    }
  }

  void _requireToken(String source, VsurfSurfaceSlot slot, String token,
      String code, List<VsurfViolation> out) {
    final int offset = source.indexOf(token);
    if (offset >= 0) return;
    out.add(VsurfViolation(
      code: code,
      message: 'Expected token `$token` not found',
      severity: slot.severity,
      slotId: slot.id,
      sourcePath: slot.sourcePath,
    ));
  }

  List<VsurfAdmissionEntry> _readAdmission(List<VsurfViolation> out) {
    final File file = File(
      '${mobileRoot.path}/lib/design_system/components/media/walka_product_media_admission.dart',
    );
    if (!file.existsSync()) {
      out.add(const VsurfViolation(
        code: 'admission.registry-missing',
        message: 'Runtime admission registry source is missing',
        severity: VsurfSeverity.blocker,
      ));
      return <VsurfAdmissionEntry>[];
    }
    final String source = file.readAsStringSync();
    final RegExp entryPattern = RegExp(
      r'''['\"]([^'\"]+)['\"]\s*:\s*WalkaProductMediaAdmissionEntry\((.*?)\n\s*\),''',
      dotAll: true,
    );
    final List<VsurfAdmissionEntry> result = <VsurfAdmissionEntry>[];
    for (final RegExpMatch match in entryPattern.allMatches(source)) {
      final String block = match.group(2)!;
      final RegExpMatch? state = RegExp(
        r'WalkaProductMediaAdmissionState\.(pending|admitted|blocked)',
      ).firstMatch(block);
      final RegExpMatch? approved =
          RegExp(r'sourceApproved:\s*(true|false)').firstMatch(block);
      final RegExpMatch? present = RegExp(
        r'canonicalExportPresent:\s*(true|false)',
      ).firstMatch(block);
      if (state == null || approved == null || present == null) continue;
      result.add(VsurfAdmissionEntry(
        variantId: match.group(1)!,
        state: state.group(1)!,
        sourceApproved: approved.group(1) == 'true',
        canonicalExportPresent: present.group(1) == 'true',
      ));
    }
    result.sort((VsurfAdmissionEntry a, VsurfAdmissionEntry b) =>
        _releasedOrder(a.variantId).compareTo(_releasedOrder(b.variantId)));
    return result;
  }

  void _validateAdmission(
      List<VsurfAdmissionEntry> admission, List<VsurfViolation> out) {
    const List<String> released = <String>[
      'drawer-organizer:white',
      'drawer-organizer:gray',
      'lunch-box:blue',
      'lunch-box:pink',
      'lunch-box:green',
    ];
    final List<String> ids =
        admission.map((VsurfAdmissionEntry e) => e.variantId).toList();
    if (ids.length != released.length ||
        !released.every(ids.contains) ||
        !ids.every(released.contains)) {
      out.add(VsurfViolation(
        code: 'admission.released-set-mismatch',
        message: 'Expected exactly ${released.join(', ')}; found ${ids.join(', ')}',
        severity: VsurfSeverity.blocker,
      ));
    }
    for (final VsurfAdmissionEntry entry in admission) {
      if (entry.state == 'admitted' && !entry.canonicalExportPresent) {
        out.add(VsurfViolation(
          code: 'admission.admitted-without-export',
          message: '${entry.variantId} is admitted without canonical export confirmation',
          severity: VsurfSeverity.blocker,
        ));
      }
      if (entry.state == 'admitted' && !entry.sourceApproved) {
        out.add(VsurfViolation(
          code: 'admission.admitted-without-source',
          message: '${entry.variantId} is admitted without source approval',
          severity: VsurfSeverity.blocker,
        ));
      }
      if (entry.state == 'blocked' && entry.eligible) {
        out.add(VsurfViolation(
          code: 'admission.blocked-runtime-eligible',
          message: '${entry.variantId} is blocked but runtime eligible',
          severity: VsurfSeverity.blocker,
        ));
      }
      if (entry.state == 'pending' && entry.eligible) {
        out.add(VsurfViolation(
          code: 'admission.pending-runtime-eligible',
          message: '${entry.variantId} is pending but runtime eligible',
          severity: VsurfSeverity.blocker,
        ));
      }
    }
  }

  Map<String, List<String>> _buildMatrix(List<VsurfViolation> out) {
    final Map<String, List<String>> matrix = <String, List<String>>{};
    final Set<String> validDevices =
        VsurfContractRegistry.devices.map((VsurfDeviceTarget d) => d.id).toSet();
    for (final VsurfSurfaceSlot slot in VsurfContractRegistry.slots) {
      final List<String> devices = <String>[...slot.deviceIds]..sort();
      matrix[slot.id] = devices;
      for (final String device in devices) {
        if (!validDevices.contains(device)) {
          out.add(VsurfViolation(
            code: 'matrix.unknown-device',
            message: '${slot.id} declares unknown target $device',
            severity: VsurfSeverity.blocker,
            slotId: slot.id,
          ));
        }
      }
      for (final String required in VsurfContractRegistry.phoneTargets) {
        if (!devices.contains(required)) {
          out.add(VsurfViolation(
            code: 'matrix.mobile-coverage-missing',
            message: '${slot.id} is missing $required coverage',
            severity: VsurfSeverity.blocker,
            slotId: slot.id,
          ));
        }
      }
      final bool adaptiveRequired = slot.surfaceToken.endsWith('.home') ||
          slot.surfaceToken.endsWith('.discovery') ||
          slot.surfaceToken.endsWith('.pdp');
      if (adaptiveRequired) {
        for (final String required in <String>['tablet', 'desktop']) {
          if (!devices.contains(required)) {
            out.add(VsurfViolation(
              code: 'matrix.adaptive-coverage-missing',
              message: '${slot.id} is missing $required coverage',
              severity: VsurfSeverity.blocker,
              slotId: slot.id,
            ));
          }
        }
      }
    }
    final List<String> keys = matrix.keys.toList()..sort();
    return <String, List<String>>{
      for (final String key in keys) key: matrix[key]!,
    };
  }

  int _lineForOffset(String source, int offset) =>
      '\n'.allMatches(source.substring(0, offset)).length + 1;

  int _releasedOrder(String id) {
    const List<String> order = <String>[
      'drawer-organizer:white',
      'drawer-organizer:gray',
      'lunch-box:blue',
      'lunch-box:pink',
      'lunch-box:green',
    ];
    final int index = order.indexOf(id);
    return index < 0 ? 999 : index;
  }
}
