import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStoreInteractor {
  final FlutterSecureStorage _secureStorage;

  SecureStoreInteractor(this._secureStorage);

  Future<String?> read(String key) => _secureStorage.read(key: key);

  Future<void> write(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  Future<void> delete(String key) => _secureStorage.delete(key: key);

  Future<void> deleteAll() => _secureStorage.deleteAll();

  Future<bool> containsKey(String key) => _secureStorage.containsKey(key: key);
}
