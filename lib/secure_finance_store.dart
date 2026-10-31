import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Prototype encrypted key/value persistence. Do not store actual card numbers.
class SecureFinanceStore {
  final FlutterSecureStorage storage;
  SecureFinanceStore({FlutterSecureStorage? storage})
      : storage = storage ?? const FlutterSecureStorage();

  static const key = 'golpool_financial_data_v1';

  Future<void> save(Map<String, dynamic> data) async {
    await storage.write(key: key, value: jsonEncode(data));
  }

  Future<Map<String, dynamic>?> load() async {
    final raw = await storage.read(key: key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid financial database');
    }
    return decoded;
  }

  Future<void> clear() => storage.delete(key: key);
}

class DeviceUnlock {
  final LocalAuthentication auth;
  DeviceUnlock({LocalAuthentication? auth}): auth=auth??LocalAuthentication();

  Future<bool> unlock() async {
    if (!await auth.isDeviceSupported()) return false;
    try {
      return await auth.authenticate(
        localizedReason: 'برای محافظت از اطلاعات مالی خود وارد شوید',
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
