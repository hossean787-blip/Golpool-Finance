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
 test('editing an expense cannot overdraw the linked account',(){
   final old=<String,dynamic>{'type':'expense','account':'A','amount':100,'date':'2026-10-31'};
   final rows=<Map<String,dynamic>>[old];
   expect(MoneyMath.canPost(rows,{'A':500},
       {'type':'expense','account':'A','amount':600},original:old),isFalse);
   expect(MoneyMath.canPost(rows,{'A':500},
       {'type':'expense','account':'A','amount':400},original:old),isTrue);
 });
 test('transfer validates distinct accounts and never counts as income',(){
   final rows=<Map<String,dynamic>>[];
   expect(MoneyMath.canPost(rows,{'A':300,'B':100},
       {'type':'transfer','amount':301,'from':'A','to':'B'}),isFalse);
   expect(MoneyMath.canPost(rows,{'A':300,'B':100},
       {'type':'transfer','amount':200,'from':'A','to':'B'}),isTrue);
   expect(MoneyMath.canPost(rows,{'A':300,'B':100},
       {'type':'transfer','amount':100,'from':'A','to':'A'}),isFalse);
 });
 test('partial debt settlement is tracked without exceeding principal',(){
   expect(MoneyMath.debtRemaining({'amount':500,'paid':125}),375);
   expect(MoneyMath.debtRemaining({'amount':500,'paid':500}),0);
   expect(MoneyMath.debtRemaining({'amount':500,'settled':true}),0);
   expect(MoneyMath.debtRemaining({'amount':500,'settled':false}),500);
 });

}
