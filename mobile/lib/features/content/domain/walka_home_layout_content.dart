import 'walka_mobile_content.dart';

enum WalkaHomeSectionId {
  hero('hero'),
  benefits('benefits'),
  collection('collection'),
  smallChanges('small_changes'),
  trust('trust');

  const WalkaHomeSectionId(this.wireName);

  final String wireName;

  static WalkaHomeSectionId parse(Object? value) {
    if (value is! String) {
      throw const FormatException('Home section id must be a string.');
    }
    for (final WalkaHomeSectionId id in values) {
      if (id.wireName == value) return id;
    }
    throw FormatException('Unsupported Home section id: $value');
  }
}

class WalkaHomeSectionConfig {
  const WalkaHomeSectionConfig({
    required this.id,
    required this.visible,
    this.eyebrow,
    this.title,
    this.body,
  });

  final WalkaHomeSectionId id;
  final bool visible;
  final String? eyebrow;
  final String? title;
  final String? body;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': id.wireName,
      'visible': visible,
    };
    if (eyebrow != null) json['eyebrow'] = eyebrow;
    if (title != null) json['title'] = title;
    if (body != null) json['body'] = body;
    return json;
  }
}

class WalkaHomeLayoutContent {
  const WalkaHomeLayoutContent({required this.sections});

  static const WalkaHomeLayoutContent bundled = WalkaHomeLayoutContent(
    sections: <WalkaHomeSectionConfig>[
      WalkaHomeSectionConfig(id: WalkaHomeSectionId.hero, visible: true),
      WalkaHomeSectionConfig(id: WalkaHomeSectionId.benefits, visible: true),
      WalkaHomeSectionConfig(
        id: WalkaHomeSectionId.collection,
        visible: true,
        eyebrow: 'OUR COLLECTION',
        title: 'Everything in Its Place',
      ),
      WalkaHomeSectionConfig(
        id: WalkaHomeSectionId.smallChanges,
        visible: true,
        title: 'Small Changes,\nBetter Living',
        body: 'Simple solutions that bring order, beauty and peace of mind.',
      ),
      WalkaHomeSectionConfig(id: WalkaHomeSectionId.trust, visible: true),
    ],
  );

  final List<WalkaHomeSectionConfig> sections;

  Iterable<WalkaHomeSectionConfig> get visibleSections =>
      sections.where((WalkaHomeSectionConfig section) => section.visible);

  WalkaHomeSectionConfig section(WalkaHomeSectionId id) {
    return sections.firstWhere(
      (WalkaHomeSectionConfig section) => section.id == id,
    );
  }

