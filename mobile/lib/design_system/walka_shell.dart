import 'package:flutter/material.dart';

import 'components/chrome/walka_shell_metrics.dart';
import 'walka_theme.dart';

export 'components/chrome/walka_shell_metrics.dart';
export 'components/navigation/walka_premium_navigation_bar.dart';
export 'components/navigation/walka_shell_destination.dart';
export 'components/splash/walka_splash_brand_mark.dart';
export 'components/splash/walka_splash_content.dart';

class WalkaWordmark extends StatelessWidget {
  const WalkaWordmark({
    super.key,
    this.onDark = false,
    this.compact = false,
    this.showDescriptor = true,
  });

  final bool onDark;
  final bool compact;
  final bool showDescriptor;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = onDark ? WalkaColors.white : WalkaColors.navy;
    final Color descriptorColor = onDark
        ? const Color(0xFFC9D4DF)
        : WalkaColors.muted;

    return Semantics(
      header: true,
      label: 'WALKA premium home organization',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'WALKA',
              style: TextStyle(
                color: titleColor,
                fontSize: compact ? 22 : 42,
                fontWeight: FontWeight.w900,
                letterSpacing: compact ? 5.2 : 8.2,
              ),
            ),
            if (showDescriptor) ...<Widget>[
              SizedBox(height: compact ? 3 : 14),
              Text(
                'PREMIUM HOME ORGANIZATION',
                style: TextStyle(
                  color: descriptorColor,
                  fontSize: compact ? 8 : 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: compact ? 1.35 : 2.1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WalkaShellIconButton extends StatelessWidget {
  const WalkaShellIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.white,
      shape: const CircleBorder(
        side: BorderSide(color: WalkaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 1,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(
          width: WalkaShellMetrics.minimumTouchTarget,
          height: WalkaShellMetrics.minimumTouchTarget,
        ),
        icon: Icon(icon, color: WalkaColors.navy, size: 21),
      ),
    );
  }
}
