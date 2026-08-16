import 'package:flutter/foundation.dart';

const Set<String> _allowedRemoteMediaMime = <String>{
  'image/png',
  'image/jpeg',
  'image/webp',
};

const int walkaRemoteMediaMaxBytes = 16 * 1024 * 1024;
const int walkaRemoteProductGalleryMaxItems = 8;
const String walkaEmptyMediaRevision =
    '0000000000000000000000000000000000000000000000000000000000000000';

final RegExp _entityIdPattern = RegExp(r'^[a-z0-9][a-z0-9-]*$');
final RegExp _variantIdPattern =
    RegExp(r'^[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*$');

@immutable
class WalkaRemoteMediaItem {
  const WalkaRemoteMediaItem({
    required this.mediaId,
    required this.position,
    required this.semanticLabel,
    required this.mime,
    required this.bytes,
    required this.width,
    required this.height,
    required this.sha256,
  });

  final String mediaId;
  final int position;
  final String semanticLabel;
  final String mime;
  final int bytes;
  final int width;
  final int height;
  final String sha256;

  String get cacheKey => 'walka-media-$mediaId-$sha256';
  String get expectedEtag => '"sha256-$sha256"';

  String get fileExtension => switch (mime) {
        'image/png' => 'png',
        'image/jpeg' => 'jpg',
        'image/webp' => 'webp',
        _ => 'bin',
      };

  factory WalkaRemoteMediaItem.fromJson(Map<String, dynamic> json) {
    final String mediaId = _requiredString(json, 'media_id', maxLength: 64);
    if (!RegExp(
      r'^[0-9A-HJKMNP-TV-Z]{26}$',
      caseSensitive: false,
    ).hasMatch(mediaId)) {
      throw const FormatException('Remote media ID must be a canonical ULID.');
    }
    final int position = _requiredInt(
      json,
      'position',
      min: 1,
      max: walkaRemoteProductGalleryMaxItems,
    );
    final String semanticLabel =
        _requiredString(json, 'semantic_label', maxLength: 160);
    final Object? canonicalObject = json['canonical'];
    if (canonicalObject is! Map) {
      throw const FormatException('Remote media canonical metadata is required.');
    }
    final Map<String, dynamic> canonical =
        Map<String, dynamic>.from(canonicalObject);
    final String mime = _requiredString(canonical, 'mime', maxLength: 32);
    if (!_allowedRemoteMediaMime.contains(mime)) {
      throw const FormatException('Unsupported remote media MIME type.');
    }
    final int bytes = _requiredInt(
      canonical,
      'bytes',
      min: 1,
      max: walkaRemoteMediaMaxBytes,
    );
    final int width = _requiredInt(canonical, 'width', min: 1, max: 8192);
    final int height = _requiredInt(canonical, 'height', min: 1, max: 8192);
    final String sha256 =
        _requiredString(canonical, 'sha256', maxLength: 64).toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256)) {
      throw const FormatException('Remote media SHA-256 is invalid.');
    }

    return WalkaRemoteMediaItem(
      mediaId: mediaId,
      position: position,
      semanticLabel: semanticLabel,
      mime: mime,
      bytes: bytes,
      width: width,
      height: height,
      sha256: sha256,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'media_id': mediaId,
        'position': position,
        'semantic_label': semanticLabel,
        'canonical': <String, dynamic>{
          'mime': mime,
          'bytes': bytes,
          'width': width,
          'height': height,
          'sha256': sha256,
        },
      };
}

@immutable
class WalkaRemoteProductMediaPayload {
  WalkaRemoteProductMediaPayload({
    required this.revisionToken,
    required Map<String, List<WalkaRemoteMediaItem>> galleriesByVariant,
  }) : galleriesByVariant = Map<String, List<WalkaRemoteMediaItem>>.unmodifiable(
          galleriesByVariant.map(
            (String key, List<WalkaRemoteMediaItem> value) => MapEntry(
              key,
              List<WalkaRemoteMediaItem>.unmodifiable(value),
            ),
          ),
        );

  factory WalkaRemoteProductMediaPayload.empty() =>
      WalkaRemoteProductMediaPayload(
        revisionToken: walkaEmptyMediaRevision,
        galleriesByVariant: const <String, List<WalkaRemoteMediaItem>>{},
      );

