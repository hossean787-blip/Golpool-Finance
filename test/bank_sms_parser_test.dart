import 'package:flutter_test/flutter_test.dart';
import 'package:golpool/bank_sms_parser.dart';
void main(){
 test('persian rial debit',(){
  final x=BankSmsParser.parse('برداشت مبلغ: ۱,۵۰۰,۰۰۰ ریال کارت ****۱۲۳۴');
  expect(x?.amount,150000);expect(x?.direction,'expense');
 });
 test('toman credit',(){
  final x=BankSmsParser.parse('واریز مبلغ: 250,000 تومان حساب ****5678');
  expect(x?.amount,250000);expect(x?.direction,'income');
 });
 test('unknown currency rejected',()=>expect(BankSmsParser.parse('برداشت مبلغ 100000'),isNull));
 test('ambiguous transfer rejected',()=>expect(BankSmsParser.parse('برداشت و واریز مبلغ 100000 ریال'),isNull));
 test('otp ignored',()=>expect(BankSmsParser.parse('رمز دوم شما 123456'),isNull));
}
