import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/storefront/storefront_v102.dart';

void main() {
  testWidgets('branded splash survives compact phone and 1.3x text scale',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.3),
        ),
        child: MaterialApp(
          theme: buildWalkaTheme(),
          home: const WalkaStorefrontSplashV102(),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('WALKA For You'), findsOneWidget);
    expect(find.text('Thoughtful pieces.\nBeautifully organized.'), findsOneWidget);
    expect(find.text('ENTER WALKA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
