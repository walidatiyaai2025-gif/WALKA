import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_reference_ui.dart';

class WalkaHomeHeader extends StatelessWidget {
  const WalkaHomeHeader({
    required this.onBrowse,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onBrowse;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return WalkaReferenceHeader(
      headerKey: const ValueKey<String>('home-reference-header'),
      leadingIcon: Icons.menu_rounded,
      leadingTooltip: 'Browse categories',
      leadingKey: const ValueKey<String>('home-reference-browse'),
      onLeading: onBrowse,
      trailingIcon: Icons.search_rounded,
      trailingTooltip: 'Search WALKA',
      trailingKey: const ValueKey<String>('home-reference-search'),
      onTrailing: onSearch,
    );
  }
}
