import 'walka_mobile_content.dart';

enum WalkaHomeBannerAction { none, browse, search }

class WalkaHomeBannerContent {
  const WalkaHomeBannerContent({
    required this.enabled,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.ctaAction,
    this.ctaLabel,
    this.startsAt,
    this.endsAt,
  });

  static const WalkaHomeBannerContent bundled = WalkaHomeBannerContent(
    enabled: false,
    eyebrow: 'WALKA NOTE',
    title: 'A calmer way to organize.',
    body: 'Explore thoughtful organization for home and everyday routines.',
    ctaAction: WalkaHomeBannerAction.browse,
    ctaLabel: 'EXPLORE WALKA',
  );

  final bool enabled;
  final String eyebrow;
  final String title;
  final String body;
  final String? ctaLabel;
  final WalkaHomeBannerAction ctaAction;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool isActiveAt(DateTime instant) {
    if (!enabled) return false;
    final DateTime now = instant.toUtc();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && !now.isBefore(endsAt!)) return false;
    return true;
  }

  factory WalkaHomeBannerContent.fromJson(Map<String, dynamic> json) {
    final Object? enabled = json['enabled'];
    final String eyebrow = _requiredString(json, 'eyebrow', max: 80);
    final String title = _requiredString(json, 'title', max: 140);
    final String body = _requiredString(json, 'body', max: 320);
    final Object? actionValue = json['cta_action'];
    if (enabled is! bool || actionValue is! String) {
      throw const FormatException('Invalid Home banner enabled/action fields.');
    }

    final WalkaHomeBannerAction action = switch (actionValue) {
      'none' => WalkaHomeBannerAction.none,
      'browse' => WalkaHomeBannerAction.browse,
      'search' => WalkaHomeBannerAction.search,
      _ => throw const FormatException('Unsupported Home banner CTA action.'),
    };

    String? ctaLabel;
    final Object? labelValue = json['cta_label'];
    if (labelValue != null) {
      if (labelValue is! String ||
          labelValue.trim().isEmpty ||
          labelValue.trim().length > 48) {
        throw const FormatException('Invalid Home banner CTA label.');
      }
      ctaLabel = labelValue.trim();
    }
    if (action != WalkaHomeBannerAction.none && ctaLabel == null) {
      throw const FormatException('Home banner CTA label is required.');
    }
    if (action == WalkaHomeBannerAction.none) {
      ctaLabel = null;
    }

    final DateTime? startsAt = _nullableTimestamp(json['starts_at']);
    final DateTime? endsAt = _nullableTimestamp(json['ends_at']);
    if (startsAt != null && endsAt != null && !endsAt.isAfter(startsAt)) {
      throw const FormatException('Home banner end must be after start.');
    }

    return WalkaHomeBannerContent(
      enabled: enabled,
      eyebrow: eyebrow,
      title: title,
      body: body,
      ctaAction: action,
      ctaLabel: ctaLabel,
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'enabled': enabled,
        'eyebrow': eyebrow,
        'title': title,
        'body': body,
        'cta_label': ctaLabel,
        'cta_action': ctaAction.name,
        'starts_at': startsAt?.toUtc().toIso8601String(),
        'ends_at': endsAt?.toUtc().toIso8601String(),
      };

  static String _requiredString(
    Map<String, dynamic> json,
    String key, {
    required int max,
  }) {
    final Object? value = json[key];
    if (value is! String || value.trim().isEmpty || value.trim().length > max) {
      throw FormatException('Invalid Home banner $key.');
    }
    return value.trim();
  }

  static DateTime? _nullableTimestamp(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('Home banner schedule must be an ISO timestamp.');
    }
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) {
      throw const FormatException('Home banner schedule must be UTC.');
    }
    return parsed.toUtc();
  }
}

class WalkaHomeBannerPayload {
  const WalkaHomeBannerPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.serverActive,
    required this.scheduleEvaluatedAt,
  });

  final WalkaHomeBannerContent content;
  final int revision;
  final DateTime publishedAt;
  final bool serverActive;
  final DateTime scheduleEvaluatedAt;

  factory WalkaHomeBannerPayload.fromApiJson(Map<String, dynamic> json) {
    final Object? dataValue = json['data'];
    final Object? metaValue = json['meta'];
    if (dataValue is! Map || metaValue is! Map) {
      throw const FormatException('Home banner API envelope is invalid.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    final Map<String, dynamic> meta = Map<String, dynamic>.from(metaValue);
    if (data['key'] != 'home.banner' || data['type'] != 'home.banner') {
      throw const FormatException('Unexpected Home banner content identity.');
    }
    if (data['schema_version'] != 1 || meta['api_version'] != 'v1') {
      throw const FormatException('Unsupported Home banner schema/API version.');
    }

    final Object? revisionValue = data['revision'];
    final Object? publishedValue = data['published_at'];
    final Object? payloadValue = data['payload'];
    final Object? serverActiveValue = meta['active'];
    final Object? evaluatedValue = meta['schedule_evaluated_at'];
    if (revisionValue is! int || revisionValue < 1 ||
        publishedValue is! String || payloadValue is! Map ||
        serverActiveValue is! bool || evaluatedValue is! String) {
      throw const FormatException('Home banner API metadata is invalid.');
    }

    final DateTime? publishedAt = DateTime.tryParse(publishedValue);
    final DateTime? evaluatedAt = DateTime.tryParse(evaluatedValue);
    if (publishedAt == null || evaluatedAt == null) {
      throw const FormatException('Home banner API timestamps are invalid.');
    }

    return WalkaHomeBannerPayload(
      content: WalkaHomeBannerContent.fromJson(
        Map<String, dynamic>.from(payloadValue),
      ),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
      serverActive: serverActiveValue,
      scheduleEvaluatedAt: evaluatedAt.toUtc(),
    );
  }
}

class WalkaHomeBannerSnapshot {
  const WalkaHomeBannerSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaHomeBannerContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaHomeBannerSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaHomeBannerSnapshot(
      content: WalkaHomeBannerContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaHomeBannerSnapshot asSource(WalkaContentSource source) {
    return WalkaHomeBannerSnapshot(
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

  factory WalkaHomeBannerSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Home banner cache schema.');
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
      throw const FormatException('Invalid Home banner cache snapshot.');
    }

    return WalkaHomeBannerSnapshot(
      content: WalkaHomeBannerContent.fromJson(
        Map<String, dynamic>.from(payload),
      ),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}