  factory WalkaHomeLayoutContent.fromJson(Map<String, dynamic> json) {
    final Object? sectionsValue = json['sections'];
    if (sectionsValue is! List ||
        sectionsValue.length != WalkaHomeSectionId.values.length) {
      throw const FormatException(
        'Home layout must contain every supported section exactly once.',
      );
    }

    final Set<WalkaHomeSectionId> seen = <WalkaHomeSectionId>{};
    final List<WalkaHomeSectionConfig> sections = <WalkaHomeSectionConfig>[];

    for (final Object? raw in sectionsValue) {
      if (raw is! Map) {
        throw const FormatException('Home layout section must be an object.');
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final WalkaHomeSectionId id = WalkaHomeSectionId.parse(map['id']);
      if (!seen.add(id)) {
        throw FormatException('Duplicate Home section: ${id.wireName}');
      }
      final Object? visibleValue = map['visible'];
      if (visibleValue is! bool) {
        throw FormatException(
          'Home section ${id.wireName} visibility must be boolean.',
        );
      }
      if ((id == WalkaHomeSectionId.hero ||
              id == WalkaHomeSectionId.collection) &&
          !visibleValue) {
        throw FormatException(
          'Required Home section ${id.wireName} cannot be hidden.',
        );
      }

      switch (id) {
        case WalkaHomeSectionId.collection:
          sections.add(
            WalkaHomeSectionConfig(
              id: id,
              visible: visibleValue,
              eyebrow: _requiredString(map, 'eyebrow', 80, id),
              title: _requiredString(map, 'title', 120, id),
            ),
          );
          break;
        case WalkaHomeSectionId.smallChanges:
          sections.add(
            WalkaHomeSectionConfig(
              id: id,
              visible: visibleValue,
              title: _requiredString(map, 'title', 120, id),
              body: _requiredString(map, 'body', 300, id),
            ),
          );
          break;
        case WalkaHomeSectionId.hero:
        case WalkaHomeSectionId.benefits:
        case WalkaHomeSectionId.trust:
          sections.add(WalkaHomeSectionConfig(id: id, visible: visibleValue));
          break;
      }
    }

    if (seen.length != WalkaHomeSectionId.values.length) {
      throw const FormatException('Home layout is missing supported sections.');
    }

    return WalkaHomeLayoutContent(sections: List.unmodifiable(sections));
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sections': sections
            .map((WalkaHomeSectionConfig section) => section.toJson())
            .toList(growable: false),
      };

  static String _requiredString(
    Map<String, dynamic> map,
    String key,
    int maxLength,
    WalkaHomeSectionId id,
  ) {
    final Object? value = map[key];
    if (value is! String) {
      throw FormatException('${id.wireName} $key must be a string.');
    }
    final String normalized = value.trim();
    if (normalized.isEmpty || normalized.length > maxLength) {
      throw FormatException(
        '${id.wireName} $key must be 1-$maxLength characters.',
      );
    }
    return normalized;
  }
}

class WalkaHomeLayoutPayload {
  const WalkaHomeLayoutPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaHomeLayoutContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaHomeLayoutPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    if (dataValue is! Map) {
      throw const FormatException('Home layout data must be an object.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);

    if (data['key'] != 'home.layout' || data['type'] != 'home.layout') {
      throw const FormatException('Unexpected WALKA Home layout identity.');
    }
    if (data['schema_version'] != 1) {
      throw const FormatException('Unsupported WALKA Home layout schema.');
    }

    final Object? revisionValue = data['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Home layout revision must be positive.');
    }

    final Object? publishedAtValue = data['published_at'];
    if (publishedAtValue is! String || publishedAtValue.trim().isEmpty) {
      throw const FormatException('Home layout published_at is required.');
    }
    final DateTime? publishedAt = DateTime.tryParse(publishedAtValue);
    if (publishedAt == null) {
      throw const FormatException('Home layout published_at is invalid.');
    }

    final Object? payloadValue = data['payload'];
    if (payloadValue is! Map) {
      throw const FormatException('Home layout payload must be an object.');
    }

    final Object? metaValue = json['meta'];
    if (metaValue is! Map || metaValue['api_version'] != 'v1') {
      throw const FormatException('Unsupported WALKA content API version.');
    }

    return WalkaHomeLayoutPayload(
      content: WalkaHomeLayoutContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaHomeLayoutSnapshot {
  const WalkaHomeLayoutSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaHomeLayoutContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaHomeLayoutSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaHomeLayoutSnapshot(
      content: WalkaHomeLayoutContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaHomeLayoutSnapshot asSource(WalkaContentSource nextSource) {
    return WalkaHomeLayoutSnapshot(
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

  factory WalkaHomeLayoutSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Home layout cache schema.');
    }

    final Object? revisionValue = json['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Cached Home layout revision is invalid.');
    }

    final Object? publishedValue = json['published_at'];
    final DateTime? publishedAt = publishedValue is String
        ? DateTime.tryParse(publishedValue)?.toUtc()
        : null;
    if (publishedAt == null) {
      throw const FormatException('Cached Home layout published_at is invalid.');
    }

    final Object? fetchedValue = json['fetched_at'];
    final DateTime? fetchedAt = fetchedValue is String
        ? DateTime.tryParse(fetchedValue)?.toUtc()
        : null;
    if (fetchedAt == null) {
      throw const FormatException('Cached Home layout fetched_at is invalid.');
    }

    final Object? payloadValue = json['payload'];
    if (payloadValue is! Map) {
      throw const FormatException('Cached Home layout payload must be an object.');
    }

    return WalkaHomeLayoutSnapshot(
      content: WalkaHomeLayoutContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
