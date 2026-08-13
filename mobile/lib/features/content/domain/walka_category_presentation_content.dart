import 'walka_mobile_content.dart';

class WalkaCategoryPresentationItem {
  const WalkaCategoryPresentationItem({
    required this.id,
    required this.displayName,
    required this.description,
    required this.visible,
  });

  final String id;
  final String displayName;
  final String description;
  final bool visible;

  factory WalkaCategoryPresentationItem.fromJson(Map<String, dynamic> json) {
    final Object? idValue = json['id'];
    final Object? nameValue = json['display_name'];
    final Object? descriptionValue = json['description'];
    final Object? visibleValue = json['visible'];
    if (idValue is! String ||
        !RegExp(r'^[a-z0-9][a-z0-9-]*$').hasMatch(idValue) ||
        nameValue is! String ||
        nameValue.trim().isEmpty ||
        nameValue.trim().length > 80 ||
        descriptionValue is! String ||
        descriptionValue.trim().isEmpty ||
        descriptionValue.trim().length > 240 ||
        visibleValue is! bool) {
      throw const FormatException('Invalid WALKA category presentation entry.');
    }

    return WalkaCategoryPresentationItem(
      id: idValue,
      displayName: nameValue.trim(),
      description: descriptionValue.trim(),
      visible: visibleValue,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'display_name': displayName,
        'description': description,
        'visible': visible,
      };
}

class WalkaCategoryPresentationContent {
  const WalkaCategoryPresentationContent({required this.categories});

  static const Set<String> protectedCategoryIds = <String>{
    'lunch',
    'drawer-organization',
  };

  static const WalkaCategoryPresentationContent bundled =
      WalkaCategoryPresentationContent(
    categories: <WalkaCategoryPresentationItem>[
      WalkaCategoryPresentationItem(
        id: 'lunch',
        displayName: 'Lunch Boxes',
        description:
            'Stainless steel lunch systems for organized everyday meals.',
        visible: true,
      ),
      WalkaCategoryPresentationItem(
        id: 'drawer-organization',
        displayName: 'Drawer Organizers',
        description:
            'Expandable organizers designed to bring calm order to drawers.',
        visible: true,
      ),
    ],
  );

  final List<WalkaCategoryPresentationItem> categories;

  List<WalkaCategoryPresentationItem> get visibleCategories =>
      List<WalkaCategoryPresentationItem>.unmodifiable(
        categories.where((WalkaCategoryPresentationItem item) => item.visible),
      );

  factory WalkaCategoryPresentationContent.fromJson(Map<String, dynamic> json) {
    final Object? categoriesValue = json['categories'];
    if (categoriesValue is! List || categoriesValue.isEmpty) {
      throw const FormatException('Category presentation list is required.');
    }

    final List<WalkaCategoryPresentationItem> categories = categoriesValue
        .map((Object? value) {
          if (value is! Map) {
            throw const FormatException('Category presentation entry must be an object.');
          }
          return WalkaCategoryPresentationItem.fromJson(
            Map<String, dynamic>.from(value),
          );
        })
        .toList(growable: false);

    final Set<String> ids = categories
        .map((WalkaCategoryPresentationItem item) => item.id)
        .toSet();
    if (ids.length != categories.length ||
        ids.length != protectedCategoryIds.length ||
        !ids.containsAll(protectedCategoryIds)) {
      throw const FormatException(
        'Category presentation must preserve the complete protected category set.',
      );
    }
    if (!categories.any((WalkaCategoryPresentationItem item) => item.visible)) {
      throw const FormatException('At least one WALKA category must remain visible.');
    }

    return WalkaCategoryPresentationContent(
      categories: List<WalkaCategoryPresentationItem>.unmodifiable(categories),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'categories': categories
            .map((WalkaCategoryPresentationItem item) => item.toJson())
            .toList(growable: false),
      };
}

class WalkaCategoryPresentationPayload {
  const WalkaCategoryPresentationPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaCategoryPresentationContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaCategoryPresentationPayload.fromApiJson(
    Map<String, dynamic> json,
  ) {
    final Object? dataValue = json['data'];
    final Object? metaValue = json['meta'];
    if (dataValue is! Map || metaValue is! Map) {
      throw const FormatException('Categories API envelope is invalid.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    final Map<String, dynamic> meta = Map<String, dynamic>.from(metaValue);
    if (data['key'] != 'categories.presentation' ||
        data['type'] != 'categories.presentation' ||
        data['schema_version'] != 1 ||
        meta['api_version'] != 'v1') {
      throw const FormatException('Unsupported category presentation identity/version.');
    }

    final Object? revisionValue = data['revision'];
    final Object? publishedValue = data['published_at'];
    final Object? payloadValue = data['payload'];
    if (revisionValue is! int ||
        revisionValue < 1 ||
        publishedValue is! String ||
        payloadValue is! Map) {
      throw const FormatException('Category presentation metadata is invalid.');
    }
    final DateTime? publishedAt = DateTime.tryParse(publishedValue);
    if (publishedAt == null) {
      throw const FormatException('Category presentation published_at is invalid.');
    }

    return WalkaCategoryPresentationPayload(
      content: WalkaCategoryPresentationContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaCategoryPresentationSnapshot {
  const WalkaCategoryPresentationSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaCategoryPresentationContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaCategoryPresentationSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaCategoryPresentationSnapshot(
      content: WalkaCategoryPresentationContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaCategoryPresentationSnapshot asSource(WalkaContentSource source) {
    return WalkaCategoryPresentationSnapshot(
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

  factory WalkaCategoryPresentationSnapshot.fromCacheJson(
    Map<String, dynamic> json,
  ) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Categories cache schema.');
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
      throw const FormatException('Invalid Categories cache snapshot.');
    }

    return WalkaCategoryPresentationSnapshot(
      content: WalkaCategoryPresentationContent.fromJson(
        Map<String, dynamic>.from(payload),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