  final String revisionToken;
  final Map<String, List<WalkaRemoteMediaItem>> galleriesByVariant;

  factory WalkaRemoteProductMediaPayload.fromApiJson(
    Map<String, dynamic> root,
  ) {
    _validateEnvelope(root);
    final Map<String, dynamic> data = _requiredMap(root, 'data');
    if (_requiredInt(data, 'schema_version', min: 1, max: 1) != 1) {
      throw const FormatException('Unsupported product media schema.');
    }
    final String revisionToken = _requiredSha(data, 'revision_token');
    final List<dynamic> products = _requiredList(data, 'products');

    final Map<String, List<WalkaRemoteMediaItem>> galleries =
        <String, List<WalkaRemoteMediaItem>>{};
    final Set<String> seenProducts = <String>{};
    final Set<String> seenVariants = <String>{};

    for (final Object? rawProduct in products) {
      if (rawProduct is! Map) {
        throw const FormatException('Product media entry must be an object.');
      }
      final Map<String, dynamic> product = Map<String, dynamic>.from(rawProduct);
      final String productId =
          _requiredString(product, 'product_id', maxLength: 96);
      if (!_entityIdPattern.hasMatch(productId) || !seenProducts.add(productId)) {
        throw const FormatException('Unknown-format or duplicate product media identity.');
      }

      // Validate product-level gallery even though the public runtime resolves
      // the already-reconciled variant gallery supplied by the backend.
      _parseMediaItems(
        _requiredList(product, 'gallery'),
        maxItems: walkaRemoteProductGalleryMaxItems,
      );

      final List<dynamic> variants = _requiredList(product, 'variants');
      if (variants.isEmpty) {
        throw FormatException('Visible product $productId has no visible media variants.');
      }
      for (final Object? rawVariant in variants) {
        if (rawVariant is! Map) {
          throw const FormatException('Variant media entry must be an object.');
        }
        final Map<String, dynamic> variant = Map<String, dynamic>.from(rawVariant);
        final String variantId =
            _requiredString(variant, 'variant_id', maxLength: 96);
        if (!_variantIdPattern.hasMatch(variantId) || !seenVariants.add(variantId)) {
          throw FormatException('Unknown-format or duplicate variant media identity: $variantId.');
        }
        final String source =
            _requiredString(variant, 'gallery_source', maxLength: 32);
        if (source != 'variant' && source != 'product_fallback') {
          throw const FormatException('Unsupported variant gallery source.');
        }
        galleries[variantId] = _parseMediaItems(
          _requiredList(variant, 'gallery'),
          maxItems: walkaRemoteProductGalleryMaxItems,
        );
      }
    }

    return WalkaRemoteProductMediaPayload(
      revisionToken: revisionToken,
      galleriesByVariant: galleries,
    );
  }

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'revision_token': revisionToken,
        'galleries_by_variant': galleriesByVariant.map(
          (String key, List<WalkaRemoteMediaItem> value) => MapEntry(
            key,
            value.map((WalkaRemoteMediaItem item) => item.toJson()).toList(),
          ),
        ),
      };

  factory WalkaRemoteProductMediaPayload.fromCacheJson(
    Map<String, dynamic> json,
  ) {
    final String revisionToken = _requiredSha(json, 'revision_token');
    final Map<String, dynamic> raw = _requiredMap(json, 'galleries_by_variant');
    final Map<String, List<WalkaRemoteMediaItem>> galleries =
        <String, List<WalkaRemoteMediaItem>>{};
    for (final MapEntry<String, dynamic> entry in raw.entries) {
      if (!_variantIdPattern.hasMatch(entry.key)) {
        throw FormatException('Cached product media variant ID is invalid: ${entry.key}.');
      }
      galleries[entry.key] = _parseMediaItems(
        _asList(entry.value, 'cached gallery'),
        maxItems: walkaRemoteProductGalleryMaxItems,
      );
    }
    return WalkaRemoteProductMediaPayload(
      revisionToken: revisionToken,
      galleriesByVariant: galleries,
    );
  }
}

@immutable
class WalkaRemoteSurfaceMediaPayload {
  WalkaRemoteSurfaceMediaPayload({
    required this.revisionToken,
    required Map<String, List<WalkaRemoteMediaItem>> itemsBySlot,
  }) : itemsBySlot = Map<String, List<WalkaRemoteMediaItem>>.unmodifiable(
          itemsBySlot.map(
            (String key, List<WalkaRemoteMediaItem> value) => MapEntry(
              key,
              List<WalkaRemoteMediaItem>.unmodifiable(value),
            ),
          ),
        );

