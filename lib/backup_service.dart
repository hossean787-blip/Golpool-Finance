import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Password-protected versioned backup with PBKDF2 and authenticated AES-GCM.
/// The password is never stored or transmitted.
class GolpoolBackup {
  static const version = 1;
  static final _cipher = AesGcm.with256bits();
  static final _kdf = Pbkdf2(macAlgorithm:Hmac.sha256(),iterations:210000,bits:256);

  static Future<String> encrypt(Map<String,dynamic> data,String password) async {
    if(password.length<12) throw ArgumentError('Backup password must contain 12+ characters');
    final rng=Random.secure();
    final salt=List<int>.generate(16,(_)=>rng.nextInt(256));
    final nonce=List<int>.generate(12,(_)=>rng.nextInt(256));
    final key=await _kdf.deriveKey(secretKey:SecretKey(utf8.encode(password)),nonce:salt);
    final box=await _cipher.encrypt(utf8.encode(jsonEncode(data)),secretKey:key,nonce:nonce);
    return jsonEncode({'format':'golpool-encrypted-backup','version':version,'salt':base64Encode(salt),
      'nonce':base64Encode(nonce),'ciphertext':base64Encode(box.cipherText),'mac':base64Encode(box.mac.bytes)});
  }

  static Future<Map<String,dynamic>> decrypt(String file,String password) async {
    final record=jsonDecode(file);
    if(record is! Map || record['format']!='golpool-encrypted-backup'||record['version']!=version){
      throw const FormatException('Unsupported backup format');
    }
    final salt=base64Decode(record['salt'] as String);
    final nonce=base64Decode(record['nonce'] as String);
    final ciphertext=base64Decode(record['ciphertext'] as String);
    final mac=base64Decode(record['mac'] as String);
    if(salt.length!=16 || nonce.length!=12 || mac.length!=16 || ciphertext.length>20000000){
      throw const FormatException('Invalid backup');
    }
    final key=await _kdf.deriveKey(secretKey:SecretKey(utf8.encode(password)),nonce:salt);
    final plaintext=await _cipher.decrypt(SecretBox(ciphertext,nonce:nonce,mac:Mac(mac)),secretKey:key);
    final decoded=jsonDecode(utf8.decode(plaintext));
    if(decoded is! Map<String,dynamic> || decoded['items'] is! List || decoded['cards'] is! List ||
        decoded['budgets'] is! Map || decoded['goals'] is! List || decoded['debts'] is! List){
      throw const FormatException('Invalid backup data');
    }
    for(final raw in decoded['items'] as List){
      if(raw is! Map || raw['amount'] is! num || (raw['amount'] as num)<=0 ||
         raw['type'] is! String || !['income','expense','transfer'].contains(raw['type']) ||
         raw['date'] is! String){
        throw const FormatException('Invalid financial transaction in backup');
      }
    }
    for(final raw in decoded['goals'] as List){
      if(raw is! Map || raw['saved'] is! num || raw['target'] is! num ||
         (raw['saved'] as num)<0 || (raw['target'] as num)<=0){
        throw const FormatException('Invalid savings goal in backup');
      }
    }
    for(final raw in decoded['debts'] as List){
      if(raw is! Map || raw['amount'] is! num || (raw['amount'] as num)<=0){
        throw const FormatException('Invalid debt in backup');
      }
    }
    for(final entry in (decoded['budgets'] as Map).entries){
      if(entry.key is! String || entry.value is! num || (entry.value as num)<0){
        throw const FormatException('Invalid budget in backup');
      }
    }
    return decoded;
  }
}
