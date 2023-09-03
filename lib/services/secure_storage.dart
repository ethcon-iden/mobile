import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OmgSecureStorage {
  OmgSecureStorage();

  static OmgSecureStorage instance = OmgSecureStorage();

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  final AndroidOptions _androidOptions = const AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'appOMG'
  );

  final IOSOptions _iOSOptions = const IOSOptions(
    accountName: 'appOMG',
  );

  Future<void> saveKey(String key, String value) async {
    await _storage.write(
        key: key,
        value: value,
        aOptions: _androidOptions,
        iOptions: _iOSOptions
    );
  }

  Future<String?> getKey(String key) async {
    final value = await _storage.read(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iOSOptions
    );
    return value;
  }

  Future<void> readAll() async {
    Map<String, String> data = await _storage.readAll(
      aOptions: _androidOptions,
      iOptions: _iOSOptions
    );
    print('---> read all: $data');
  }

  Future<void> deleteKey(String key) async {
    await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iOSOptions
    );
  }

  Future<void> resetStorage() async {
    /// reset user related data
    await _storage.deleteAll(
        aOptions: _androidOptions,
        iOptions: _iOSOptions
    );
  }

}