import 'package:flutter/material.dart';

import 'walka_account_section.dart';

class WalkaAccountProductSupportGroup extends StatelessWidget {
  const WalkaAccountProductSupportGroup({
    required this.onFavorites,
    required this.onOurStory,
    required this.onFaq,
    required this.onContact,
    super.key,
  });

  final VoidCallback onFavorites;
  final VoidCallback onOurStory;
  final VoidCallback onFaq;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return WalkaAccountSection(
      title: 'Product & Support',
      children: <Widget>[
        WalkaAccountDestination(
          icon: Icons.favorite_border_rounded,
          title: 'Favorites',
          subtitle: 'Drawer Organizer variants saved on this device',
          onTap: onFavorites,
        ),
        WalkaAccountDestination(
          icon: Icons.auto_stories_outlined,
          title: 'Our Story',
          subtitle: 'Thoughtful organization, designed for daily life',
          onTap: onOurStory,
        ),
        WalkaAccountDestination(
          icon: Icons.help_outline_rounded,
          title: 'FAQ',
          subtitle: 'Verified product care, use and purchase guidance',
          onTap: onFaq,
        ),
        WalkaAccountDestination(
          icon: Icons.mail_outline_rounded,
          title: 'Contact Us',
          subtitle: 'WALKA product support and Amazon order routes',
          onTap: onContact,
        ),
      ],
    );
  }
}

class WalkaAccountOfficialDestinationsGroup extends StatelessWidget {
  const WalkaAccountOfficialDestinationsGroup({
    required this.onAmazonStore,
    required this.onSocial,
    super.key,
  });

  final VoidCallback onAmazonStore;
  final VoidCallback onSocial;

  @override
  Widget build(BuildContext context) {
    return WalkaAccountSection(
      title: 'Official Destinations',
      children: <Widget>[
        WalkaAccountDestination(
          icon: Icons.storefront_outlined,
          title: 'Amazon Store',
          subtitle: 'Official WALKA purchase destination',
          external: true,
          onTap: onAmazonStore,
        ),
        WalkaAccountDestination(
          icon: Icons.public_rounded,
          title: 'Follow WALKA',
          subtitle: 'Website and Instagram destinations',
          external: true,
          onTap: onSocial,
        ),
      ],
    );
  }
}

class WalkaAccountLegalAppGroup extends StatelessWidget {
  const WalkaAccountLegalAppGroup({
    required this.onPrivacy,
    required this.onTerms,
    required this.onAppInfo,
    super.key,
  });

  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onAppInfo;

  @override
  Widget build(BuildContext context) {
    return WalkaAccountSection(
      title: 'Legal & App',
      children: <Widget>[
        WalkaAccountDestination(
          icon: Icons.shield_outlined,
          title: 'Privacy',
          subtitle: 'Local Favorites, catalog behavior and handoffs',
          onTap: onPrivacy,
        ),
        WalkaAccountDestination(
          icon: Icons.description_outlined,
          title: 'Terms',
          subtitle: 'Discovery and marketplace boundaries',
          onTap: onTerms,
        ),
        WalkaAccountDestination(
          icon: Icons.info_outline_rounded,
          title: 'App Information',
          subtitle: 'Release, catalog and purchase-boundary details',
          onTap: onAppInfo,
        ),
      ],
    );
  }
}
