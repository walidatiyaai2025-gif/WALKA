import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/buttons/walka_pill_chip.dart';
import 'package:walka/design_system/walka_theme.dart';

void main() {
  Widget app(Widget child) {
    return MaterialApp(
      theme: buildWalkaTheme(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders inactive and selected WALKA states',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(WalkaPillChip(label: 'Drawer', selected: false, onSelected: (_) {})),
    );

    FilterChip chip = tester.widget(find.byType(FilterChip));
    expect(chip.selected, isFalse);
    expect(chip.backgroundColor, WalkaColors.white);
    expect(chip.showCheckmark, isFalse);

    await tester.pumpWidget(
      app(WalkaPillChip(label: 'Drawer', selected: true, onSelected: (_) {})),
    );

    chip = tester.widget(find.byType(FilterChip));
    expect(chip.selected, isTrue);
    expect(chip.selectedColor, WalkaColors.navy);
  });

  testWidgets('announces selected state and invokes selection callback',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    addTearDown(handle.dispose);
    bool? value;

    await tester.pumpWidget(
      app(
        WalkaPillChip(
          label: 'Lunch',
          selected: true,
          onSelected: (bool selected) => value = selected,
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(WalkaPillChip)),
      matchesSemantics(
        label: 'Lunch',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.byType(FilterChip));
    await tester.pump();
    expect(value, isFalse);
  });

  testWidgets('disables FilterChip when requested', (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        WalkaPillChip(
          label: 'Unavailable',
          selected: false,
          enabled: false,
          onSelected: (_) {},
        ),
      ),
    );

    final FilterChip chip = tester.widget(find.byType(FilterChip));
    expect(chip.onSelected, isNull);
  });
}
