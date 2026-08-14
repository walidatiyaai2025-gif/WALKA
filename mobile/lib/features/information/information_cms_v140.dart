import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/walka_theme.dart';
import '../content/content_state.dart';
import '../content/domain/walka_information_content.dart';

const String _instagramUrl = 'https://www.instagram.com/walkabrands/';
const String _websiteUrl = 'https://walkastore.com';

enum WalkaLegalTypeCmsV140 { privacy, terms }

class WalkaFaqCmsV140 extends StatelessWidget {
  const WalkaFaqCmsV140({super.key});

  @override
  Widget build(BuildContext context) {
    final WalkaFaqContent faq = _information(context).faq;
    return _InfoScaffold(
      title: faq.title,
      eyebrow: faq.eyebrow,
      intro: faq.intro,
      children: faq.items
          .map(
            (WalkaFaqItem item) => _FaqTile(
              key: ValueKey<String>('cms-faq-${item.id}'),
              question: item.question,
              answer: item.answer,
            ),
          )
          .toList(growable: false),
    );
  }
}

class WalkaContactCmsV140 extends StatelessWidget {
  const WalkaContactCmsV140({super.key});

  @override
  Widget build(BuildContext context) {
    final WalkaSupportContent support = _information(context).support;
    return _InfoScaffold(
      title: support.title,
      eyebrow: support.eyebrow,
      intro: support.intro,
      children: <Widget>[
        _Notice(
          icon: Icons.shopping_bag_outlined,
          title: support.amazonOrderTitle,
          body: support.amazonOrderBody,
        ),
        const SizedBox(height: 12),
        _ExternalCard(
          key: const ValueKey<String>('cms-support-email'),
          icon: Icons.mail_outline_rounded,
          title: support.emailTitle,
          body: '${support.emailBody}\n${support.supportEmail}',
          label: 'EMAIL WALKA',
          onTap: () => _openExternal(
            context,
            Uri(scheme: 'mailto', path: support.supportEmail),
          ),
        ),
        const SizedBox(height: 12),
        _ExternalCard(
          key: const ValueKey<String>('cms-support-website'),
          icon: Icons.language_rounded,
          title: support.websiteTitle,
          body: support.websiteBody,
          label: 'OPEN WEBSITE',
          onTap: () => _openExternal(context, Uri.parse(_websiteUrl)),
        ),
        const SizedBox(height: 12),
        _ExternalCard(
          key: const ValueKey<String>('cms-support-instagram'),
          icon: Icons.camera_alt_outlined,
          title: support.instagramTitle,
          body: support.instagramBody,
          label: 'OPEN INSTAGRAM',
          onTap: () => _openExternal(context, Uri.parse(_instagramUrl)),
        ),
      ],
    );
  }
}

class WalkaLegalCmsV140 extends StatelessWidget {
  const WalkaLegalCmsV140({required this.type, super.key});

  final WalkaLegalTypeCmsV140 type;

  @override
  Widget build(BuildContext context) {
    final WalkaLegalContent legal = _information(context).legal;
    final WalkaLegalDocumentContent document =
        type == WalkaLegalTypeCmsV140.privacy ? legal.privacy : legal.terms;

    return _InfoScaffold(
      title: document.title,
      eyebrow: legal.eyebrow,
      intro: document.intro,
      children: <Widget>[
        ...document.sections.indexed.map(
          ((int, WalkaInformationCopyItem) entry) => _LegalSection(
            key: ValueKey<String>('cms-legal-${entry.$2.id}'),
            number: (entry.$1 + 1).toString().padLeft(2, '0'),
            title: entry.$2.title,
            body: entry.$2.body,
          ),
        ),
        const SizedBox(height: 8),
        _Notice(
          key: const ValueKey<String>('cms-legal-review-notice'),
          icon: Icons.gavel_outlined,
          title: legal.reviewNoticeTitle,
          body: legal.reviewNoticeBody,
        ),
      ],
    );
  }
}

WalkaInformationContent _information(BuildContext context) {
  return WalkaContentScope.maybeOf(context)?.information.content ??
      WalkaInformationContent.bundled;
}

Future<void> _openExternal(BuildContext context, Uri uri) async {
  bool opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }

  if (!context.mounted || opened) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('This destination could not be opened.')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _Wordmark()),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 42),
          children: <Widget>[
            Text(eyebrow, style: WalkaType.eyebrow),
            const SizedBox(height: 8),
            Text(title, style: WalkaType.sectionTitle),
            const SizedBox(height: 10),
            Text(intro, style: WalkaType.body),
            const SizedBox(height: 26),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WALKA',
      style: TextStyle(
        color: WalkaColors.navy,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.8,
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer, super.key});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        title: Text(
          question,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: WalkaType.body),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: WalkaColors.gold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(body, style: WalkaType.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalCard extends StatelessWidget {
  const _ExternalCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: WalkaColors.navy, size: 22),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: WalkaType.cardTitle),
                const SizedBox(height: 5),
                Text(body, style: WalkaType.body),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onTap,
                  child: Text(label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.number,
    required this.title,
    required this.body,
    super.key,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 38,
            child: Text(
              number,
              style: const TextStyle(
                color: WalkaColors.gold,
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: WalkaType.cardTitle),
                const SizedBox(height: 6),
                Text(body, style: WalkaType.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
