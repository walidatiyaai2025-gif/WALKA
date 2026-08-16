import 'walka_mobile_content.dart';

class WalkaSearchFilterLabel {
  const WalkaSearchFilterLabel({required this.id, required this.label});

  final String id;
  final String label;

  factory WalkaSearchFilterLabel.fromJson(Map<String, dynamic> json) {
    final Object? idValue = json['id'];
    final Object? labelValue = json['label'];
    if (idValue is! String ||
        !RegExp(r'^[a-z0-9][a-z0-9-]*$').hasMatch(idValue) ||
        labelValue is! String ||
        labelValue.trim().isEmpty ||
        labelValue.trim().length > 40) {
      throw const FormatException('Invalid WALKA Search filter label.');
    }
    return WalkaSearchFilterLabel(id: idValue, label: labelValue.trim());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'label': label,
      };
}

class WalkaSearchPresentationContent {
  const WalkaSearchPresentationContent({
    required this.heading,
    required this.supportingCopy,
    required this.placeholder,
    required this.emptyTitle,
    required this.emptyBody,
    required this.featuredVariantIds,
    required this.filterLabels,
  });

  /// Compatibility-only empty value. Production generic Search renders this
  /// copy only for remote/cache sources.
  static const WalkaSearchPresentationContent bundled =
      WalkaSearchPresentationContent(
    heading: '',
    supportingCopy: '',
    placeholder: '',
    emptyTitle: '',
    emptyBody: '',
    featuredVariantIds: <String>[],
    filterLabels: <WalkaSearchFilterLabel>[],
  );

  final String heading;
  final String supportingCopy;
  final String placeholder;
  final String emptyTitle;
  final String emptyBody;
  final List<String> featuredVariantIds;
  final List<WalkaSearchFilterLabel> filterLabels;

  String? filterLabel(String id) {
    for (final WalkaSearchFilterLabel item in filterLabels) {
      if (item.id == id) return item.label;
    }
    return null;
  }

  factory WalkaSearchPresentationContent.fromJson(Map<String, dynamic> json) {
    String requiredString(String key, int maxLength) {
      final Object? value = json[key];
      if (value is! String ||
          value.trim().isEmpty ||
          value.trim().length > maxLength) {
        throw FormatException('Invalid Search presentation $key.');
      }
      return value.trim();
    }

    final Object? variantsValue = json['featured_variant_ids'];
    if (variantsValue is! List) {
      throw const FormatException('Search merchandising order must be a list.');
    }
    final List<String> featuredVariantIds = variantsValue.map((Object? value) {
      if (value is! String ||
          !RegExp(r'^[a-z0-9][a-z0-9-]*:[a-z0-9][a-z0-9-]*$')
              .hasMatch(value)) {
        throw const FormatException('Invalid Search merchandising variant ID.');
      }
      return value;
    }).toList(growable: false);
    if (featuredVariantIds.toSet().length != featuredVariantIds.length) {
      throw const FormatException('Search merchandising variant IDs must be unique.');
    }

    final Object? filtersValue = json['filter_labels'];
    if (filtersValue is! List || filtersValue.isEmpty) {
      throw const FormatException('Search filter labels are required.');
    }
    final List<WalkaSearchFilterLabel> filters = filtersValue.map((Object? value) {
      if (value is! Map) {
        throw const FormatException('Search filter label must be an object.');
      }
      return WalkaSearchFilterLabel.fromJson(Map<String, dynamic>.from(value));
    }).toList(growable: false);
    final Set<String> filterSet =
        filters.map((WalkaSearchFilterLabel item) => item.id).toSet();
    if (filterSet.length != filters.length || !filterSet.contains('all')) {
      throw const FormatException(
        'Search filters must be unique and include the stable All filter.',
      );
    }

    return WalkaSearchPresentationContent(
      heading: requiredString('heading', 80),
      supportingCopy: requiredString('supporting_copy', 240),
      placeholder: requiredString('placeholder', 100),
      emptyTitle: requiredString('empty_title', 100),
      emptyBody: requiredString('empty_body', 240),
      featuredVariantIds: List<String>.unmodifiable(featuredVariantIds),
      filterLabels: List<WalkaSearchFilterLabel>.unmodifiable(filters),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'heading': heading,
        'supporting_copy': supportingCopy,
        'placeholder': placeholder,
        'empty_title': emptyTitle,
        'empty_body': emptyBody,
        'featured_variant_ids': featuredVariantIds,
        'filter_labels': filterLabels
            .map((WalkaSearchFilterLabel item) => item.toJson())
            .toList(growable: false),
      };
}

class WalkaSearchPresentationPayload {
  const WalkaSearchPresentationPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaSearchPresentationContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaSearchPresentationPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    final Object? metaValue = json['meta'];
    if (dataValue is! Map || metaValue is! Map) {
      throw const FormatException('Search API envelope is invalid.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    final Map<String, dynamic> meta = Map<String, dynamic>.from(metaValue);
    if (data['key'] != 'search.presentation' ||
        data['type'] != 'search.presentation' ||
        data['schema_version'] != 1 ||
        meta['api_version'] != 'v1') {
      throw const FormatException('Unsupported Search presentation identity/version.');
    }

    final Object? revisionValue = data['revision'];
    final Object? publishedValue = data['published_at'];
    final Object? payloadValue = data['payload'];
    if (revisionValue is! int ||
        revisionValue < 1 ||
        publishedValue is! String ||
        payloadValue is! Map) {
      throw const FormatException('Search presentation metadata is invalid.');
    }
    final DateTime? publishedAt = DateTime.tryParse(publishedValue);
    if (publishedAt == null) {
      throw const FormatException('Search presentation published_at is invalid.');
    }

    return WalkaSearchPresentationPayload(
      content: WalkaSearchPresentationContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaSearchPresentationSnapshot {
  const WalkaSearchPresentationSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaSearchPresentationContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaSearchPresentationSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaSearchPresentationSnapshot(
      content: WalkaSearchPresentationContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaSearchPresentationSnapshot asSource(WalkaContentSource source) {
    return WalkaSearchPresentationSnapshot(
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

  factory WalkaSearchPresentationSnapshot.fromCacheJson(
    Map<String, dynamic> json,
  ) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Search cache schema.');
    }
    final Object? revisionValue = json['revision'];
    final DateTime? publishedAt = json['published_at'] is String
        ? DateTime.tryParse(json['published_at'] as String)?.toUtc()
        : null;
    final DateTime? fetchedAt = json['fetched_at'] is String
        ? DateTime.tryParse(json['fetched_at'] as String)?.toUtc()
        : null;
    final Object? payload = json['payload'];
    if (revisionValue is! int ||
        revisionValue < 1 ||
        publishedAt == null ||
        fetchedAt == null ||
        payload is! Map) {
      throw const FormatException('Invalid Search cache snapshot.');
    }

    return WalkaSearchPresentationSnapshot(
      content: WalkaSearchPresentationContent.fromJson(
        Map<String, dynamic>.from(payload),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
