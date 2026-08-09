import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/main.dart';
import 'package:walka/screens/walka_screens.dart';

void main() {
  testWidgets('WALKA splash renders the brand entry state', (WidgetTester tester) async {
    await tester.pumpWidget(const WalkaApp());

    expect(find.text('WALKA'), findsOneWidget);
    expect(find.text('EXPLORE WALKA'), findsOneWidget);
    expect(find.text('PREMIUM HOME ORGANIZATION'), findsOneWidget);
  });

  testWidgets('WALKA shell exposes primary navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const WalkaShell(),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Beautifully organized. Effortlessly yours.'), findsOneWidget);
  });
}
