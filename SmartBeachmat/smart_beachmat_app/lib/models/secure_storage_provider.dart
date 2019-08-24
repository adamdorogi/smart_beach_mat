import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Singleton.
class SecureStorageProvider {
  static final SecureStorageProvider _secureStorageProvider =
      SecureStorageProvider._();
  static FlutterSecureStorage _storage = FlutterSecureStorage();

  static final String _tokenKey = 'token';

  factory SecureStorageProvider() {
    return _secureStorageProvider;
  }

  // Constructor.
  SecureStorageProvider._();

  static Future<String> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
