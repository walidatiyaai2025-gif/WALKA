import 'walka_mobile_content.dart';

class WalkaStorefrontCopyContent {
  const WalkaStorefrontCopyContent({
    required this.categoriesHeading,
    required this.categoriesBody,
    required this.favoritesHeading,
    required this.favoritesBody,
    required this.favoritesEmptyTitle,
    required this.favoritesEmptyBody,
    required this.favoritesExploreLabel,
    required this.favoritesRemoveLabel,
    required this.pdpUnavailable,
    required this.pdpColorsLabel,
    required this.pdpFeaturesLabel,
    required this.pdpDetailsLabel,
    required this.pdpBuyLabel,
    required this.pdpAsinLabel,
    required this.pdpFavoriteAddLabel,
    required this.pdpFavoriteRemoveLabel,
  });

  static const WalkaStorefrontCopyContent bundled = WalkaStorefrontCopyContent(
    categoriesHeading: '',
    categoriesBody: '',
    favoritesHeading: '',
    favoritesBody: '',
    favoritesEmptyTitle: '',
    favoritesEmptyBody: '',
    favoritesExploreLabel: '',
    favoritesRemoveLabel: '',
    pdpUnavailable: '',
    pdpColorsLabel: '',
    pdpFeaturesLabel: '',
    pdpDetailsLabel: '',
    pdpBuyLabel: '',
    pdpAsinLabel: '',
    pdpFavoriteAddLabel: '',
    pdpFavoriteRemoveLabel: '',
  );

  final String categoriesHeading;
  final String categoriesBody;
  final String favoritesHeading;
  final String favoritesBody;
  final String favoritesEmptyTitle;
  final String favoritesEmptyBody;
  final String favoritesExploreLabel;
  final String favoritesRemoveLabel;
  final String pdpUnavailable;
  final String pdpColorsLabel;
  final String pdpFeaturesLabel;
  final String pdpDetailsLabel;
  final String pdpBuyLabel;
  final String pdpAsinLabel;
  final String pdpFavoriteAddLabel;
  final String pdpFavoriteRemoveLabel;

  factory WalkaStorefrontCopyContent.fromJson(Map<String, dynamic> json) {
    String requiredString(String key, int maxLength) {
      final Object? value = json[key];
      if (value is! String ||
          value.trim().isEmpty ||
          value.trim().length > maxLength) {
        throw FormatException('Invalid Storefront copy $key.');
      }
      return value.trim();
    }

    return WalkaStorefrontCopyContent(
      categoriesHeading: requiredString('categories_heading', 80),
      categoriesBody: requiredString('categories_body', 240),
      favoritesHeading: requiredString('favorites_heading', 80),
      favoritesBody: requiredString('favorites_body', 240),
      favoritesEmptyTitle: requiredString('favorites_empty_title', 100),
      favoritesEmptyBody: requiredString('favorites_empty_body', 240),
      favoritesExploreLabel: requiredString('favorites_explore_label', 80),
      favoritesRemoveLabel: requiredString('favorites_remove_label', 60),
      pdpUnavailable: requiredString('pdp_unavailable', 160),
      pdpColorsLabel: requiredString('pdp_colors_label', 60),
      pdpFeaturesLabel: requiredString('pdp_features_label', 60),
      pdpDetailsLabel: requiredString('pdp_details_label', 60),
      pdpBuyLabel: requiredString('pdp_buy_label', 80),
      pdpAsinLabel: requiredString('pdp_asin_label', 40),
      pdpFavoriteAddLabel: requiredString('pdp_favorite_add_label', 80),
      pdpFavoriteRemoveLabel: requiredString('pdp_favorite_remove_label', 80),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'categories_heading': categoriesHeading,
        'categories_body': categoriesBody,
        'favorites_heading': favoritesHeading,
        'favorites_body': favoritesBody,
        'favorites_empty_title': favoritesEmptyTitle,
        'favorites_empty_body': favoritesEmptyBody,
        'favorites_explore_label': favoritesExploreLabel,
        'favorites_remove_label': favoritesRemoveLabel,
        'pdp_unavailable': pdpUnavailable,
        'pdp_colors_label': pdpColorsLabel,
        'pdp_features_label': pdpFeaturesLabel,
        'pdp_details_label': pdpDetailsLabel,
        'pdp_buy_label': pdpBuyLabel,
        'pdp_asin_label': pdpAsinLabel,
        'pdp_favorite_add_label': pdpFavoriteAddLabel,
        'pdp_favorite_remove_label': pdpFavoriteRemoveLabel,
      };
}

class WalkaStorefrontCopyPayload {
  const WalkaStorefrontCopyPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaStorefrontCopyContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaStorefrontCopyPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    final Object? metaValue = json['meta'];
    if (dataValue is! Map || metaValue is! Map) {
      throw const FormatException('Storefront copy API envelope is invalid.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    if (data['key'] != 'storefront.copy' ||
        data['type'] != 'storefront.copy' ||
        data['schema_version'] != 1 ||
        metaValue['api_version'] != 'v1') {
      throw const FormatException('Unsupported Storefront copy identity/version.');
    }
    final Object? revisionValue = data['revision'];
    final Object? publishedValue = data['published_at'];
    final Object? payloadValue = data['payload'];
    if (revisionValue is! int ||
        revisionValue < 1 ||
        publishedValue is! String ||
        payloadValue is! Map) {
      throw const FormatException('Storefront copy metadata is invalid.');
    }
    final DateTime? publishedAt = DateTime.tryParse(publishedValue);
    if (publishedAt == null) {
      throw const FormatException('Storefront copy published_at is invalid.');
    }
    return WalkaStorefrontCopyPayload(
      content: WalkaStorefrontCopyContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaStorefrontCopySnapshot {
  const WalkaStorefrontCopySnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaStorefrontCopyContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaStorefrontCopySnapshot.bundled({DateTime? fetchedAt}) =>
      WalkaStorefrontCopySnapshot(
        content: WalkaStorefrontCopyContent.bundled,
        revision: 0,
        publishedAt: null,
        fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
        source: WalkaContentSource.bundled,
      );

  WalkaStorefrontCopySnapshot asSource(WalkaContentSource source) =>
      WalkaStorefrontCopySnapshot(
        content: content,
        revision: revision,
        publishedAt: publishedAt,
        fetchedAt: fetchedAt,
        source: source,
      );

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'cache_schema': 1,
        'revision': revision,
        'published_at': publishedAt?.toIso8601String(),
        'fetched_at': fetchedAt.toIso8601String(),
        'payload': content.toJson(),
      };

  factory WalkaStorefrontCopySnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Storefront copy cache schema.');
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
      throw const FormatException('Invalid Storefront copy cache snapshot.');
    }
    return WalkaStorefrontCopySnapshot(
      content: WalkaStorefrontCopyContent.fromJson(
        Map<String, dynamic>.from(payload),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
