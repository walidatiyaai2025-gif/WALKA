import 'walka_mobile_content.dart';

class WalkaHomeFeaturedContent {
  const WalkaHomeFeaturedContent({
    required this.collectionVariantIds,
    required this.editorialVariantId,
  });

  static const WalkaHomeFeaturedContent bundled = WalkaHomeFeaturedContent(
    collectionVariantIds: <String>[
      'lunch-box:blue',
      'drawer-organizer:white',
    ],
    editorialVariantId: 'drawer-organizer:white',
  );

  final List<String> collectionVariantIds;
  final String editorialVariantId;

  factory WalkaHomeFeaturedContent.fromJson(Map<String, dynamic> json) {
    final Object? collectionValue = json['collection_variant_ids'];
    if (collectionValue is! List || collectionValue.length != 2) {
      throw const FormatException(
        'Home featured collection must contain exactly two variant IDs.',
      );
    }

    final List<String> collection = collectionValue.map((Object? value) {
      if (value is! String || !_validVariantId(value)) {
        throw const FormatException('Invalid Home featured collection variant ID.');
      }
      return value;
    }).toList(growable: false);

    if (collection.toSet().length != 2) {
      throw const FormatException('Featured collection variants must be unique.');
    }
    if (_family(collection[0]) == _family(collection[1])) {
      throw const FormatException(
        'Featured collection must contain different product families.',
      );
    }

    final Object? editorialValue = json['editorial_variant_id'];
    if (editorialValue is! String || !_validVariantId(editorialValue)) {
      throw const FormatException('Invalid Home editorial variant ID.');
    }

    return WalkaHomeFeaturedContent(
      collectionVariantIds: List<String>.unmodifiable(collection),
      editorialVariantId: editorialValue,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'collection_variant_ids': collectionVariantIds,
        'editorial_variant_id': editorialVariantId,
      };

  static bool _validVariantId(String value) {
    return RegExp(r'^[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*$')
        .hasMatch(value);
  }

  static String _family(String value) => value.split(':').first;
}

class WalkaHomeFeaturedPayload {
  const WalkaHomeFeaturedPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaHomeFeaturedContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaHomeFeaturedPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    if (dataValue is! Map) {
      throw const FormatException('Home featured data must be an object.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    if (data['key'] != 'home.featured' || data['type'] != 'home.featured') {
      throw const FormatException('Unexpected Home featured content identity.');
    }
    if (data['schema_version'] != 1) {
      throw const FormatException('Unsupported Home featured schema.');
    }

    final Object? revisionValue = data['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Home featured revision must be positive.');
    }
    final Object? publishedValue = data['published_at'];
    if (publishedValue is! String) {
      throw const FormatException('Home featured published_at is required.');
    }
    final DateTime? publishedAt = DateTime.tryParse(publishedValue);
    if (publishedAt == null) {
      throw const FormatException('Home featured published_at is invalid.');
    }
    final Object? payloadValue = data['payload'];
    if (payloadValue is! Map) {
      throw const FormatException('Home featured payload must be an object.');
    }
    final Object? meta = json['meta'];
    if (meta is! Map || meta['api_version'] != 'v1') {
      throw const FormatException('Unsupported WALKA content API version.');
    }

    return WalkaHomeFeaturedPayload(
      content: WalkaHomeFeaturedContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaHomeFeaturedSnapshot {
  const WalkaHomeFeaturedSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaHomeFeaturedContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaHomeFeaturedSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaHomeFeaturedSnapshot(
      content: WalkaHomeFeaturedContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaHomeFeaturedSnapshot asSource(WalkaContentSource source) {
    return WalkaHomeFeaturedSnapshot(
      content: content,
      revision: revision,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: source,
    );
  }

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'cache_schema': 1,
        'revision': revision,
        'published_at': publishedAt?.toIso8601String(),
        'fetched_at': fetchedAt.toIso8601String(),
        'payload': content.toJson(),
      };

  factory WalkaHomeFeaturedSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Home featured cache schema.');
    }
    final Object? revisionValue = json['revision'];
    final DateTime? publishedAt = json['published_at'] is String
        ? DateTime.tryParse(json['published_at'] as String)?.toUtc()
        : null;
    final DateTime? fetchedAt = json['fetched_at'] is String
        ? DateTime.tryParse(json['fetched_at'] as String)?.toUtc()
        : null;
    final Object? payload = json['payload'];
    if (revisionValue is! int || revisionValue < 1 ||
        publishedAt == null || fetchedAt == null || payload is! Map) {
      throw const FormatException('Invalid Home featured cache snapshot.');
    }
    return WalkaHomeFeaturedSnapshot(
      content: WalkaHomeFeaturedContent.fromJson(
        Map<String, dynamic>.from(payload),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
