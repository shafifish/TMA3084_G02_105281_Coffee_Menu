import 'package:coffee_menu/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('menu shows drinks and cart count goes up', (tester) async {
    await tester.pumpWidget(const CoffeeShopApp());

    expect(find.text('Brew & Bean Cafe'), findsOneWidget);
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
