import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/main.dart';

void main() {
 testWidgets('Persian navigation and approved design sections', (tester) async {
  await tester.pumpWidget(const Golpool());
  expect(find.text('گل‌پول 🌸'), findsNothing);
  expect(find.text('خرج امروز'), findsOneWidget);
  expect(find.text('حساب‌های من'), findsOneWidget);
  await tester.tap(find.byIcon(Icons.pie_chart_outline));
  await tester.pumpAndSettle();
  expect(find.text('خوراک'), findsWidgets);
  await tester.tap(find.byIcon(Icons.favorite_outline));
  await tester.pumpAndSettle();
  expect(find.text('هدف‌های من'), findsOneWidget);
 });
}
