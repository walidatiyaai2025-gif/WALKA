import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/walka_theme.dart';
import '../lifestyle/lifestyle_v4.dart' show WalkaAboutV4;

const String _amazonStoreUrl =
    'https://www.amazon.com/stores/walkabrand/page/97D69007-E4C8-4FC1-8EBB-45C24A1FEB7C';
const String _instagramUrl = 'https://www.instagram.com/walkabrands/';
const String _websiteUrl = 'https://walkastore.com';

class WalkaAccountV100 extends StatelessWidget {
  const WalkaAccountV100({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _Wordmark(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _AccountHero(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _AccountSection(
                eyebrow: 'DISCOVER WALKA',
                children: <Widget>[
                  _AccountRow(
                    icon: Icons.auto_stories_outlined,
                    title: 'Our Story',
                    subtitle: 'The thinking behind calmer everyday organization.',
                    onTap: () => _push(context, const WalkaAboutV4()),
                  ),
                  _AccountRow(
                    icon: Icons.storefront_outlined,
                    title: 'Amazon Store',
                    subtitle: 'Explore the official WALKA storefront on Amazon.',
                    onTap: () => _push(context, const WalkaAmazonStoreV100()),
                  ),
                  _AccountRow(
                    icon: Icons.public_rounded,
                    title: 'Follow WALKA',
                    subtitle: 'Website, Instagram and the latest brand edit.',
                    onTap: () => _push(context, const WalkaSocialV100()),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: _AccountSection(
                eyebrow: 'HELP & SUPPORT',
                children: <Widget>[
                  _AccountRow(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQ',
                    subtitle: 'Product care, materials, use and purchasing.',
                    onTap: () => _push(context, const WalkaFaqV100()),
                  ),
                  _AccountRow(
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact Us',
                    subtitle: 'Find the right support route for your question.',
                    onTap: () => _push(context, const WalkaContactV100()),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              child: _AccountSection(
                eyebrow: 'LEGAL & APP',
                children: <Widget>[
                  _AccountRow(
                    icon: Icons.shield_outlined,
                    title: 'Privacy',
                    subtitle: 'How this app is designed to handle your data.',
                    onTap: () => _push(
                      context,
                      const WalkaLegalV100(type: WalkaLegalType.privacy),
                    ),
                  ),
                  _AccountRow(
                    icon: Icons.description_outlined,
                    title: 'Terms',
                    subtitle: 'Important information about using WALKA.',
                    onTap: () => _push(
                      context,
                      const WalkaLegalV100(type: WalkaLegalType.terms),
                    ),
                  ),
                  _AccountRow(
                    icon: Icons.info_outline_rounded,
                    title: 'App Information',
                    subtitle: 'Version, purchase model and release details.',
                    onTap: () => _push(context, const WalkaAppInfoV100()),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 42)),
        ],
      ),
    );
  }
}

class WalkaContactV100 extends StatelessWidget {
  const WalkaContactV100({super.key});

  @override
  Widget build(BuildContext context) {
    return _InformationScaffold(
      title: 'Contact Us',
      eyebrow: 'SUPPORT',
      intro:
          'Choose the route that best matches your question. Product purchasing and Amazon order support remain on Amazon.',
      children: <Widget>[
        const _ContactCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Amazon order support',
          body:
              'For order status, delivery, returns or marketplace payments, continue through your Amazon account so the order remains securely connected to Amazon.',
          badge: 'AMAZON ORDER',
        ),
        const SizedBox(height: 12),
        _LinkCard(
          icon: Icons.language_rounded,
          title: 'WALKA website',
          body: 'Visit the WALKA website for brand and product information.',
          buttonLabel: 'OPEN WEBSITE',
          onTap: () => _openExternal(context, Uri.parse(_websiteUrl)),
        ),
        const SizedBox(height: 12),
        _LinkCard(
          icon: Icons.camera_alt_outlined,
          title: 'Instagram',
          body: 'Follow @walkabrands for product stories and brand updates.',
          buttonLabel: 'OPEN INSTAGRAM',
          onTap: () => _openExternal(context, Uri.parse(_instagramUrl)),
        ),
        const SizedBox(height: 24),
        const _EditorialNote(
          title: 'Before you contact support',
          body:
              'For lunch-box questions, remember that the product is best for dry & semi-wet foods, is not intended for liquids, and should be carried upright.',
        ),
      ],
    );
  }
}

class WalkaFaqV100 extends StatelessWidget {
  const WalkaFaqV100({super.key});

  @override
  Widget build(BuildContext context) {
    return _InformationScaffold(
      title: 'Frequently Asked Questions',
      eyebrow: 'HELP',
      intro:
          'Clear answers for the two WALKA collections currently available in the app.',
      children: const <Widget>[
        _FaqTile(
          question: 'Is the lunch box leakproof?',
          answer:
              'The secure-lock design helps prevent spills, but the lunch box is not intended for liquids. It is best for dry & semi-wet foods and should be carried upright.',
        ),
        _FaqTile(
          question: 'What is the lunch tray made from?',
          answer:
              'Food sits in a SUS304 stainless-steel tray. The outer body is PP, with a silicone gasket in the lid.',
        ),
        _FaqTile(
          question: 'Can the lunch box go in a microwave?',
          answer:
              'Remove the stainless-steel tray before microwaving. The stainless tray is not microwave safe.',
        ),
        _FaqTile(
          question: 'How should I wash the lunch box?',
          answer:
              'The stainless tray can go on the dishwasher top rack. Hand wash the lid and gasket.',
        ),
        _FaqTile(
          question: 'How wide does the drawer organizer expand?',
          answer:
              'The organizer starts at 13 inches wide and expands to approximately 22.4 inches.',
        ),
        _FaqTile(
          question: 'Where do I purchase WALKA products?',
          answer:
              'Product purchase buttons open the selected WALKA listing on Amazon. WALKA does not run an in-app cart or checkout.',
        ),
      ],
    );
  }
}

enum WalkaLegalType { privacy, terms }

class WalkaLegalV100 extends StatelessWidget {
  const WalkaLegalV100({required this.type, super.key});

  final WalkaLegalType type;

  @override
  Widget build(BuildContext context) {
    final bool privacy = type == WalkaLegalType.privacy;
    return _InformationScaffold(
      title: privacy ? 'Privacy' : 'Terms',
      eyebrow: 'LEGAL',
      intro: privacy
          ? 'A clear product-facing presentation of how the current WALKA app prototype is designed to use device data.'
          : 'A product-facing presentation of the current WALKA app experience and purchase model.',
      children: privacy
          ? const <Widget>[
              _LegalSection(
                number: '01',
                title: 'Current app data',
                body:
                    'Favorites are stored locally on your device. The current app does not require an account and does not send Favorites to a WALKA backend.',
              ),
              _LegalSection(
                number: '02',
                title: 'Purchasing',
                body:
                    'When you choose Buy on Amazon, the app opens Amazon externally. Amazon then handles its own account, order and payment data under Amazon’s policies.',
              ),
              _LegalSection(
                number: '03',
                title: 'Search',
                body:
                    'Search and recent-search suggestions in the current release run locally in the Flutter experience and are not connected to a remote search service.',
              ),
              _LegalReviewNotice(),
            ]
          : const <Widget>[
              _LegalSection(
                number: '01',
                title: 'Product discovery',
                body:
                    'WALKA provides product information and discovery screens. Product availability, marketplace price, delivery and final transaction terms are determined on Amazon.',
              ),
              _LegalSection(
                number: '02',
                title: 'Product guidance',
                body:
                    'Use products according to the care and usage guidance shown in the app and on the applicable marketplace listing.',
              ),
              _LegalSection(
                number: '03',
                title: 'External destinations',
                body:
                    'Links to Amazon, the WALKA website or social platforms open services operated outside this app and subject to their respective terms.',
              ),
              _LegalReviewNotice(),
            ],
    );
  }
}

class WalkaAmazonStoreV100 extends StatelessWidget {
  const WalkaAmazonStoreV100({super.key});

  @override
  Widget build(BuildContext context) {
    return _InformationScaffold(
      title: 'Amazon Store',
      eyebrow: 'SHOP WALKA',
      intro:
          'WALKA uses Amazon as the purchase destination. Discover in the app, then complete the transaction on Amazon.',
      children: <Widget>[
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: WalkaColors.navy,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            children: <Widget>[
              const Positioned(
                left: 22,
                top: 22,
                child: Text(
                  'WALKA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 5.2,
                  ),
                ),
              ),
              const Positioned(
                left: 22,
                top: 68,
                child: SizedBox(
                  width: 210,
                  child: Text(
                    'The official WALKA collection on Amazon.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 29,
                      height: 1.05,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -24,
                bottom: 24,
                child: Transform.rotate(
                  angle: -0.07,
                  child: Container(
                    width: 165,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7894A5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'WALKA',
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 150,
                bottom: 22,
                child: ElevatedButton.icon(
                  onPressed: () => _openExternal(
                    context,
                    Uri.parse(_amazonStoreUrl),
                  ),
                  icon: const Icon(Icons.north_east_rounded, size: 17),
                  label: const Text('OPEN AMAZON STORE'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _EditorialNote(
          title: 'Why Amazon?',
          body:
              'The app keeps discovery focused and premium while Amazon handles marketplace availability, account, delivery, returns and payment checkout.',
        ),
      ],
    );
  }
}

class WalkaSocialV100 extends StatelessWidget {
  const WalkaSocialV100({super.key});

  @override
  Widget build(BuildContext context) {
    return _InformationScaffold(
      title: 'Follow WALKA',
      eyebrow: 'STAY CONNECTED',
      intro:
          'Continue the brand experience beyond the app through the official WALKA destinations.',
      children: <Widget>[
        _LinkCard(
          icon: Icons.camera_alt_outlined,
          title: '@walkabrands',
          body: 'Product details, organization inspiration and WALKA updates.',
          buttonLabel: 'OPEN INSTAGRAM',
          onTap: () => _openExternal(context, Uri.parse(_instagramUrl)),
        ),
        const SizedBox(height: 12),
        _LinkCard(
          icon: Icons.language_rounded,
          title: 'walkastore.com',
          body: 'Visit the WALKA web destination.',
          buttonLabel: 'OPEN WEBSITE',
          onTap: () => _openExternal(context, Uri.parse(_websiteUrl)),
        ),
        const SizedBox(height: 12),
        _LinkCard(
          icon: Icons.storefront_outlined,
          title: 'WALKA on Amazon',
          body: 'Browse the official Amazon brand storefront.',
          buttonLabel: 'OPEN AMAZON',
          onTap: () => _openExternal(context, Uri.parse(_amazonStoreUrl)),
        ),
      ],
    );
  }
}

class WalkaAppInfoV100 extends StatelessWidget {
  const WalkaAppInfoV100({super.key});

  @override
  Widget build(BuildContext context) {
    return _InformationScaffold(
      title: 'App Information',
      eyebrow: 'WALKA MOBILE',
      intro:
          'The first complete visual-freeze release of the WALKA mobile storefront.',
      children: const <Widget>[
        _InfoMetric(label: 'Version', value: '1.0.0'),
        _InfoMetric(label: 'Platform', value: 'Flutter · Android / iOS'),
        _InfoMetric(label: 'Purchase model', value: 'Amazon handoff'),
        _InfoMetric(label: 'Favorites', value: 'Stored on device'),
        _InfoMetric(label: 'Current catalog', value: '5 sellable variants'),
        SizedBox(height: 24),
        _EditorialNote(
          title: 'Visual freeze',
          body:
              'Version 1.0.0 is the design baseline used before Laravel/API integration. Functional backend work should extend this experience rather than redesign it.',
        ),
      ],
    );
  }
}

Future<void> _openExternal(BuildContext context, Uri uri) async {
  final bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!context.mounted || opened) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('This destination could not be opened.')),
  );
}

class _InformationScaffold extends StatelessWidget {
  const _InformationScaffold({
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          children: <Widget>[
            Text(eyebrow, style: WalkaType.eyebrow),
            const SizedBox(height: 9),
            Text(title, style: WalkaType.sectionTitle),
            const SizedBox(height: 11),
            Text(intro, style: WalkaType.body),
            const SizedBox(height: 28),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('WALKA MOBILE', style: WalkaType.eyebrow),
          Spacer(),
          Text(
            'Everything WALKA,\nin one calm place.',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 31,
              height: 1.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Products, support, story and official destinations.',
            style: TextStyle(
              color: Color(0xFFC8D4DF),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.eyebrow, required this.children});
  final String eyebrow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
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
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: WalkaColors.surface,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: WalkaColors.navy, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: WalkaColors.muted,
            fontSize: 10,
            height: 1.35,
          ),
        ),
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
        title: Text(
          question,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: <Widget>[Text(answer, style: WalkaType.body)],
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
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 44,
            child: Text(
              number,
              style: const TextStyle(
                color: WalkaColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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

class _LegalReviewNotice extends StatelessWidget {
  const _LegalReviewNotice();

  @override
  Widget build(BuildContext context) {
    return const _EditorialNote(
      title: 'Legal review required before store publication',
      body:
          'This screen is the approved UI presentation layer. Final jurisdiction-specific legal wording should be reviewed and supplied before public production release.',
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.badge,
  });
  final IconData icon;
  final String title;
  final String body;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: WalkaColors.gold, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: WalkaColors.surface,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  title,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String body;
  final String buttonLabel;
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
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(body, style: WalkaType.body),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.north_east_rounded, size: 16),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({required this.label, required this.value});
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
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: WalkaColors.muted, fontSize: 11),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialNote extends StatelessWidget {
  const _EditorialNote({required this.title, required this.body});
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(body, style: WalkaType.body),
        ],
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
