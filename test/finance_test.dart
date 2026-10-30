import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/finance.dart';
void main(){
 final rows=<Map<String,dynamic>>[
  {'type':'expense','date':'2026-10-31','amount':900000,'note':'','parts':[{'category':'خوراک','amount':300000},{'category':'پوشاک','amount':600000}]},
  {'type':'income','date':'2026-10-31','amount':1200000,'note':'حقوق'},
  {'type':'expense','date':'2026-10-30','amount':100000,'category':'خوراک','note':'ناهار'}];
 test('daily expense',()=>expect(MoneyMath.spentToday(rows,'2026-10-31'),900000));
 test('split category',()=>expect(MoneyMath.categorySpent(rows,'خوراک','2026-10'),400000));
 test('other split',()=>expect(MoneyMath.categorySpent(rows,'پوشاک','2026-10'),600000));
 test('pending',()=>expect(MoneyMath.pending(rows).length,1));
 test('split validated',()=>expect(MoneyMath.validateParts(900000,[{'category':'خوراک','amount':300000},{'category':'پوشاک','amount':600000}]),true));
 test('split mismatch',()=>expect(MoneyMath.validateParts(800000,[{'category':'خوراک','amount':300000},{'category':'پوشاک','amount':600000}]),false));
 test('goal progress',()=>expect(MoneyMath.progress(18000000,60000000),30));
 test('goal cap',()=>expect(MoneyMath.progress(120,100),100));
}