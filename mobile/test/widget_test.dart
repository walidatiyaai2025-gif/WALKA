import 'package:flutter_test/flutter_test.dart';
import 'package:walka/main.dart';

void main() {
  testWidgets('WALKA splash enters the navigable shell', (WidgetTester tester) async {
    await tester.pumpWidget(const WalkaApp());

    expect(find.text('WALKA'), findsOneWidget);
    expect(find.text('EXPLORE WALKA'), findsOneWidget);

    await tester.tap(find.text('EXPLORE WALKA'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Beautifully organized. Effortlessly yours.'), findsOneWidget);
  });
}
