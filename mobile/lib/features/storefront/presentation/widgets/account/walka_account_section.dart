import 'package:flutter/material.dart';

import 'package:walka/design_system/components/cards/walka_destination_tile.dart';
import 'package:walka/design_system/components/typography/walka_divider_label.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaAccountSection extends StatelessWidget {
  const WalkaAccountSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        WalkaDividerLabel(label: title),
        const SizedBox(height: 12),
        Column(
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              children[i],
              if (i != children.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class WalkaAccountDestination extends StatelessWidget {
  const WalkaAccountDestination({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.external = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool external;

  @override
  Widget build(BuildContext context) {
    return WalkaDestinationTile(
      key: ValueKey<String>(
        'reference-account-${title.toLowerCase().replaceAll(' ', '-')}',
      ),
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: Icon(
        external ? Icons.north_east_rounded : Icons.chevron_right_rounded,
        color: WalkaColors.muted,
        size: 20,
      ),
    );
  }
}
