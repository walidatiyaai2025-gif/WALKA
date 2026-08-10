import 'package:flutter/material.dart';

import '../../../../../design_system/components/chrome/walka_reference_top_bar.dart';

class WalkaFavoritesHeader extends StatelessWidget {
  const WalkaFavoritesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaReferenceTopBar(
      headerKey: ValueKey<String>('reference-favorites-header'),
      leadingIcon: Icons.menu_rounded,
      trailingIcon: Icons.favorite_border_rounded,
    );
  }
}
