import 'walka_mobile_content.dart';

class WalkaInformationCopyItem {
  const WalkaInformationCopyItem({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
      };
}

class WalkaFaqItem {
  const WalkaFaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  final String id;
  final String question;
  final String answer;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'question': question,
        'answer': answer,
      };
}

class WalkaAboutContent {
  const WalkaAboutContent({
    required this.heroEyebrow,
    required this.heroTitle,
    required this.heroBody,
    required this.storyEyebrow,
    required this.storyTitle,
    required this.storyBody,
    required this.valuesEyebrow,
    required this.values,
    required this.principlesEyebrow,
    required this.principlesTitle,
    required this.principles,
    required this.closingEyebrow,
    required this.closingTitle,
    required this.closingBody,
  });

  final String heroEyebrow;
  final String heroTitle;
  final String heroBody;
  final String storyEyebrow;
  final String storyTitle;
  final String storyBody;
  final String valuesEyebrow;
  final List<WalkaInformationCopyItem> values;
  final String principlesEyebrow;
  final String principlesTitle;
  final List<WalkaInformationCopyItem> principles;
  final String closingEyebrow;
  final String closingTitle;
  final String closingBody;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'hero_eyebrow': heroEyebrow,
        'hero_title': heroTitle,
        'hero_body': heroBody,
        'story_eyebrow': storyEyebrow,
        'story_title': storyTitle,
        'story_body': storyBody,
        'values_eyebrow': valuesEyebrow,
        'values': values.map((WalkaInformationCopyItem item) => item.toJson()).toList(growable: false),
        'principles_eyebrow': principlesEyebrow,
        'principles_title': principlesTitle,
        'principles': principles.map((WalkaInformationCopyItem item) => item.toJson()).toList(growable: false),
        'closing_eyebrow': closingEyebrow,
        'closing_title': closingTitle,
        'closing_body': closingBody,
      };
}

class WalkaFaqContent {
  const WalkaFaqContent({
    required this.eyebrow,
    required this.title,
    required this.intro,
    required this.items,
  });

  final String eyebrow;
  final String title;
  final String intro;
  final List<WalkaFaqItem> items;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'eyebrow': eyebrow,
        'title': title,
        'intro': intro,
        'items': items.map((WalkaFaqItem item) => item.toJson()).toList(growable: false),
      };
}

class WalkaSupportContent {
  const WalkaSupportContent({
    required this.eyebrow,
    required this.title,
    required this.intro,
    required this.amazonOrderTitle,
    required this.amazonOrderBody,
    required this.supportEmail,
    required this.emailTitle,
    required this.emailBody,
    required this.websiteTitle,
    required this.websiteBody,
    required this.instagramTitle,
    required this.instagramBody,
  });

  final String eyebrow;
  final String title;
  final String intro;
  final String amazonOrderTitle;
  final String amazonOrderBody;
  final String supportEmail;
  final String emailTitle;
  final String emailBody;
  final String websiteTitle;
  final String websiteBody;
  final String instagramTitle;
  final String instagramBody;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'eyebrow': eyebrow,
        'title': title,
        'intro': intro,
        'amazon_order_title': amazonOrderTitle,
        'amazon_order_body': amazonOrderBody,
        'support_email': supportEmail,
        'email_title': emailTitle,
        'email_body': emailBody,
        'website_title': websiteTitle,
        'website_body': websiteBody,
        'instagram_title': instagramTitle,
        'instagram_body': instagramBody,
      };
}

class WalkaLegalDocumentContent {
  const WalkaLegalDocumentContent({
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<WalkaInformationCopyItem> sections;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'intro': intro,
        'sections': sections.map((WalkaInformationCopyItem item) => item.toJson()).toList(growable: false),
      };
}

class WalkaLegalContent {
  const WalkaLegalContent({
    required this.eyebrow,
    required this.privacy,
    required this.terms,
    required this.reviewNoticeTitle,
    required this.reviewNoticeBody,
  });

