import 'dart:async';

import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/content/domain/walka_home_banner_content.dart';

class WalkaScheduledHomeBanner extends StatefulWidget {
  const WalkaScheduledHomeBanner({
    required this.content,
    required this.onBrowse,
    required this.onSearch,
    required this.horizontalPadding,
    this.clock,
    super.key,
  });

  final WalkaHomeBannerContent content;
  final VoidCallback onBrowse;
  final VoidCallback onSearch;
  final double horizontalPadding;
  final DateTime Function()? clock;

  @override
  State<WalkaScheduledHomeBanner> createState() =>
      _WalkaScheduledHomeBannerState();
}

class _WalkaScheduledHomeBannerState extends State<WalkaScheduledHomeBanner> {
  Timer? _boundaryTimer;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _refreshSchedule();
  }

  @override
  void didUpdateWidget(covariant WalkaScheduledHomeBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.content, widget.content) ||
        oldWidget.clock != widget.clock) {
      _refreshSchedule();
    }
  }

  @override
  void dispose() {
    _boundaryTimer?.cancel();
    super.dispose();
  }

  DateTime _now() => (widget.clock?.call() ?? DateTime.now()).toUtc();

  void _refreshSchedule() {
    _boundaryTimer?.cancel();
    final DateTime now = _now();
    _active = widget.content.isActiveAt(now);

    if (!widget.content.enabled) return;

    final List<DateTime> futureBoundaries = <DateTime>[
      if (widget.content.startsAt != null && widget.content.startsAt!.isAfter(now))
        widget.content.startsAt!,
      if (widget.content.endsAt != null && widget.content.endsAt!.isAfter(now))
        widget.content.endsAt!,
    ]..sort();
    if (futureBoundaries.isEmpty) return;

    final Duration untilBoundary = futureBoundaries.first.difference(now);
    _boundaryTimer = Timer(untilBoundary + const Duration(milliseconds: 25), () {
      if (!mounted) return;
      setState(_refreshSchedule);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) {
      return const SizedBox.shrink(key: ValueKey<String>('home-banner-inactive'));
    }

    return Padding(
      key: const ValueKey<String>('home-banner-active'),
      padding: EdgeInsets.fromLTRB(
        widget.horizontalPadding,
        10,
        widget.horizontalPadding,
        0,
      ),
      child: WalkaHomeBanner(
        content: widget.content,
        onBrowse: widget.onBrowse,
        onSearch: widget.onSearch,
      ),
    );
  }
}

class WalkaHomeBanner extends StatelessWidget {
  const WalkaHomeBanner({
    required this.content,
    required this.onBrowse,
    required this.onSearch,
    super.key,
  });

  final WalkaHomeBannerContent content;
  final VoidCallback onBrowse;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = switch (content.ctaAction) {
      WalkaHomeBannerAction.none => null,
      WalkaHomeBannerAction.browse => onBrowse,
      WalkaHomeBannerAction.search => onSearch,
    };

    return Semantics(
      container: true,
      label: '${content.eyebrow}. ${content.title}. ${content.body}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WalkaColors.navy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 460 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.15;
              final Widget copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    content.eyebrow,
                    style: const TextStyle(
                      color: WalkaColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 20,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content.body,
                    style: const TextStyle(
                      color: Color(0xFFDCE5EC),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              );

              final Widget? cta = action == null
                  ? null
                  : TextButton.icon(
                      key: const ValueKey<String>('home-banner-cta'),
                      onPressed: action,
                      style: TextButton.styleFrom(
                        foregroundColor: WalkaColors.gold,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        content.ctaLabel!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    copy,
                    if (cta != null) ...<Widget>[
                      const SizedBox(height: 5),
                      Align(alignment: Alignment.centerLeft, child: cta),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: copy),
                  if (cta != null) ...<Widget>[
                    const SizedBox(width: 14),
                    cta,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
