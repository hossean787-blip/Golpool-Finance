import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/main.dart';
import 'package:golpool/secure_finance_store.dart';

class TestStore extends SecureFinanceStore {
 @override Future<Map<String,dynamic>?> load() async => null;
 @override Future<void> save(Map<String,dynamic> data) async {}
}


void main() {
 testWidgets('Persian navigation and approved design sections', (tester) async {
  await tester.pumpWidget(Golpool(store:TestStore()));
  await tester.pump(const Duration(seconds:1));
  expect(find.text('گل‌پول 🌸'), findsNothing);
  expect(find.text('خرج امروز'), findsOneWidget);
  expect(find.text('حساب‌های من'), findsOneWidget);
  await tester.tap(find.descendant(of:find.byType(NavigationBar),matching:find.byIcon(Icons.pie_chart_outline)));
  await tester.pump(const Duration(seconds:1));
  expect(find.text('نمای کلی بودجه ماه'), findsOneWidget);
  await tester.tap(find.descendant(of:find.byType(NavigationBar),matching:find.byIcon(Icons.favorite_outline)));
  await tester.pump(const Duration(seconds:1));
  expect(find.text('هدف‌ها'), findsWidgets);
 });
 testWidgets('All five finance tabs render within a compact phone viewport',(tester)async{
   tester.view.physicalSize=const Size(390,844);
   tester.view.devicePixelRatio=1;
   addTearDown(tester.view.resetPhysicalSize);
   addTearDown(tester.view.resetDevicePixelRatio);
   await tester.pumpWidget(Golpool(store:TestStore()));
   await tester.pump(const Duration(seconds:1));
   expect(find.text('حساب‌های من'),findsOneWidget);
   await tester.tap(find.byIcon(Icons.receipt_long_outlined));
   await tester.pump(const Duration(seconds:1));
   expect(find.text('جست‌وجوی تراکنش‌ها'),findsOneWidget);
   await tester.tap(find.descendant(of:find.byType(NavigationBar),matching:find.byIcon(Icons.pie_chart_outline)));
   await tester.pump(const Duration(seconds:1));
   expect(find.text('نمای کلی بودجه ماه'),findsOneWidget);
   await tester.tap(find.descendant(of:find.byType(NavigationBar),matching:find.byIcon(Icons.favorite_outline)));
   await tester.pump(const Duration(seconds:1));
   expect(find.text('هدف‌های پس‌انداز'),findsOneWidget);
   await tester.tap(find.byIcon(Icons.menu));
   await tester.pump(const Duration(seconds:1));
   expect(find.text('کارت‌های بانکی'),findsOneWidget);
 });

}
