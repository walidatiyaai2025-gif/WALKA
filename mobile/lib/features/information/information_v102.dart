import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/walka_theme.dart';
import '../lifestyle/lifestyle_v4.dart' show WalkaAboutV4;

const String _amazonStoreUrl =
    'https://www.amazon.com/stores/walkabrand/page/97D69007-E4C8-4FC1-8EBB-45C24A1FEB7C';
const String _instagramUrl = 'https://www.instagram.com/walkabrands/';
const String _websiteUrl = 'https://walkastore.com';

class WalkaAccountV102 extends StatelessWidget {
  const WalkaAccountV102({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
        children: <Widget>[
          const _Wordmark(),
          const SizedBox(height: 24),
          const Text('WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          const Text('Account & information', style: WalkaType.sectionTitle),
          const SizedBox(height: 9),
          const Text(
            'Brand story, verified product help, legal presentation and official WALKA destinations.',
            style: WalkaType.body,
          ),
          const SizedBox(height: 24),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.auto_stories_outlined,
                title: 'Our Story',
                subtitle: 'The thinking behind calmer everyday organization.',
                onTap: () => _push(context, const WalkaAboutV4()),
              ),
              _MenuRow(
                icon: Icons.help_outline_rounded,
                title: 'FAQ',
                subtitle: 'Verified product care, use and purchasing guidance.',
                onTap: () => _push(context, const WalkaFaqV102()),
              ),
              _MenuRow(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Us',
                subtitle: 'Support routes for WALKA and Amazon orders.',
                onTap: () => _push(context, const WalkaContactV102()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.storefront_outlined,
                title: 'Amazon Store',
                subtitle: 'Official WALKA purchase destination.',
                onTap: () => _push(context, const WalkaAmazonStoreV102()),
              ),
              _MenuRow(
                icon: Icons.public_rounded,
                title: 'Follow WALKA',
                subtitle: 'Website and Instagram destinations.',
                onTap: () => _push(context, const WalkaSocialV102()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MenuCard(
            children: <Widget>[
              _MenuRow(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                subtitle: 'Current local-data model and external handoffs.',
                onTap: () => _push(
                  context,
                  const WalkaLegalV102(type: WalkaLegalTypeV102.privacy),
                ),
              ),
              _MenuRow(
                icon: Icons.description_outlined,
                title: 'Terms',
                subtitle: 'Product discovery and marketplace boundaries.',
                onTap: () => _push(
                  context,
                  const WalkaLegalV102(type: WalkaLegalTypeV102.terms),
                ),
              ),
              _MenuRow(
                icon: Icons.info_outline_rounded,
                title: 'App Information',
                subtitle: 'WALKA visual freeze · version 1.0.0',
                onTap: () => _push(context, const WalkaAppInfoV102()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WalkaFaqV102 extends StatelessWidget {
  const WalkaFaqV102({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'Frequently Asked Questions',
      eyebrow: 'VERIFIED PRODUCT HELP',
      intro:
          'These answers follow the WALKA Product Master used by the release UI and regression tests.',
      children: <Widget>[
        _FaqTile(
          question: 'Is the lunch box leakproof?',
          answer:
              'WALKA does not make a full leakproof claim. Secure Lock helps prevent spills. Use the lunch box for dry & semi-wet foods, not liquids, and carry it upright.',
        ),
        _FaqTile(
          question: 'What is the lunch box made from?',
          answer:
              'Food sits in a SUS304 stainless-steel tray. The outer body is food-grade PP. The lid uses four clips with a silicone gasket.',
        ),
        _FaqTile(
          question: 'What can go in the dishwasher?',
          answer:
              'The SUS304 stainless-steel tray is dishwasher safe. The lid and silicone gasket are dishwasher safe on the top rack.',
        ),
        _FaqTile(
          question: 'What can go in the microwave?',
          answer:
              'The stainless-steel tray, lid and silicone gasket are not microwave safe. Microwave only the PP outer body after removing all three.',
        ),
        _FaqTile(
          question: 'What comes with the lunch box?',
          answer:
              'The set includes the lunch box, insulated carry bag, stainless sauce cup with lid, spoon and fork.',
        ),
        _FaqTile(
          question: 'How wide does the drawer organizer expand?',
          answer:
              'The organizer is 13 × 15 × 2 inches when closed and expands up to 22.4 inches wide. It has eight compartments and a non-slip base.',
        ),
        _FaqTile(
          question: 'Where do I purchase WALKA products?',
          answer:
              'Product purchase buttons open the selected official WALKA listing on Amazon. The app does not run an in-app cart, checkout or payment flow.',
        ),
      ],
    );
  }
}

class WalkaContactV102 extends StatelessWidget {
  const WalkaContactV102({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'Contact Us',
      eyebrow: 'SUPPORT',
      intro:
          'Choose the route that matches your question. Marketplace order, delivery, return and payment support remains with Amazon.',
      children: <Widget>[
        const _Notice(
          icon: Icons.shopping_bag_outlined,
          title: 'Amazon order support',
          body:
              'Use your Amazon account for an existing marketplace order so the request stays connected to the correct transaction.',
        ),
        const SizedBox(height: 12),
        _ExternalCard(
          icon: Icons.language_rounded,
          title: 'WALKA website',
          body: 'Brand and product information at walkastore.com.',
          label: 'OPEN WEBSITE',
          onTap: () => _openExternal(context, Uri.parse(_websiteUrl)),
        ),
        const SizedBox(height: 12),
        _ExternalCard(
          icon: Icons.camera_alt_outlined,
          title: 'Instagram',
          body: 'Follow @walkabrands for WALKA product and brand updates.',
          label: 'OPEN INSTAGRAM',
          onTap: () => _openExternal(context, Uri.parse(_instagramUrl)),
        ),
      ],
    );
  }
}

class WalkaAmazonStoreV102 extends StatelessWidget {
  const WalkaAmazonStoreV102({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'Amazon Store',
      eyebrow: 'SHOP WALKA',
      intro:
          'Discover products in WALKA, then continue to Amazon for marketplace availability and purchase.',
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: WalkaColors.navy,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('WALKA', style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
              )),
              const SizedBox(height: 18),
              const Text(
                'The official WALKA collection on Amazon.',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.08,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () => _openExternal(context, Uri.parse(_amazonStoreUrl)),
                icon: const Icon(Icons.north_east_rounded, size: 17),
                label: const Text('OPEN AMAZON STORE'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WalkaSocialV102 extends StatelessWidget {
  const WalkaSocialV102({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'Follow WALKA',
      eyebrow: 'OFFICIAL DESTINATIONS',
      intro: 'Continue the WALKA brand experience outside the app.',
      children: <Widget>[
        _ExternalCard(
          icon: Icons.camera_alt_outlined,
          title: '@walkabrands',
          body: 'Product stories and WALKA updates.',
          label: 'OPEN INSTAGRAM',
          onTap: () => _openExternal(context, Uri.parse(_instagramUrl)),
        ),
        const SizedBox(height: 12),
        _ExternalCard(
          icon: Icons.language_rounded,
          title: 'walkastore.com',
          body: 'Official WALKA web destination.',
          label: 'OPEN WEBSITE',
          onTap: () => _openExternal(context, Uri.parse(_websiteUrl)),
        ),
        const SizedBox(height: 12),
        _ExternalCard(
          icon: Icons.storefront_outlined,
          title: 'WALKA on Amazon',
          body: 'Official Amazon brand storefront.',
          label: 'OPEN AMAZON',
          onTap: () => _openExternal(context, Uri.parse(_amazonStoreUrl)),
        ),
      ],
    );
  }
}

enum WalkaLegalTypeV102 { privacy, terms }

class WalkaLegalV102 extends StatelessWidget {
  const WalkaLegalV102({required this.type, super.key});

  final WalkaLegalTypeV102 type;

  @override
  Widget build(BuildContext context) {
    final bool privacy = type == WalkaLegalTypeV102.privacy;
    return _InfoScaffold(
      title: privacy ? 'Privacy' : 'Terms',
      eyebrow: 'LEGAL PRESENTATION',
      intro: privacy
          ? 'Current app behavior before backend integration.'
          : 'Current product-discovery and marketplace boundaries.',
      children: <Widget>[
        if (privacy) ...const <Widget>[
          _LegalSection(
            number: '01',
            title: 'Favorites',
            body:
                'Drawer Organizer favorites are stored locally on this device in the current release.',
          ),
          _LegalSection(
            number: '02',
            title: 'Search',
            body:
                'Current product search runs locally in Flutter and is not connected to a remote WALKA search service.',
          ),
          _LegalSection(
            number: '03',
            title: 'External purchase',
            body:
                'Buy on Amazon opens Amazon externally. Amazon handles marketplace account, order and payment data under its own policies.',
          ),
        ] else ...const <Widget>[
          _LegalSection(
            number: '01',
            title: 'Product discovery',
            body:
                'WALKA presents product information and discovery. Marketplace price, availability, delivery and final transaction terms are determined on Amazon.',
          ),
          _LegalSection(
            number: '02',
            title: 'Product guidance',
            body:
                'Use products according to the verified care and usage guidance shown in the app and applicable marketplace listing.',
          ),
          _LegalSection(
            number: '03',
            title: 'External destinations',
            body:
                'Amazon, WALKA web and social links open services outside this app and subject to their respective terms.',
          ),
        ],
        const SizedBox(height: 8),
        const _Notice(
          icon: Icons.gavel_outlined,
          title: 'Legal review required before store publication',
          body:
              'This is the visual presentation layer. Final jurisdiction-specific legal wording should be reviewed before public production release.',
        ),
      ],
    );
  }
}

class WalkaAppInfoV102 extends StatelessWidget {
  const WalkaAppInfoV102({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InfoScaffold(
      title: 'App Information',
      eyebrow: 'WALKA MOBILE',
      intro: 'Design-first visual freeze before backend integration.',
      children: <Widget>[
        _Metric(label: 'Version', value: '1.0.0'),
        _Metric(label: 'Platform', value: 'Flutter · Android / iOS'),
        _Metric(label: 'Purchase model', value: 'Amazon handoff'),
        _Metric(label: 'Favorites', value: 'Stored on device'),
        _Metric(label: 'Current catalog', value: '5 sellable variants'),
        SizedBox(height: 22),
        _Notice(
          icon: Icons.verified_outlined,
          title: 'Visual freeze',
          body:
              '1.0.0 is the approved design baseline. Backend work should extend this experience rather than replace the completed visual architecture.',
        ),
      ],
    );
  }
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

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: WalkaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: WalkaColors.surface,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: WalkaColors.navy, size: 21),
      ),
      title: Text(title, style: const TextStyle(
        color: WalkaColors.navy,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      )),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(subtitle, style: const TextStyle(
          color: WalkaColors.muted,
          fontSize: 10,
          height: 1.35,
        )),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: WalkaColors.gold,
        size: 14,
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

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
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(question, style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        )),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[Text(answer, style: WalkaType.body)],
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: WalkaColors.gold, size: 25),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          )),
          const SizedBox(height: 7),
          Text(body, style: WalkaType.body),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.north_east_rounded, size: 16),
            label: Text(label),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.4)),
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
                Text(title, style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                )),
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

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 44,
            child: Text(number, style: const TextStyle(
              color: WalkaColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            )),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                )),
                const SizedBox(height: 7),
                Text(body, style: WalkaType.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: WalkaColors.line)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: const TextStyle(
            color: WalkaColors.muted,
            fontSize: 11,
          ))),
          const SizedBox(width: 20),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ))),
        ],
      ),
    );
  }
}