  factory WalkaRemoteSurfaceMediaPayload.empty() => WalkaRemoteSurfaceMediaPayload(
        revisionToken: walkaEmptyMediaRevision,
        itemsBySlot: const <String, List<WalkaRemoteMediaItem>>{},
      );

  final String revisionToken;
  final Map<String, List<WalkaRemoteMediaItem>> itemsBySlot;

  factory WalkaRemoteSurfaceMediaPayload.fromApiJson(Map<String, dynamic> root) {
    _validateEnvelope(root);
    final Map<String, dynamic> data = _requiredMap(root, 'data');
    if (_requiredInt(data, 'schema_version', min: 1, max: 1) != 1) {
      throw const FormatException('Unsupported surface media schema.');
    }
    final String revisionToken = _requiredSha(data, 'revision_token');
    final List<dynamic> slots = _requiredList(data, 'slots');
    final Map<String, List<WalkaRemoteMediaItem>> itemsBySlot =
        <String, List<WalkaRemoteMediaItem>>{};

    for (final Object? rawSlot in slots) {
      if (rawSlot is! Map) {
        throw const FormatException('Surface media slot must be an object.');
      }
      final Map<String, dynamic> slot = Map<String, dynamic>.from(rawSlot);
      final String slotKey = _requiredString(slot, 'slot_key', maxLength: 96);
      if (itemsBySlot.containsKey(slotKey)) {
        throw const FormatException('Duplicate surface media slot.');
      }
      _validateSurfaceIdentity(
        slotKey: slotKey,
        purpose: _requiredString(slot, 'purpose', maxLength: 32),
        categoryId: slot['category_id'],
      );
      itemsBySlot[slotKey] = _parseMediaItems(
        _requiredList(slot, 'items'),
        maxItems: 1,
      );
    }

    return WalkaRemoteSurfaceMediaPayload(
      revisionToken: revisionToken,
      itemsBySlot: itemsBySlot,
    );
  }

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'revision_token': revisionToken,
        'items_by_slot': itemsBySlot.map(
          (String key, List<WalkaRemoteMediaItem> value) => MapEntry(
            key,
            value.map((WalkaRemoteMediaItem item) => item.toJson()).toList(),
          ),
        ),
      };

  factory WalkaRemoteSurfaceMediaPayload.fromCacheJson(Map<String, dynamic> json) {
    final String revisionToken = _requiredSha(json, 'revision_token');
    final Map<String, dynamic> raw = _requiredMap(json, 'items_by_slot');
    final Map<String, List<WalkaRemoteMediaItem>> items =
        <String, List<WalkaRemoteMediaItem>>{};
    for (final MapEntry<String, dynamic> entry in raw.entries) {
      _validateCachedSurfaceKey(entry.key);
      items[entry.key] = _parseMediaItems(
        _asList(entry.value, 'cached slot'),
        maxItems: 1,
      );
    }
    return WalkaRemoteSurfaceMediaPayload(
      revisionToken: revisionToken,
      itemsBySlot: items,
    );
  }
}

enum WalkaRemoteMediaSource { remote, cache, unavailable }

@immutable
class WalkaRemoteMediaSnapshot {
  const WalkaRemoteMediaSnapshot({
    required this.products,
    required this.surfaces,
    required this.source,
    required this.fetchedAt,
  });

  final WalkaRemoteProductMediaPayload products;
  final WalkaRemoteSurfaceMediaPayload surfaces;
  final WalkaRemoteMediaSource source;
  final DateTime fetchedAt;

  factory WalkaRemoteMediaSnapshot.unavailable({DateTime? fetchedAt}) =>
      WalkaRemoteMediaSnapshot(
        products: WalkaRemoteProductMediaPayload.empty(),
        surfaces: WalkaRemoteSurfaceMediaPayload.empty(),
        source: WalkaRemoteMediaSource.unavailable,
        fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      );

  List<WalkaRemoteMediaItem> galleryForVariant(String variantId) =>
      products.galleriesByVariant[variantId] ?? const <WalkaRemoteMediaItem>[];

