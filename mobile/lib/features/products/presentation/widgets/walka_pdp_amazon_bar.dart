import 'package:flutter/material.dart';

import '../../../../design_system/walka_theme.dart';

class WalkaPdpAmazonBar extends StatelessWidget {
  const WalkaPdpAmazonBar({
    required this.selectedLabel,
    required this.onPressed,
    super.key,
  });

  final String selectedLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool compact = width < 350;
    final bool stack = width < 300 || MediaQuery.textScalerOf(context).scale(1) > 1.25;
    final Widget identity = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'SELECTED',
          style: TextStyle(
            color: WalkaColors.muted,
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          selectedLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
    final Widget button = ElevatedButton.icon(
      key: const ValueKey<String>('walka-pdp-buy-amazon'),
      onPressed: onPressed,
      icon: const Icon(Icons.open_in_new_rounded, size: 17),
      label: const Text('BUY ON AMAZON'),
    );

    return Material(
      key: const ValueKey<String>('walka-pdp-amazon-bar'),
      color: Colors.white,
      elevation: 14,
      shadowColor: WalkaColors.navy.withValues(alpha: 0.10),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 16, 10, compact ? 12 : 16, 10),
          child: stack
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    identity,
                    const SizedBox(height: 8),
                    button,
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(child: identity),
                    const SizedBox(width: 10),
                    SizedBox(width: compact ? 162 : 180, child: button),
                  ],
                ),
        ),
      ),
    );
  }
}
