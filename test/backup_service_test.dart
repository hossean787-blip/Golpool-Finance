import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/backup_service.dart';

void main() {
  final dataset=<String,dynamic>{'items':[{'type':'expense','amount':12000,'note':'خرید'}],
    'cards':['بانک'], 'budgets':{'خوراک':100000},'goals':<dynamic>[],'debts':<dynamic>[]};
  test('encrypted backup roundtrip preserves financial information', () async {
    const password='strong-example-password';
    final encrypted=await GolpoolBackup.encrypt(dataset,password);
    expect(encrypted.contains('خرید'),isFalse);
    final result=await GolpoolBackup.decrypt(encrypted,password);
    expect((result['items'] as List).first['amount'],12000);
  });
  test('invalid password fails without returning plaintext', () async {
    final encrypted=await GolpoolBackup.encrypt(dataset,'strong-example-password');
    await expectLater(GolpoolBackup.decrypt(encrypted,'incorrect-password'),throwsA(isA<Exception>()));
  });
  test('short backup password rejected',()async{
    await expectLater(GolpoolBackup.encrypt(dataset,'short'),throwsArgumentError);
  });
}
