import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_beachmat_app/models/database_provider.dart';

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
    // await DatabaseProvider.deleteUsers(); // TODO: Comment/remove
    // await removeToken(); // TODO: Comment/remove
    String token = await _storage.read(key: _tokenKey);
    print('GETTOKEN: $token'); // TODO: Remove
    return token;
  }

  static Future<void> setToken(String token) async {
    print('WRITETOKEN: $token'); // TODO: Remove
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> removeToken() async {
    print('REMOVETOKEN'); // TODO: Remove
    await _storage.delete(key: _tokenKey);
  }
}