  final String eyebrow;
  final WalkaLegalDocumentContent privacy;
  final WalkaLegalDocumentContent terms;
  final String reviewNoticeTitle;
  final String reviewNoticeBody;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'eyebrow': eyebrow,
        'privacy': privacy.toJson(),
        'terms': terms.toJson(),
        'review_notice_title': reviewNoticeTitle,
        'review_notice_body': reviewNoticeBody,
      };
}

class WalkaInformationContent {
  const WalkaInformationContent({
    required this.about,
    required this.faq,
    required this.support,
    required this.legal,
  });

  static const WalkaInformationContent bundled = WalkaInformationContent(
    about: WalkaAboutContent(
      heroEyebrow: 'OUR STORY',
      heroTitle: 'Organized living.\nElevated everyday.',
      heroBody: 'Thoughtful organization essentials that make everyday spaces easier to use and calmer to look at.',
      storyEyebrow: 'OUR POINT OF VIEW',
      storyTitle: 'A calmer home begins with thoughtful details.',
      storyBody: 'WALKA creates organization essentials that balance practical function with a refined visual language. We believe useful objects should make everyday spaces easier to live with and quieter to look at.',
      valuesEyebrow: 'WHAT GUIDES US',
      values: <WalkaInformationCopyItem>[
        WalkaInformationCopyItem(id: 'purposeful', title: 'Purposeful', body: 'Useful details first, unnecessary complexity removed.'),
        WalkaInformationCopyItem(id: 'refined', title: 'Refined', body: 'Clean proportions and restrained visual language.'),
        WalkaInformationCopyItem(id: 'everyday', title: 'Everyday', body: 'Designed to support routines again and again.'),
      ],
      principlesEyebrow: 'HOW WE DESIGN',
      principlesTitle: 'Simple choices, made deliberately.',
      principles: <WalkaInformationCopyItem>[
        WalkaInformationCopyItem(id: 'useful-first', title: 'Useful first', body: 'Every WALKA product starts with the routine it needs to improve, then removes unnecessary complexity.'),
        WalkaInformationCopyItem(id: 'calm-by-design', title: 'Calm by design', body: 'Clean proportions, restrained color and considered details help products sit naturally in the home.'),
        WalkaInformationCopyItem(id: 'made-for-repetition', title: 'Made for repetition', body: 'The best organization products quietly support everyday habits and remain easy to use again and again.'),
      ],
      closingEyebrow: 'WALKA',
      closingTitle: 'Thoughtful pieces for a better organized everyday.',
      closingBody: 'Explore the current collection in the app. When you are ready to purchase, WALKA sends you to the official Amazon listing.',
    ),
    faq: WalkaFaqContent(
      eyebrow: 'VERIFIED PRODUCT HELP',
      title: 'Frequently Asked Questions',
      intro: 'These answers follow the WALKA Product Master used by the release UI and regression tests.',
      items: <WalkaFaqItem>[
        WalkaFaqItem(id: 'lunch-leakproof', question: 'Is the lunch box leakproof?', answer: 'WALKA does not make a full leakproof claim. Secure Lock helps prevent spills. Use the lunch box for dry & semi-wet foods, not liquids, and carry it upright.'),
        WalkaFaqItem(id: 'lunch-materials', question: 'What is the lunch box made from?', answer: 'Food sits in a SUS304 stainless-steel tray. The outer body is food-grade PP. The lid uses four clips with a silicone gasket.'),
        WalkaFaqItem(id: 'lunch-dishwasher', question: 'What can go in the dishwasher?', answer: 'The SUS304 stainless-steel tray is dishwasher safe. The lid and silicone gasket are dishwasher safe on the top rack.'),
        WalkaFaqItem(id: 'lunch-microwave', question: 'What can go in the microwave?', answer: 'The stainless-steel tray, lid and silicone gasket are not microwave safe. Microwave only the PP outer body after removing all three.'),
        WalkaFaqItem(id: 'lunch-included', question: 'What comes with the lunch box?', answer: 'The set includes the lunch box, insulated carry bag, stainless sauce cup with lid, spoon and fork.'),
        WalkaFaqItem(id: 'drawer-width', question: 'How wide does the drawer organizer expand?', answer: 'The organizer is 13 × 15 × 2 inches when closed and expands up to 22.4 inches wide. It has eight compartments and a non-slip base.'),
        WalkaFaqItem(id: 'purchase-location', question: 'Where do I purchase WALKA products?', answer: 'Product purchase buttons open the selected official WALKA listing on Amazon. The app does not run an in-app cart, checkout or payment flow.'),
      ],
    ),
    support: WalkaSupportContent(
      eyebrow: 'SUPPORT',
      title: 'Contact Us',
      intro: 'Choose the route that matches your question. Marketplace order, delivery, return and payment support remains with Amazon.',
      amazonOrderTitle: 'Amazon order support',
      amazonOrderBody: 'Use your Amazon account for an existing marketplace order so the request stays connected to the correct transaction.',
      supportEmail: 'support@walkastore.com',
      emailTitle: 'Email WALKA',
      emailBody: 'Brand and product support from WALKA.',
      websiteTitle: 'WALKA website',
      websiteBody: 'Brand and product information at walkastore.com.',
      instagramTitle: 'Instagram',
      instagramBody: 'Follow @walkabrands for WALKA product and brand updates.',
    ),
    legal: WalkaLegalContent(
      eyebrow: 'LEGAL PRESENTATION',
      privacy: WalkaLegalDocumentContent(
        title: 'Privacy',
        intro: 'Current app behavior before backend integration.',
        sections: <WalkaInformationCopyItem>[
          WalkaInformationCopyItem(id: 'favorites', title: 'Favorites', body: 'Drawer Organizer favorites are stored locally on this device in the current release.'),
          WalkaInformationCopyItem(id: 'search', title: 'Search', body: 'Current product search runs locally in Flutter and is not connected to a remote WALKA search service.'),
          WalkaInformationCopyItem(id: 'external-purchase', title: 'External purchase', body: 'Buy on Amazon opens Amazon externally. Amazon handles marketplace account, order and payment data under its own policies.'),
        ],
      ),
      terms: WalkaLegalDocumentContent(
        title: 'Terms',
        intro: 'Current product-discovery and marketplace boundaries.',
        sections: <WalkaInformationCopyItem>[
          WalkaInformationCopyItem(id: 'product-discovery', title: 'Product discovery', body: 'WALKA presents product information and discovery. Marketplace price, availability, delivery and final transaction terms are determined on Amazon.'),
          WalkaInformationCopyItem(id: 'product-guidance', title: 'Product guidance', body: 'Use products according to the verified care and usage guidance shown in the app and applicable marketplace listing.'),
          WalkaInformationCopyItem(id: 'external-destinations', title: 'External destinations', body: 'Amazon, WALKA web and social links open services outside this app and subject to their respective terms.'),
        ],
      ),
      reviewNoticeTitle: 'Legal review required before store publication',
      reviewNoticeBody: 'This is the visual presentation layer. Final jurisdiction-specific legal wording should be reviewed before public production release.',
    ),
  );

