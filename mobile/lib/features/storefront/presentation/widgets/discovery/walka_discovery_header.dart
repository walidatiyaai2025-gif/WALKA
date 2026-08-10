import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaDiscoveryHeader extends StatelessWidget {
  const WalkaDiscoveryHeader({
    required this.trailingIcon,
    required this.trailingTooltip,
    super.key,
    this.onTrailing,
  });

  final IconData trailingIcon;
  final String trailingTooltip;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-discovery-header'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: WalkaColors.line, width: 0.7)),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.menu_rounded, color: WalkaColors.navy),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'WALKA',
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: onTrailing == null
                ? Icon(trailingIcon, color: WalkaColors.navy)
                : IconButton(
                    key: const ValueKey<String>('reference-discovery-trailing'),
                    onPressed: onTrailing,
                    tooltip: trailingTooltip,
                    icon: Icon(trailingIcon, color: WalkaColors.navy),
                  ),
          ),
        ],
      ),
    );
  }
}