  WalkaRemoteMediaItem? firstForVariant(String variantId) {
    final List<WalkaRemoteMediaItem> gallery = galleryForVariant(variantId);
    return gallery.isEmpty ? null : gallery.first;
  }

  WalkaRemoteMediaItem? firstForSlot(String slotKey) {
    final List<WalkaRemoteMediaItem> items =
        surfaces.itemsBySlot[slotKey] ?? const <WalkaRemoteMediaItem>[];
    return items.isEmpty ? null : items.first;
  }
}

void _validateSurfaceIdentity({
  required String slotKey,
  required String purpose,
  required Object? categoryId,
}) {
  if (slotKey == 'home.hero') {
    if (purpose != 'home' || categoryId != null) {
      throw const FormatException('Home Hero media identity is invalid.');
    }
    return;
  }
  if (slotKey == 'home.editorial.small_changes') {
    if (purpose != 'editorial' || categoryId != null) {
      throw const FormatException('Home editorial media identity is invalid.');
    }
    return;
  }
  if (slotKey.startsWith('category:')) {
    final String id = slotKey.substring('category:'.length);
    if (!_entityIdPattern.hasMatch(id) || purpose != 'category' || categoryId != id) {
      throw FormatException('Dynamic category media identity is invalid: $slotKey.');
    }
    return;
  }
  throw FormatException('Unsupported surface media slot: $slotKey.');
}

void _validateCachedSurfaceKey(String slotKey) {
  if (slotKey == 'home.hero' || slotKey == 'home.editorial.small_changes') {
    return;
  }
  if (slotKey.startsWith('category:') &&
      _entityIdPattern.hasMatch(slotKey.substring('category:'.length))) {
    return;
  }
  throw FormatException('Cached surface media slot is invalid: $slotKey.');
}

void _validateEnvelope(Map<String, dynamic> root) {
  final Map<String, dynamic> meta = _requiredMap(root, 'meta');
  if (_requiredString(meta, 'api_version', maxLength: 8) != 'v1' ||
      _requiredString(meta, 'binary_delivery', maxLength: 40) !=
          'canonical_by_media_id') {
    throw const FormatException('Unsupported remote media delivery contract.');
  }
}

List<WalkaRemoteMediaItem> _parseMediaItems(
  List<dynamic> raw, {
  required int maxItems,
}) {
  if (raw.length > maxItems) {
    throw FormatException('Remote media list exceeds maximum $maxItems.');
  }
  final List<WalkaRemoteMediaItem> items = <WalkaRemoteMediaItem>[];
  final Set<String> ids = <String>{};
  int expectedPosition = 1;
  for (final Object? value in raw) {
    if (value is! Map) {
      throw const FormatException('Remote media item must be an object.');
    }
    final WalkaRemoteMediaItem item =
        WalkaRemoteMediaItem.fromJson(Map<String, dynamic>.from(value));
    if (!ids.add(item.mediaId)) {
      throw const FormatException('Duplicate remote media ID in one gallery.');
    }
    if (item.position != expectedPosition++) {
      throw const FormatException(
        'Remote media positions must be contiguous from one.',
      );
    }
    items.add(item);
  }
  return List<WalkaRemoteMediaItem>.unmodifiable(items);
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! Map) throw FormatException('$key must be an object.');
  return Map<String, dynamic>.from(value);
}

List<dynamic> _requiredList(Map<String, dynamic> json, String key) =>
    _asList(json[key], key);

List<dynamic> _asList(Object? value, String label) {
  if (value is! List) throw FormatException('$label must be a list.');
  return List<dynamic>.from(value);
}

String _requiredString(
  Map<String, dynamic> json,
  String key, {
  required int maxLength,
}) {
  final Object? value = json[key];
  if (value is! String || value.trim().isEmpty || value.trim().length > maxLength) {
    throw FormatException('$key must be a bounded non-empty string.');
  }
  return value.trim();
}

String _requiredSha(Map<String, dynamic> json, String key) {
  final String value = _requiredString(json, key, maxLength: 64).toLowerCase();
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
    throw FormatException('$key must be a SHA-256 digest.');
  }
  return value;
}

int _requiredInt(
  Map<String, dynamic> json,
  String key, {
  required int min,
  required int max,
}) {
  final Object? value = json[key];
  if (value is! int || value < min || value > max) {
    throw FormatException('$key must be between $min and $max.');
  }
  return value;
}
