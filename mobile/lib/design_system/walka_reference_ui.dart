import 'package:flutter/material.dart';

import 'walka_theme.dart';

/// Shared visual contract for the Android-reference storefront surfaces.
///
/// Keeping these values here prevents Home, discovery, Favorites and Account
/// from drifting independently as the reference fidelity pass evolves.
abstract final class WalkaReferenceUi {
  static const Color pageBackground = WalkaColors.ivory;
  static const Color headerBackground = WalkaColors.white;
  static const double headerHorizontalPadding = 12;
  static const double headerVerticalPadding = 10;
  static const double headerSlotExtent = 48;
  static const double headerDividerWidth = 0.7;

  static const TextStyle wordmarkStyle = TextStyle(
    color: WalkaColors.navy,
    fontFamily: 'serif',
    fontSize: 27,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.8,
  );
}

/// Standard owner-visible reference viewport: warm WALKA background plus the
/// same SafeArea behavior on every primary storefront tab.
class WalkaReferenceViewport extends StatelessWidget {
  const WalkaReferenceViewport({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WalkaReferenceUi.pageBackground,
      child: SafeArea(bottom: false, child: child),
    );
  }
}

/// Shared top bar used by Home, Categories, Search, Favorites and Account.
///
/// A slot can be decorative (icon with no callback), interactive (icon +
/// callback), or empty. All variants keep a fixed 48dp slot so the WALKA
/// wordmark remains optically centered regardless of surrounding actions.
class WalkaReferenceHeader extends StatelessWidget {
  const WalkaReferenceHeader({
    this.headerKey,
    this.leadingIcon,
    this.leadingColor = WalkaColors.navy,
    this.leadingTooltip,
    this.leadingKey,
    this.onLeading,
    this.trailingIcon,
    this.trailingColor = WalkaColors.navy,
    this.trailingTooltip,
    this.trailingKey,
    this.onTrailing,
    super.key,
  });

  final Key? headerKey;
  final IconData? leadingIcon;
  final Color leadingColor;
  final String? leadingTooltip;
  final Key? leadingKey;
  final VoidCallback? onLeading;
  final IconData? trailingIcon;
  final Color trailingColor;
  final String? trailingTooltip;
  final Key? trailingKey;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: headerKey,
      padding: const EdgeInsets.symmetric(
        horizontal: WalkaReferenceUi.headerHorizontalPadding,
        vertical: WalkaReferenceUi.headerVerticalPadding,
      ),
      decoration: const BoxDecoration(
        color: WalkaReferenceUi.headerBackground,
        border: Border(
          bottom: BorderSide(
            color: WalkaColors.line,
            width: WalkaReferenceUi.headerDividerWidth,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          _ReferenceHeaderSlot(
            icon: leadingIcon,
            color: leadingColor,
            tooltip: leadingTooltip,
            actionKey: leadingKey,
            onPressed: onLeading,
          ),
          const Expanded(
            child: Center(
              child: Text('WALKA', style: WalkaReferenceUi.wordmarkStyle),
            ),
          ),
          _ReferenceHeaderSlot(
            icon: trailingIcon,
            color: trailingColor,
            tooltip: trailingTooltip,
            actionKey: trailingKey,
            onPressed: onTrailing,
          ),
        ],
      ),
    );
  }
}

class _ReferenceHeaderSlot extends StatelessWidget {
  const _ReferenceHeaderSlot({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.actionKey,
    required this.onPressed,
  });

  final IconData? icon;
  final Color color;
  final String? tooltip;
  final Key? actionKey;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return const SizedBox.square(
        dimension: WalkaReferenceUi.headerSlotExtent,
      );
    }
    if (onPressed == null) {
      return SizedBox.square(
        dimension: WalkaReferenceUi.headerSlotExtent,
        child: Icon(icon, color: color),
      );
    }
    return SizedBox.square(
      dimension: WalkaReferenceUi.headerSlotExtent,
      child: IconButton(
        key: actionKey,
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: color),
      ),
    );
  }
}
