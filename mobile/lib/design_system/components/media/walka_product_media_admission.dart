enum WalkaProductMediaAdmissionState {
  pending,
  admitted,
  blocked,
}

class WalkaProductMediaAdmissionEntry {
  const WalkaProductMediaAdmissionEntry({
    required this.variantId,
    required this.canonicalPath,
    required this.state,
    required this.sourceApproved,
    required this.canonicalExportPresent,
  });

  final String variantId;
  final String canonicalPath;
  final WalkaProductMediaAdmissionState state;
  final bool sourceApproved;
  final bool canonicalExportPresent;

  bool get eligibleForRuntime =>
      state == WalkaProductMediaAdmissionState.admitted &&
      sourceApproved &&
      canonicalExportPresent;

  String get quarantineReason {
    if (state == WalkaProductMediaAdmissionState.blocked) {
      return 'source-or-provenance-blocked';
    }
    if (!sourceApproved) return 'source-not-approved';
    if (!canonicalExportPresent) return 'canonical-export-not-confirmed';
    if (state != WalkaProductMediaAdmissionState.admitted) {
      return 'provenance-not-admitted';
    }
    return 'admitted';
  }
}

/// Compile-time runtime-admission truth.
///
/// This registry deliberately separates *registered canonical paths* from
/// *runtime admission*. A PNG can exist in the Flutter bundle while remaining
/// quarantined. Promotion to [WalkaProductMediaAdmissionState.admitted] is
/// allowed only after source admission, canonical-export confirmation and
/// provenance/visual QA have all been reconciled.
abstract final class WalkaProductMediaAdmissionRegistry {
  static const List<String> releasedVariantIds = <String>[
    'drawer-organizer:white',
    'drawer-organizer:gray',
    'lunch-box:blue',
    'lunch-box:pink',
    'lunch-box:green',
  ];

  static const Map<String, WalkaProductMediaAdmissionEntry> entries =
      <String, WalkaProductMediaAdmissionEntry>{
    'drawer-organizer:white': WalkaProductMediaAdmissionEntry(
      variantId: 'drawer-organizer:white',
      canonicalPath: 'assets/products/drawer/white.png',
      state: WalkaProductMediaAdmissionState.admitted,
      sourceApproved: true,
      canonicalExportPresent: true,
    ),
    'drawer-organizer:gray': WalkaProductMediaAdmissionEntry(
      variantId: 'drawer-organizer:gray',
      canonicalPath: 'assets/products/drawer/gray.png',
      state: WalkaProductMediaAdmissionState.blocked,
      sourceApproved: false,
      canonicalExportPresent: false,
    ),
    'lunch-box:blue': WalkaProductMediaAdmissionEntry(
      variantId: 'lunch-box:blue',
      canonicalPath: 'assets/products/lunch/blue.png',
      state: WalkaProductMediaAdmissionState.admitted,
      sourceApproved: true,
      canonicalExportPresent: true,
    ),
    'lunch-box:pink': WalkaProductMediaAdmissionEntry(
      variantId: 'lunch-box:pink',
      canonicalPath: 'assets/products/lunch/pink.png',
      state: WalkaProductMediaAdmissionState.admitted,
      sourceApproved: true,
      canonicalExportPresent: true,
    ),
    'lunch-box:green': WalkaProductMediaAdmissionEntry(
      variantId: 'lunch-box:green',
      canonicalPath: 'assets/products/lunch/green.png',
      state: WalkaProductMediaAdmissionState.pending,
      sourceApproved: true,
      canonicalExportPresent: false,
    ),
  };

  static WalkaProductMediaAdmissionEntry? entryFor(String variantId) =>
      entries[variantId];

  static bool isRuntimeEligible(String variantId) =>
      entries[variantId]?.eligibleForRuntime ?? false;

  static Iterable<String> get admittedVariantIds => entries.values
      .where((WalkaProductMediaAdmissionEntry entry) => entry.eligibleForRuntime)
      .map((WalkaProductMediaAdmissionEntry entry) => entry.variantId);

  static Iterable<String> get quarantinedVariantIds => entries.values
      .where((WalkaProductMediaAdmissionEntry entry) => !entry.eligibleForRuntime)
      .map((WalkaProductMediaAdmissionEntry entry) => entry.variantId);

  static Iterable<String> get pendingVariantIds => entries.values
      .where(
        (WalkaProductMediaAdmissionEntry entry) =>
            entry.state == WalkaProductMediaAdmissionState.pending,
      )
      .map((WalkaProductMediaAdmissionEntry entry) => entry.variantId);

  static Iterable<String> get blockedVariantIds => entries.values
      .where(
        (WalkaProductMediaAdmissionEntry entry) =>
            entry.state == WalkaProductMediaAdmissionState.blocked,
      )
      .map((WalkaProductMediaAdmissionEntry entry) => entry.variantId);

  static int get registeredCount => entries.length;
  static int get admittedCount => admittedVariantIds.length;
  static int get pendingCount => pendingVariantIds.length;
  static int get blockedCount => blockedVariantIds.length;
  static int get quarantinedCount => quarantinedVariantIds.length;

  static bool get allReleasedMediaAdmitted =>
      registeredCount == releasedVariantIds.length &&
      admittedCount == releasedVariantIds.length &&
      pendingCount == 0 &&
      blockedCount == 0;
}
