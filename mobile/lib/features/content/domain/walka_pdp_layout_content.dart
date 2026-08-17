import 'walka_mobile_content.dart';

enum WalkaPdpSectionId {
  gallery('gallery'),
  identity('identity'),
  variants('variants'),
  usage('usage'),
  facts('facts'),
  editorial('editorial'),
  specifications('specifications'),
  amazonTrust('amazon_trust');

  const WalkaPdpSectionId(this.wireName);
  final String wireName;

  static WalkaPdpSectionId parse(Object? value) {
    if (value is! String) throw const FormatException('PDP section id must be a string.');
    for (final WalkaPdpSectionId id in values) {
      if (id.wireName == value) return id;
    }
    throw FormatException('Unsupported PDP section id: $value');
  }
}

class WalkaPdpSectionConfig {
  const WalkaPdpSectionConfig({required this.id, required this.visible});
  final WalkaPdpSectionId id;
  final bool visible;
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id.wireName, 'visible': visible};
}

class WalkaPdpLayoutContent {
  const WalkaPdpLayoutContent({required this.sections});

  static const Set<WalkaPdpSectionId> requiredVisible = <WalkaPdpSectionId>{
    WalkaPdpSectionId.gallery,
    WalkaPdpSectionId.identity,
    WalkaPdpSectionId.variants,
    WalkaPdpSectionId.facts,
    WalkaPdpSectionId.specifications,
    WalkaPdpSectionId.amazonTrust,
  };

  static const WalkaPdpLayoutContent bundled = WalkaPdpLayoutContent(
    sections: <WalkaPdpSectionConfig>[
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.gallery, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.identity, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.variants, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.usage, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.facts, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.editorial, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.specifications, visible: true),
      WalkaPdpSectionConfig(id: WalkaPdpSectionId.amazonTrust, visible: true),
    ],
  );

  final List<WalkaPdpSectionConfig> sections;
  Iterable<WalkaPdpSectionConfig> get visibleSections => sections.where((WalkaPdpSectionConfig section) => section.visible);

  factory WalkaPdpLayoutContent.fromJson(Map<String, dynamic> json) {
    final Object? sectionsValue = json['sections'];
    if (sectionsValue is! List || sectionsValue.length != WalkaPdpSectionId.values.length) {
      throw const FormatException('PDP layout must contain every supported section exactly once.');
    }
    final Set<WalkaPdpSectionId> seen = <WalkaPdpSectionId>{};
    final List<WalkaPdpSectionConfig> sections = <WalkaPdpSectionConfig>[];
    for (final Object? raw in sectionsValue) {
      if (raw is! Map) throw const FormatException('PDP layout section must be an object.');
      final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
      final WalkaPdpSectionId id = WalkaPdpSectionId.parse(map['id']);
      if (!seen.add(id)) throw FormatException('Duplicate PDP section: ${id.wireName}');
      final Object? visibleValue = map['visible'];
      if (visibleValue is! bool) throw FormatException('PDP section ${id.wireName} visibility must be boolean.');
      if (requiredVisible.contains(id) && !visibleValue) {
        throw FormatException('Protected PDP section ${id.wireName} cannot be hidden.');
      }
      sections.add(WalkaPdpSectionConfig(id: id, visible: visibleValue));
    }
    if (seen.length != WalkaPdpSectionId.values.length) throw const FormatException('PDP layout is missing supported sections.');
    return WalkaPdpLayoutContent(sections: List<WalkaPdpSectionConfig>.unmodifiable(sections));
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'sections': sections.map((WalkaPdpSectionConfig section) => section.toJson()).toList(growable: false),
      };
}

class WalkaPdpLayoutPayload {
  const WalkaPdpLayoutPayload({required this.content, required this.revision, required this.publishedAt});
  final WalkaPdpLayoutContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaPdpLayoutPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    if (dataValue is! Map) throw const FormatException('PDP layout data must be an object.');
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    if (data['key'] != 'pdp.layout' || data['type'] != 'pdp.layout') throw const FormatException('Unexpected WALKA PDP layout identity.');
    if (data['schema_version'] != 1) throw const FormatException('Unsupported WALKA PDP layout schema.');
    final Object? revisionValue = data['revision'];
    if (revisionValue is! int || revisionValue < 1) throw const FormatException('PDP layout revision must be positive.');
    final Object? publishedAtValue = data['published_at'];
    final DateTime? publishedAt = publishedAtValue is String ? DateTime.tryParse(publishedAtValue) : null;
    if (publishedAt == null) throw const FormatException('PDP layout published_at is invalid.');
    final Object? payloadValue = data['payload'];
    if (payloadValue is! Map) throw const FormatException('PDP layout payload must be an object.');
    final Object? metaValue = json['meta'];
    if (metaValue is! Map || metaValue['api_version'] != 'v1') throw const FormatException('Unsupported WALKA content API version.');
    return WalkaPdpLayoutPayload(
      content: WalkaPdpLayoutContent.fromJson(Map<String, dynamic>.from(payloadValue)),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaPdpLayoutSnapshot {
  const WalkaPdpLayoutSnapshot({required this.content, required this.revision, required this.publishedAt, required this.fetchedAt, required this.source});
  final WalkaPdpLayoutContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaPdpLayoutSnapshot.bundled({DateTime? fetchedAt}) => WalkaPdpLayoutSnapshot(
        content: WalkaPdpLayoutContent.bundled,
        revision: 0,
        publishedAt: null,
        fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
        source: WalkaContentSource.bundled,
      );

  WalkaPdpLayoutSnapshot asSource(WalkaContentSource nextSource) => WalkaPdpLayoutSnapshot(
        content: content,
        revision: revision,
        publishedAt: publishedAt,
        fetchedAt: fetchedAt,
        source: nextSource,
      );

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'cache_schema': 1,
        'revision': revision,
        'published_at': publishedAt?.toIso8601String(),
        'fetched_at': fetchedAt.toIso8601String(),
        'payload': content.toJson(),
      };

  factory WalkaPdpLayoutSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) throw const FormatException('Unsupported PDP layout cache schema.');
    final Object? revisionValue = json['revision'];
    if (revisionValue is! int || revisionValue < 1) throw const FormatException('Cached PDP layout revision is invalid.');
    final Object? publishedValue = json['published_at'];
    final DateTime? publishedAt = publishedValue is String ? DateTime.tryParse(publishedValue)?.toUtc() : null;
    if (publishedAt == null) throw const FormatException('Cached PDP layout published_at is invalid.');
    final Object? fetchedValue = json['fetched_at'];
    final DateTime? fetchedAt = fetchedValue is String ? DateTime.tryParse(fetchedValue)?.toUtc() : null;
    if (fetchedAt == null) throw const FormatException('Cached PDP layout fetched_at is invalid.');
    final Object? payloadValue = json['payload'];
    if (payloadValue is! Map) throw const FormatException('Cached PDP layout payload must be an object.');
    return WalkaPdpLayoutSnapshot(
      content: WalkaPdpLayoutContent.fromJson(Map<String, dynamic>.from(payloadValue)),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
