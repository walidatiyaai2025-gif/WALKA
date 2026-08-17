import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/walka_theme.dart';
import '../content/content_state.dart';
import '../content/domain/walka_mobile_content.dart';
import '../content/domain/walka_storefront_copy_content.dart';

class WalkaAccountV102 extends StatelessWidget {
  const WalkaAccountV102({super.key});

  @override
  Widget build(BuildContext context) {
    final _InformationData? data = _publishedInformation(context);
    if (data == null) return const _InformationUnavailable();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
        children: <Widget>[
          Text(data.account.eyebrow, style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          Text(data.account.title, style: WalkaType.sectionTitle),
          const SizedBox(height: 9),
          Text(data.account.body, style: WalkaType.body),
          const SizedBox(height: 24),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.auto_stories_outlined,
                title: data.story.title,
                onTap: () => _push(context, const WalkaStoryV102()),
              ),
              _MenuRow(
                icon: Icons.help_outline_rounded,
                title: data.faq.title,
                onTap: () => _push(context, const WalkaFaqV102()),
              ),
              _MenuRow(
                icon: Icons.mail_outline_rounded,
                title: data.contact.title,
                onTap: () => _push(context, const WalkaContactV102()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.storefront_outlined,
                title: data.amazonStore.title,
                onTap: () => _push(context, const WalkaAmazonStoreV102()),
              ),
              _MenuRow(
                icon: Icons.public_rounded,
                title: data.social.title,
                onTap: () => _push(context, const WalkaSocialV102()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.shield_outlined,
                title: data.privacy.title,
                onTap: () => _push(
                  context,
                  const WalkaLegalV102(type: WalkaLegalTypeV102.privacy),
                ),
              ),
              _MenuRow(
                icon: Icons.description_outlined,
                title: data.terms.title,
                onTap: () => _push(
                  context,
                  const WalkaLegalV102(type: WalkaLegalTypeV102.terms),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalkaStoryV102 extends StatelessWidget {
  const WalkaStoryV102({super.key});

  @override
  Widget build(BuildContext context) {
    final _TextPage? page = _publishedInformation(context)?.story;
    if (page == null) return const _InformationUnavailable();
    return _InfoScaffold(
      title: page.title,
      eyebrow: page.eyebrow,
      intro: page.body,
      children: const <Widget>[],
    );
  }
}

class WalkaFaqV102 extends StatelessWidget {
  const WalkaFaqV102({super.key});

  @override
  Widget build(BuildContext context) {
    final _FaqPage? page = _publishedInformation(context)?.faq;
    if (page == null) return const _InformationUnavailable();
    return _InfoScaffold(
      title: page.title,
      eyebrow: page.eyebrow,
      intro: page.intro,
      children: page.items
          .map(
            (_FaqItem item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                title: Text(
                  item.question,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(item.answer, style: WalkaType.body),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class WalkaContactV102 extends StatelessWidget {
  const WalkaContactV102({super.key});

  @override
  Widget build(BuildContext context) {
    final _LinksPage? page = _publishedInformation(context)?.contact;
    if (page == null) return const _InformationUnavailable();
    return _LinksScaffold(page: page);
  }
}

class WalkaAmazonStoreV102 extends StatelessWidget {
  const WalkaAmazonStoreV102({super.key});

  @override
  Widget build(BuildContext context) {
    final _ActionPage? page = _publishedInformation(context)?.amazonStore;
    if (page == null) return const _InformationUnavailable();
    return _InfoScaffold(
      title: page.title,
      eyebrow: page.eyebrow,
      intro: page.body,
      children: <Widget>[
        FilledButton.icon(
          onPressed: () => _openExternal(context, page.url),
          icon: const Icon(Icons.north_east_rounded),
          label: Text(page.label),
        ),
      ],
    );
  }
}

class WalkaSocialV102 extends StatelessWidget {
  const WalkaSocialV102({super.key});

  @override
  Widget build(BuildContext context) {
    final _LinksPage? page = _publishedInformation(context)?.social;
    if (page == null) return const _InformationUnavailable();
    return _LinksScaffold(page: page);
  }
}

enum WalkaLegalTypeV102 { privacy, terms }

class WalkaLegalV102 extends StatelessWidget {
  const WalkaLegalV102({required this.type, super.key});

  final WalkaLegalTypeV102 type;

  @override
  Widget build(BuildContext context) {
    final _InformationData? data = _publishedInformation(context);
    final _LegalPage? page = type == WalkaLegalTypeV102.terms
        ? data?.terms
        : data?.privacy;
    if (page == null) return const _InformationUnavailable();
    return _InfoScaffold(
      title: page.title,
      eyebrow: page.eyebrow,
      intro: page.intro,
      children: page.sections
          .map(
            (_LegalSectionData section) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    section.title,
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(section.body, style: WalkaType.body),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _LinksScaffold extends StatelessWidget {
  const _LinksScaffold({required this.page});
  final _LinksPage page;

  @override
  Widget build(BuildContext context) => _InfoScaffold(
        title: page.title,
        eyebrow: page.eyebrow,
        intro: page.intro,
        children: page.links
            .map(
              (_ExternalLink link) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          link.title,
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(link.body, style: WalkaType.body),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => _openExternal(context, link.url),
                          icon: const Icon(Icons.north_east_rounded, size: 17),
                          label: Text(link.label),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      );
}

class _InfoScaffold extends StatelessWidget {
  const _InfoScaffold({
    required this.title,
    required this.eyebrow,
    required this.intro,
    required this.children,
  });

  final String title;
  final String eyebrow;
  final String intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: WalkaColors.ivory,
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 42),
          children: <Widget>[
            Text(eyebrow, style: WalkaType.eyebrow),
            const SizedBox(height: 8),
            Text(title, style: WalkaType.sectionTitle),
            const SizedBox(height: 9),
            Text(intro, style: WalkaType.body),
            if (children.isNotEmpty) const SizedBox(height: 24),
            ...children,
          ],
        ),
      );
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Column(children: children),
      );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}

class _InformationUnavailable extends StatelessWidget {
  const _InformationUnavailable();

  @override
  Widget build(BuildContext context) {
    final WalkaContentController? content = WalkaContentScope.maybeOf(context);
    return Scaffold(
      backgroundColor: WalkaColors.ivory,
      body: Center(
        child: content?.isLoading == true
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: WalkaColors.muted,
              ),
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}

Future<void> _openExternal(BuildContext context, Uri uri) async {
  final bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Icon(Icons.link_off_rounded)),
    );
  }
}

_InformationData? _publishedInformation(BuildContext context) {
  final WalkaContentController? controller = WalkaContentScope.maybeOf(context);
  if (controller == null) return null;
  final WalkaStorefrontCopySnapshot snapshot = controller.storefrontCopy;
  if (snapshot.source != WalkaContentSource.remote &&
      snapshot.source != WalkaContentSource.cache) {
    return null;
  }
  try {
    return _InformationData.fromJsonString(snapshot.content.informationJson);
  } on Object {
    return null;
  }
}

class _InformationData {
  const _InformationData({
    required this.account,
    required this.story,
    required this.faq,
    required this.contact,
    required this.amazonStore,
    required this.social,
    required this.privacy,
    required this.terms,
  });

  final _AccountPage account;
  final _TextPage story;
  final _FaqPage faq;
  final _LinksPage contact;
  final _ActionPage amazonStore;
  final _LinksPage social;
  final _LegalPage privacy;
  final _LegalPage terms;

  factory _InformationData.fromJsonString(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map) throw const FormatException('Invalid information.');
    final Map<String, dynamic> json = Map<String, dynamic>.from(decoded);
    return _InformationData(
      account: _AccountPage.fromJson(_map(json, 'account')),
      story: _TextPage.fromJson(_map(json, 'story')),
      faq: _FaqPage.fromJson(_map(json, 'faq')),
      contact: _LinksPage.fromJson(_map(json, 'contact')),
      amazonStore: _ActionPage.fromJson(_map(json, 'amazon_store')),
      social: _LinksPage.fromJson(_map(json, 'social')),
      privacy: _LegalPage.fromJson(_map(json, 'privacy')),
      terms: _LegalPage.fromJson(_map(json, 'terms')),
    );
  }
}

class _AccountPage {
  const _AccountPage({
    required this.eyebrow,
    required this.title,
    required this.body,
  });
  final String eyebrow;
  final String title;
  final String body;

  factory _AccountPage.fromJson(Map<String, dynamic> json) => _AccountPage(
        eyebrow: _string(json, 'eyebrow'),
        title: _string(json, 'title'),
        body: _string(json, 'body'),
      );
}

class _TextPage {
  const _TextPage({
    required this.title,
    required this.eyebrow,
    required this.body,
  });
  final String title;
  final String eyebrow;
  final String body;

  factory _TextPage.fromJson(Map<String, dynamic> json) => _TextPage(
        title: _string(json, 'title'),
        eyebrow: _string(json, 'eyebrow'),
        body: _string(json, 'body'),
      );
}

class _FaqPage {
  const _FaqPage({
    required this.title,
    required this.eyebrow,
    required this.intro,
    required this.items,
  });
  final String title;
  final String eyebrow;
  final String intro;
  final List<_FaqItem> items;

  factory _FaqPage.fromJson(Map<String, dynamic> json) => _FaqPage(
        title: _string(json, 'title'),
        eyebrow: _string(json, 'eyebrow'),
        intro: _string(json, 'intro'),
        items: _list(json, 'items')
            .map((Object item) => _FaqItem.fromJson(_asMap(item)))
            .toList(growable: false),
      );
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  factory _FaqItem.fromJson(Map<String, dynamic> json) => _FaqItem(
        question: _string(json, 'question'),
        answer: _string(json, 'answer'),
      );
}

class _LinksPage {
  const _LinksPage({
    required this.title,
    required this.eyebrow,
    required this.intro,
    required this.links,
  });
  final String title;
  final String eyebrow;
  final String intro;
  final List<_ExternalLink> links;

  factory _LinksPage.fromJson(Map<String, dynamic> json) => _LinksPage(
        title: _string(json, 'title'),
        eyebrow: _string(json, 'eyebrow'),
        intro: _string(json, 'intro'),
        links: _list(json, 'links')
            .map((Object item) => _ExternalLink.fromJson(_asMap(item)))
            .toList(growable: false),
      );
}

class _ExternalLink {
  const _ExternalLink({
    required this.title,
    required this.body,
    required this.label,
    required this.url,
  });
  final String title;
  final String body;
  final String label;
  final Uri url;

  factory _ExternalLink.fromJson(Map<String, dynamic> json) => _ExternalLink(
        title: _string(json, 'title'),
        body: _string(json, 'body'),
        label: _string(json, 'label'),
        url: _httpsUri(json, 'url'),
      );
}

class _ActionPage {
  const _ActionPage({
    required this.title,
    required this.eyebrow,
    required this.body,
    required this.label,
    required this.url,
  });
  final String title;
  final String eyebrow;
  final String body;
  final String label;
  final Uri url;

  factory _ActionPage.fromJson(Map<String, dynamic> json) => _ActionPage(
        title: _string(json, 'title'),
        eyebrow: _string(json, 'eyebrow'),
        body: _string(json, 'body'),
        label: _string(json, 'label'),
        url: _httpsUri(json, 'url'),
      );
}

class _LegalPage {
  const _LegalPage({
    required this.title,
    required this.eyebrow,
    required this.intro,
    required this.sections,
  });
  final String title;
  final String eyebrow;
  final String intro;
  final List<_LegalSectionData> sections;

  factory _LegalPage.fromJson(Map<String, dynamic> json) => _LegalPage(
        title: _string(json, 'title'),
        eyebrow: _string(json, 'eyebrow'),
        intro: _string(json, 'intro'),
        sections: _list(json, 'sections')
            .map((Object item) => _LegalSectionData.fromJson(_asMap(item)))
            .toList(growable: false),
      );
}

class _LegalSectionData {
  const _LegalSectionData({required this.title, required this.body});
  final String title;
  final String body;

  factory _LegalSectionData.fromJson(Map<String, dynamic> json) =>
      _LegalSectionData(
        title: _string(json, 'title'),
        body: _string(json, 'body'),
      );
}

Map<String, dynamic> _map(Map<String, dynamic> json, String key) =>
    _asMap(json[key]);

Map<String, dynamic> _asMap(Object? value) {
  if (value is! Map) throw const FormatException('Expected object.');
  return Map<String, dynamic>.from(value);
}

List<Object> _list(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! List || value.isEmpty) throw FormatException('Invalid $key.');
  return List<Object>.from(value);
}

String _string(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Invalid $key.');
  }
  return value.trim();
}

Uri _httpsUri(Map<String, dynamic> json, String key) {
  final Uri? uri = Uri.tryParse(_string(json, key));
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    throw FormatException('Invalid $key.');
  }
  return uri;
}
