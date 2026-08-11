enum WalkaContentSource { remote, cache, bundled }

class WalkaHomeHeroContent {
  const WalkaHomeHeroContent({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.shopLabel,
    required this.searchLabel,
  });

  static const WalkaHomeHeroContent bundled = WalkaHomeHeroContent(
    eyebrow: 'PREMIUM ORGANIZATION\nELEVATED EVERYDAY.',
    title: 'Organize Better.\nLive Better.',
    body:
        'Premium drawer organizers and stainless steel lunch boxes designed for calm, everyday order.',
    shopLabel: 'SHOP PRODUCTS',
    searchLabel: 'SEARCH COLLECTION',
  );

  final String eyebrow;
  final String title;
  final String body;
  final String shopLabel;
  final String searchLabel;

  factory WalkaHomeHeroContent.fromJson(Map<String, dynamic> json) {
    String requiredString(String key, {required int maxLength}) {
      final Object? value = json[key];
      if (value is! String) {
        throw FormatException('Home hero $key must be a string.');
      }
      final String normalized = value.trim();
      if (normalized.isEmpty || normalized.length > maxLength) {
        throw FormatException(
          'Home hero $key must be 1-$maxLength characters.',
        );
      }
      return normalized;
    }

    return WalkaHomeHeroContent(
      eyebrow: requiredString('eyebrow', maxLength: 120),
      title: requiredString('title', maxLength: 160),
      body: requiredString('body', maxLength: 500),
      shopLabel: requiredString('shop_label', maxLength: 64),
      searchLabel: requiredString('search_label', maxLength: 64),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'eyebrow': eyebrow,
        'title': title,
        'body': body,
        'shop_label': shopLabel,
        'search_label': searchLabel,
      };
}

class WalkaHomeHeroPayload {
  const WalkaHomeHeroPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaHomeHeroContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaHomeHeroPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    if (dataValue is! Map) {
      throw const FormatException('Home content data must be an object.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);

    if (data['key'] != 'home.hero' || data['type'] != 'home.hero') {
      throw const FormatException('Unexpected WALKA Home content identity.');
    }
    if (data['schema_version'] != 1) {
      throw const FormatException('Unsupported WALKA Home content schema.');
    }

    final Object? revisionValue = data['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Home content revision must be positive.');
    }

    final Object? publishedAtValue = data['published_at'];
    if (publishedAtValue is! String || publishedAtValue.trim().isEmpty) {
      throw const FormatException('Home content published_at is required.');
    }
    final DateTime? publishedAt = DateTime.tryParse(publishedAtValue);
    if (publishedAt == null) {
      throw const FormatException('Home content published_at is invalid.');
    }

    final Object? payloadValue = data['payload'];
    if (payloadValue is! Map) {
      throw const FormatException('Home content payload must be an object.');
    }

    final Object? metaValue = json['meta'];
    if (metaValue is! Map || metaValue['api_version'] != 'v1') {
      throw const FormatException('Unsupported WALKA content API version.');
    }

    return WalkaHomeHeroPayload(
      content: WalkaHomeHeroContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaHomeHeroSnapshot {
  const WalkaHomeHeroSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaHomeHeroContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaHomeHeroSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaHomeHeroSnapshot(
      content: WalkaHomeHeroContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaHomeHeroSnapshot asSource(WalkaContentSource nextSource) {
    return WalkaHomeHeroSnapshot(
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

  factory WalkaHomeHeroSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Home content cache schema.');
    }

    final Object? revisionValue = json['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Cached Home content revision is invalid.');
    }

    final Object? publishedValue = json['published_at'];
    final DateTime? publishedAt = publishedValue is String
        ? DateTime.tryParse(publishedValue)?.toUtc()
        : null;
    if (publishedAt == null) {
      throw const FormatException('Cached Home published_at is invalid.');
    }

    final Object? fetchedValue = json['fetched_at'];
    final DateTime? fetchedAt = fetchedValue is String
        ? DateTime.tryParse(fetchedValue)?.toUtc()
        : null;
    if (fetchedAt == null) {
      throw const FormatException('Cached Home fetched_at is invalid.');
    }

    final Object? payloadValue = json['payload'];
    if (payloadValue is! Map) {
      throw const FormatException('Cached Home payload must be an object.');
    }

    return WalkaHomeHeroSnapshot(
      content: WalkaHomeHeroContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
