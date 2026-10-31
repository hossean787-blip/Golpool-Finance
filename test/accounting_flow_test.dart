import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/finance.dart';

void main(){
 test('Opening balances, expense, income, transfers remain separated',(){
   final rows=<Map<String,dynamic>>[
     {'type':'expense','date':'2026-10-31','amount':120,'account':'A'},
     {'type':'income','date':'2026-10-31','amount':200,'account':'B'},
     {'type':'transfer','date':'2026-10-31','amount':300,'from':'A','to':'B'},
   ];
   final balances=<String,int>{'A':1000,'B':500};
   expect(MoneyMath.accountBalance('A',balances,rows),580);
   expect(MoneyMath.accountBalance('B',balances,rows),1000);
   expect(MoneyMath.spentToday(rows,'2026-10-31'),120);
   expect(MoneyMath.expensesForMonth(rows,'2026-10'),120);
   expect(MoneyMath.incomeForMonth(rows,'2026-10'),200);
   expect(MoneyMath.accountBalance('unknown',balances,rows),isNull);
 });
}
