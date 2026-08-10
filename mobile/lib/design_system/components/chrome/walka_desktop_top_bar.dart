import 'package:flutter/material.dart';

import '../../walka_shell.dart';
import '../../walka_theme.dart';

/// Reusable desktop header chrome for PC reference compositions.
///
/// Feature routes stay caller-owned through the [navigation] and [actions]
/// slots. Ordered traversal keeps keyboard focus deterministic left-to-right.
class WalkaDesktopTopBar extends StatelessWidget {
  const WalkaDesktopTopBar({
    super.key,
    this.navigation = const <Widget>[],
    this.actions = const <Widget>[],
    this.leading,
  });

  static const double minHeight = 72;

  final Widget? leading;
  final List<Widget> navigation;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.white,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: WalkaColors.line, width: 1),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WalkaSpacing.xl,
                vertical: WalkaSpacing.sm,
              ),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Row(
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      leading!,
                      const SizedBox(width: WalkaSpacing.md),
                    ],
                    const WalkaWordmark(compact: true, showDescriptor: false),
                    const Spacer(),
                    if (navigation.isNotEmpty)
                      Wrap(
                        spacing: WalkaSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: navigation,
                      ),
                    if (navigation.isNotEmpty && actions.isNotEmpty)
                      const SizedBox(width: WalkaSpacing.lg),
                    ...actions,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