  final WalkaAboutContent about;
  final WalkaFaqContent faq;
  final WalkaSupportContent support;
  final WalkaLegalContent legal;

  factory WalkaInformationContent.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> about = _requiredMap(json, 'about');
    final Map<String, dynamic> faq = _requiredMap(json, 'faq');
    final Map<String, dynamic> support = _requiredMap(json, 'support');
    final Map<String, dynamic> legal = _requiredMap(json, 'legal');

    return WalkaInformationContent(
      about: _parseAbout(about),
      faq: _parseFaq(faq),
      support: _parseSupport(support),
      legal: _parseLegal(legal),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'about': about.toJson(),
        'faq': faq.toJson(),
        'support': support.toJson(),
        'legal': legal.toJson(),
      };
}

class WalkaInformationPayload {
  const WalkaInformationPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaInformationContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaInformationPayload.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _requiredMap(json, 'data');
    if (data['key'] != 'information' || data['type'] != 'information') {
      throw const FormatException('Unexpected WALKA information identity.');
    }
    if (data['schema_version'] != 1) {
      throw const FormatException('Unsupported WALKA information schema.');
    }
    final Object? revisionValue = data['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Information revision must be positive.');
    }
    final Object? publishedValue = data['published_at'];
    if (publishedValue is! String || publishedValue.trim().isEmpty) {
      throw const FormatException('Information published_at is required.');
    }
    final DateTime? publishedAt = DateTime.tryParse(publishedValue);
    if (publishedAt == null) {
      throw const FormatException('Information published_at is invalid.');
    }
    final Map<String, dynamic> meta = _requiredMap(json, 'meta');
    if (meta['api_version'] != 'v1') {
      throw const FormatException('Unsupported WALKA information API version.');
    }

    return WalkaInformationPayload(
      content: WalkaInformationContent.fromJson(_requiredMap(data, 'payload')),
      revision: revisionValue,
      publishedAt: publishedAt.toUtc(),
    );
  }
}

