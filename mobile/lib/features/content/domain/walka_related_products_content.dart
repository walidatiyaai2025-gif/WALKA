import 'walka_mobile_content.dart';

class WalkaRelatedProductRelationship {
  const WalkaRelatedProductRelationship({
    required this.productId,
    required this.relatedProductIds,
  });

  final String productId;
  final List<String> relatedProductIds;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'product_id': productId,
        'related_product_ids': relatedProductIds,
      };
}

class WalkaRelatedProductsContent {
  const WalkaRelatedProductsContent({required this.relationships});

  static const int maxRelated = 4;
  static const WalkaRelatedProductsContent bundled = WalkaRelatedProductsContent(
    relationships: <WalkaRelatedProductRelationship>[],
  );

  final List<WalkaRelatedProductRelationship> relationships;

  List<String> relatedIdsFor(String productId) {
    for (final WalkaRelatedProductRelationship relationship in relationships) {
      if (relationship.productId == productId) {
        return relationship.relatedProductIds;
      }
    }
    return const <String>[];
  }

  factory WalkaRelatedProductsContent.fromJson(Map<String, dynamic> json) {
    final Object? relationshipsValue = json['relationships'];
    if (relationshipsValue is! List || relationshipsValue.length > 256) {
      throw const FormatException(
        'Related-product relationships must be a bounded ordered list.',
      );
    }

    final Set<String> seenSources = <String>{};
    final List<WalkaRelatedProductRelationship> relationships =
        <WalkaRelatedProductRelationship>[];
    String? previousSource;

    for (final Object? rawRelationship in relationshipsValue) {
      if (rawRelationship is! Map) {
        throw const FormatException(
          'Each related-product relationship must be an object.',
        );
      }
      final Map<String, dynamic> relationship =
          Map<String, dynamic>.from(rawRelationship);
      final String productId = _catalogId(relationship['product_id']);
      if (!seenSources.add(productId)) {
        throw FormatException('Duplicate related-product source: $productId');
      }
      if (previousSource != null && productId.compareTo(previousSource) < 0) {
        throw const FormatException(
          'Related-product source ordering must be deterministic.',
        );
      }
      previousSource = productId;

      final Object? relatedValue = relationship['related_product_ids'];
      if (relatedValue is! List || relatedValue.length > maxRelated) {
        throw const FormatException(
          'Related-product IDs must be an ordered bounded list.',
        );
      }

      final Set<String> seenRelated = <String>{};
      final List<String> relatedIds = <String>[];
      for (final Object? rawRelatedId in relatedValue) {
        final String relatedId = _catalogId(rawRelatedId);
        if (relatedId == productId) {
          throw const FormatException('A product cannot recommend itself.');
        }
        if (!seenRelated.add(relatedId)) {
          throw const FormatException(
            'Related-product targets must be unique per source product.',
          );
        }
        relatedIds.add(relatedId);
      }

      relationships.add(
        WalkaRelatedProductRelationship(
          productId: productId,
          relatedProductIds: List<String>.unmodifiable(relatedIds),
        ),
      );
    }

    return WalkaRelatedProductsContent(
      relationships:
          List<WalkaRelatedProductRelationship>.unmodifiable(relationships),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'relationships': relationships
            .map(
              (WalkaRelatedProductRelationship relationship) =>
                  relationship.toJson(),
            )
            .toList(growable: false),
      };
}

class WalkaRelatedProductsPayload {
  const WalkaRelatedProductsPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaRelatedProductsContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaRelatedProductsPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    if (dataValue is! Map) {
      throw const FormatException('Related-products data must be an object.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    if (data['key'] != 'pdp.related_products' ||
        data['type'] != 'pdp.related_products') {
      throw const FormatException('Unexpected WALKA related-products identity.');
    }
    if (data['schema_version'] != 1) {
      throw const FormatException('Unsupported WALKA related-products schema.');
    }
    final Object? revisionValue = data['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Related-products revision must be positive.');
    }
    final Object? publishedAtValue = data['published_at'];
    final DateTime? publishedAt = publishedAtValue is String
        ? DateTime.tryParse(publishedAtValue)?.toUtc()
        : null;
    if (publishedAt == null) {
      throw const FormatException('Related-products published_at is invalid.');
    }
    final Object? payloadValue = data['payload'];
    if (payloadValue is! Map) {
      throw const FormatException('Related-products payload must be an object.');
    }
    final Object? metaValue = json['meta'];
    if (metaValue is! Map || metaValue['api_version'] != 'v1') {
      throw const FormatException('Unsupported WALKA content API version.');
    }

    return WalkaRelatedProductsPayload(
      content: WalkaRelatedProductsContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
    );
  }
}

class WalkaRelatedProductsSnapshot {
  const WalkaRelatedProductsSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaRelatedProductsContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaRelatedProductsSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaRelatedProductsSnapshot(
      content: WalkaRelatedProductsContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaRelatedProductsSnapshot asSource(WalkaContentSource nextSource) {
    return WalkaRelatedProductsSnapshot(
      content: content,
      revision: revision,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: nextSource,
    );
  }

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'cache_schema': 1,
        'revision': revision,
        'published_at': publishedAt?.toIso8601String(),
        'fetched_at': fetchedAt.toIso8601String(),
        'payload': content.toJson(),
      };

  factory WalkaRelatedProductsSnapshot.fromCacheJson(
    Map<String, dynamic> json,
  ) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported related-products cache schema.');
    }
    final Object? revisionValue = json['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Cached related-products revision is invalid.');
    }
    final Object? publishedValue = json['published_at'];
    final DateTime? publishedAt = publishedValue is String
        ? DateTime.tryParse(publishedValue)?.toUtc()
        : null;
    if (publishedAt == null) {
      throw const FormatException(
        'Cached related-products published_at is invalid.',
      );
    }
    final Object? fetchedValue = json['fetched_at'];
    final DateTime? fetchedAt = fetchedValue is String
        ? DateTime.tryParse(fetchedValue)?.toUtc()
        : null;
    if (fetchedAt == null) {
      throw const FormatException('Cached related-products fetched_at is invalid.');
    }
    final Object? payloadValue = json['payload'];
    if (payloadValue is! Map) {
      throw const FormatException(
        'Cached related-products payload must be an object.',
      );
    }

    return WalkaRelatedProductsSnapshot(
      content: WalkaRelatedProductsContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}

String _catalogId(Object? value) {
  if (value is! String ||
      !RegExp(r'^[a-z0-9][a-z0-9-]*$').hasMatch(value.trim())) {
    throw const FormatException('Related products contain an invalid catalog product ID.');
  }
  return value.trim();
}
