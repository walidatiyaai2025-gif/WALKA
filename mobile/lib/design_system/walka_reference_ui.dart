import 'package:flutter/material.dart';

import 'components/chrome/walka_reference_top_bar.dart';
import 'walka_theme.dart';

export 'components/chrome/walka_reference_top_bar.dart';

/// Shared visual contract for the Android-reference storefront surfaces.
///
/// Keeping these values here prevents Home, discovery, Favorites and Account
/// from drifting independently as the reference fidelity pass evolves.
abstract final class WalkaReferenceUi {
  static const Color pageBackground = WalkaColors.ivory;
  static const Color headerBackground = WalkaColors.white;
  static const double headerHorizontalPadding =
      WalkaReferenceTopBar.horizontalPadding;
  static const double headerVerticalPadding = WalkaReferenceTopBar.verticalPadding;
  static const double headerSlotExtent = WalkaReferenceTopBar.slotExtent;
  static const double headerExtent = WalkaReferenceTopBar.extent;
  static const double headerDividerWidth = WalkaReferenceTopBar.dividerWidth;

  static const TextStyle wordmarkStyle = WalkaReferenceTopBar.wordmarkStyle;
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

/// Compatibility wrapper retained for existing released screens.
///
/// New code should use [WalkaReferenceTopBar] directly. This wrapper preserves
/// the established constructor and delegates all rendering to the extracted
/// design-system component.
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
    return WalkaReferenceTopBar(
      headerKey: headerKey,
      leadingIcon: leadingIcon,
      leadingColor: leadingColor,
      leadingTooltip: leadingTooltip,
      leadingKey: leadingKey,
      onLeading: onLeading,
      trailingIcon: trailingIcon,
      trailingColor: trailingColor,
      trailingTooltip: trailingTooltip,
      trailingKey: trailingKey,
      onTrailing: onTrailing,
    );
  }
}