class WalkaInformationSnapshot {
  const WalkaInformationSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaInformationContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaInformationSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaInformationSnapshot(
      content: WalkaInformationContent.bundled,
      revision: 0,
      publishedAt: null,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaContentSource.bundled,
    );
  }

  WalkaInformationSnapshot asSource(WalkaContentSource nextSource) {
    return WalkaInformationSnapshot(
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

  factory WalkaInformationSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported Information cache schema.');
    }
    final Object? revisionValue = json['revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Cached Information revision is invalid.');
    }
    final DateTime? publishedAt = json['published_at'] is String
        ? DateTime.tryParse(json['published_at'] as String)?.toUtc()
        : null;
    final DateTime? fetchedAt = json['fetched_at'] is String
        ? DateTime.tryParse(json['fetched_at'] as String)?.toUtc()
        : null;
    if (publishedAt == null || fetchedAt == null) {
      throw const FormatException('Cached Information timestamps are invalid.');
    }

    return WalkaInformationSnapshot(
      content: WalkaInformationContent.fromJson(_requiredMap(json, 'payload')),
      revision: revisionValue,
      publishedAt: publishedAt,
      fetchedAt: fetchedAt,
      source: WalkaContentSource.cache,
    );
  }
}

WalkaAboutContent _parseAbout(Map<String, dynamic> json) {
  return WalkaAboutContent(
    heroEyebrow: _text(json, 'hero_eyebrow'),
    heroTitle: _text(json, 'hero_title'),
    heroBody: _text(json, 'hero_body'),
    storyEyebrow: _text(json, 'story_eyebrow'),
    storyTitle: _text(json, 'story_title'),
    storyBody: _text(json, 'story_body'),
    valuesEyebrow: _text(json, 'values_eyebrow'),
    values: _fixedCopyItems(json, 'values', const <String>['purposeful', 'refined', 'everyday']),
    principlesEyebrow: _text(json, 'principles_eyebrow'),
    principlesTitle: _text(json, 'principles_title'),
    principles: _fixedCopyItems(json, 'principles', const <String>['useful-first', 'calm-by-design', 'made-for-repetition']),
    closingEyebrow: _text(json, 'closing_eyebrow'),
    closingTitle: _text(json, 'closing_title'),
    closingBody: _text(json, 'closing_body'),
  );
}

WalkaFaqContent _parseFaq(Map<String, dynamic> json) {
  final List<dynamic> raw = _requiredList(json, 'items');
  if (raw.isEmpty || raw.length > 12) {
    throw const FormatException('FAQ must contain between 1 and 12 items.');
  }
  final Set<String> seen = <String>{};
  final List<WalkaFaqItem> items = <WalkaFaqItem>[];
  for (final Object? value in raw) {
    if (value is! Map) throw const FormatException('FAQ item must be an object.');
    final Map<String, dynamic> item = Map<String, dynamic>.from(value);
    final String id = _stableId(item, 'id');
    if (!seen.add(id)) throw FormatException('Duplicate FAQ ID: $id');
    items.add(WalkaFaqItem(id: id, question: _text(item, 'question'), answer: _text(item, 'answer')));
  }
  return WalkaFaqContent(
    eyebrow: _text(json, 'eyebrow'),
    title: _text(json, 'title'),
    intro: _text(json, 'intro'),
    items: List<WalkaFaqItem>.unmodifiable(items),
  );
}

