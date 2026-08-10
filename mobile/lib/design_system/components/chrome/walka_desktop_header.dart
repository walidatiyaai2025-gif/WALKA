import 'package:flutter/material.dart';

import '../../walka_theme.dart';
import 'walka_reference_top_bar.dart';

/// Desktop chrome for wide WALKA compositions.
///
/// The header deliberately owns only brand hierarchy, divider geometry and
/// optional action slots. Page-specific navigation/content remains caller-owned.
class WalkaDesktopHeader extends StatelessWidget {
  const WalkaDesktopHeader({
    super.key,
    this.leading,
    this.actions = const <Widget>[],
    this.subtitle = 'PREMIUM HOME ORGANIZATION',
  });

  final Widget? leading;
  final List<Widget> actions;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: WalkaColors.line,
              width: WalkaReferenceTopBar.dividerWidth,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WalkaSpacing.xl,
              vertical: WalkaSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: WalkaSpacing.lg),
                ],
                Expanded(
                  child: Semantics(
                    header: true,
                    label: 'WALKA premium home organization',
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'WALKA',
                            style: WalkaReferenceTopBar.wordmarkStyle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WalkaType.caption.copyWith(
                              color: WalkaColors.muted,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (actions.isNotEmpty) ...<Widget>[
                  const SizedBox(width: WalkaSpacing.lg),
                  Wrap(
                    spacing: WalkaSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
