import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/backup_service.dart';

void main() {
  final dataset=<String,dynamic>{'items':[{'type':'expense','date':'2026-10-31','amount':12000,'note':'خرید'}],
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
  test('tampered ciphertext fails authentication',()async{
    final encrypted=await GolpoolBackup.encrypt(dataset,'strong-example-password');
    final record=Map<String,dynamic>.from(jsonDecode(encrypted) as Map);
    final original=base64Decode(record['ciphertext'] as String);
    original[0]^=1;
    record['ciphertext']=base64Encode(original);
    await expectLater(GolpoolBackup.decrypt(jsonEncode(record),'strong-example-password'),
      throwsA(isA<Exception>()));
  });
  test('backup format and version are checked',()async{
    final encrypted=await GolpoolBackup.encrypt(dataset,'strong-example-password');
    final record=Map<String,dynamic>.from(jsonDecode(encrypted) as Map);
    record['version']=999;
    await expectLater(GolpoolBackup.decrypt(jsonEncode(record),'strong-example-password'),
      throwsA(isA<FormatException>()));
  });
  test('backup does not reuse encryption salt and nonce',()async{
    final first=jsonDecode(await GolpoolBackup.encrypt(dataset,'strong-example-password')) as Map;
    final second=jsonDecode(await GolpoolBackup.encrypt(dataset,'strong-example-password')) as Map;
    expect(first['salt'],isNot(second['salt']));
    expect(first['nonce'],isNot(second['nonce']));
  });

  test('authenticated but invalid financial rows are rejected',()async{
    final invalid=<String,dynamic>{...dataset,
      'items':[{'type':'expense','date':'2026-10-31','amount':-10}]};
    final encrypted=await GolpoolBackup.encrypt(invalid,'strong-example-password');
    await expectLater(GolpoolBackup.decrypt(encrypted,'strong-example-password'),
      throwsA(isA<FormatException>()));
  });

}