WalkaSupportContent _parseSupport(Map<String, dynamic> json) {
  final String email = _text(json, 'support_email').toLowerCase();
  if (!RegExp(r'^[^@\s]+@walkastore\.com$').hasMatch(email)) {
    throw const FormatException('Support email must use the walkastore.com domain.');
  }
  return WalkaSupportContent(
    eyebrow: _text(json, 'eyebrow'),
    title: _text(json, 'title'),
    intro: _text(json, 'intro'),
    amazonOrderTitle: _text(json, 'amazon_order_title'),
    amazonOrderBody: _text(json, 'amazon_order_body'),
    supportEmail: email,
    emailTitle: _text(json, 'email_title'),
    emailBody: _text(json, 'email_body'),
    websiteTitle: _text(json, 'website_title'),
    websiteBody: _text(json, 'website_body'),
    instagramTitle: _text(json, 'instagram_title'),
    instagramBody: _text(json, 'instagram_body'),
  );
}

WalkaLegalContent _parseLegal(Map<String, dynamic> json) {
  return WalkaLegalContent(
    eyebrow: _text(json, 'eyebrow'),
    privacy: _parseLegalDocument(_requiredMap(json, 'privacy')),
    terms: _parseLegalDocument(_requiredMap(json, 'terms')),
    reviewNoticeTitle: _text(json, 'review_notice_title'),
    reviewNoticeBody: _text(json, 'review_notice_body'),
  );
}

WalkaLegalDocumentContent _parseLegalDocument(Map<String, dynamic> json) {
  final List<dynamic> raw = _requiredList(json, 'sections');
  if (raw.isEmpty || raw.length > 8) {
    throw const FormatException('Legal document must contain between 1 and 8 sections.');
  }
  final Set<String> seen = <String>{};
  final List<WalkaInformationCopyItem> sections = <WalkaInformationCopyItem>[];
  for (final Object? value in raw) {
    if (value is! Map) throw const FormatException('Legal section must be an object.');
    final Map<String, dynamic> item = Map<String, dynamic>.from(value);
    final String id = _stableId(item, 'id');
    if (!seen.add(id)) throw FormatException('Duplicate legal section ID: $id');
    sections.add(WalkaInformationCopyItem(id: id, title: _text(item, 'title'), body: _text(item, 'body')));
  }
  return WalkaLegalDocumentContent(
    title: _text(json, 'title'),
    intro: _text(json, 'intro'),
    sections: List<WalkaInformationCopyItem>.unmodifiable(sections),
  );
}

List<WalkaInformationCopyItem> _fixedCopyItems(
  Map<String, dynamic> json,
  String key,
  List<String> expectedIds,
) {
  final List<dynamic> raw = _requiredList(json, key);
  if (raw.length != expectedIds.length) {
    throw FormatException('$key must contain the released stable item set.');
  }
  final Set<String> seen = <String>{};
  final List<WalkaInformationCopyItem> items = <WalkaInformationCopyItem>[];
  for (final Object? value in raw) {
    if (value is! Map) throw FormatException('$key item must be an object.');
    final Map<String, dynamic> item = Map<String, dynamic>.from(value);
    final String id = _stableId(item, 'id');
    if (!expectedIds.contains(id) || !seen.add(id)) {
      throw FormatException('$key contains an unknown or duplicate stable ID.');
    }
    items.add(WalkaInformationCopyItem(id: id, title: _text(item, 'title'), body: _text(item, 'body')));
  }
  if (!seen.containsAll(expectedIds)) {
    throw FormatException('$key is missing a released stable ID.');
  }
  return List<WalkaInformationCopyItem>.unmodifiable(items);
}

String _text(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be non-empty text.');
  }
  return value.trim();
}

String _stableId(Map<String, dynamic> json, String key) {
  final String value = _text(json, key);
  if (!RegExp(r'^[a-z0-9][a-z0-9-]{0,63}$').hasMatch(value)) {
    throw FormatException('$key must be a stable lowercase ID.');
  }
  return value;
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! Map) throw FormatException('$key must be an object.');
  return Map<String, dynamic>.from(value);
}

List<dynamic> _requiredList(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! List) throw FormatException('$key must be a list.');
  return List<dynamic>.from(value);
}
