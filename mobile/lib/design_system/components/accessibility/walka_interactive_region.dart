import 'package:flutter/material.dart';

typedef WalkaInteractionBuilder = Widget Function(
  BuildContext context,
  WalkaInteractionState state,
);

class WalkaInteractionState {
  const WalkaInteractionState({
    required this.hovered,
    required this.focused,
  });

  final bool hovered;
  final bool focused;
}

/// Shared pointer/keyboard interaction contract for desktop-capable cards and
/// controls. Visual treatment is supplied by [builder] so feature widgets keep
/// their own appearance while behavior remains consistent.
class WalkaInteractiveRegion extends StatefulWidget {
  const WalkaInteractiveRegion({
    required this.builder,
    super.key,
    this.onActivate,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
  });

  final WalkaInteractionBuilder builder;
  final VoidCallback? onActivate;
  final String? semanticLabel;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<WalkaInteractiveRegion> createState() => _WalkaInteractiveRegionState();
}

class _WalkaInteractiveRegionState extends State<WalkaInteractiveRegion> {
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onActivate != null;

  void _activate() => widget.onActivate?.call();

  @override
  Widget build(BuildContext context) {
    final WalkaInteractionState state = WalkaInteractionState(
      hovered: _hovered,
      focused: _focused,
    );

    return Semantics(
      container: true,
      button: _enabled,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: _enabled ? _activate : null,
      child: FocusableActionDetector(
        enabled: _enabled,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowHoverHighlight: (bool value) {
          if (_hovered != value) setState(() => _hovered = value);
        },
        onShowFocusHighlight: (bool value) {
          if (_focused != value) setState(() => _focused = value);
        },
        actions: _enabled
            ? <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (ActivateIntent intent) {
                    _activate();
                    return null;
                  },
                ),
              }
            : const <Type, Action<Intent>>{},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _activate : null,
          child: widget.builder(context, state),
        ),
      ),
    );
  }
}
