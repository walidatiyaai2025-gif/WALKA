import 'domain/walka_catalog.dart';

/// Presentation no longer owns catalog membership, names or variant ordering.
/// The validated Dashboard/DB/API snapshot is the single catalog authority.
WalkaCatalogSnapshot walkaPresentationSnapshot(WalkaCatalogSnapshot source) =>
    source;
