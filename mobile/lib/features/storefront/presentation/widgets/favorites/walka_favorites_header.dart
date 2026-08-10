import 'package:flutter/material.dart';

import '../../../../../design_system/components/chrome/walka_reference_top_bar.dart';
import '../../../../../design_system/walka_theme.dart';

class WalkaFavoritesHeader extends StatelessWidget {
  const WalkaFavoritesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaReferenceTopBar(
      headerKey: ValueKey<String>('reference-favorites-topbar'),
      trailingIcon: Icons.favorite_rounded,
      trailingColor: WalkaColors.gold,
    );
  }
}
