import 'package:flutter/material.dart';

import 'package:walka/design_system/components/chrome/walka_reference_top_bar.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaAccountTopBar extends StatelessWidget {
  const WalkaAccountTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalkaReferenceTopBar(
      headerKey: ValueKey<String>('reference-account-topbar'),
      leadingIcon: Icons.menu_rounded,
      trailingIcon: Icons.person_outline_rounded,
      trailingColor: WalkaColors.gold,
    );
  }
}
