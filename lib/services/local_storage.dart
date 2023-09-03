import '../../resource/kConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  static Future<void> saveStringList(String key, List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }

  static Future<List<String>> getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? []; // Return an empty list if the key is not found
  }

  static void insertStringList(String key, List<String> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dataset = prefs.getStringList(key);
    if (dataset != null) {
      int i = 0;  // 리스트 인덱스 0 ~ 부터
      for (var e in value) {
        dataset.insert(i, e);
        i++;
      }
    } else {  // 데이터가 없는 경우 -> 새로 리스트 생성
      dataset = value;
    }
    prefs.setStringList(key, dataset);
  }

  static Future<void> removeValueFromStringList(String key, String value) async {
    print('---> removeValueFromStringList > value: $value');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? dataset = prefs.getStringList(key);
    if (dataset != null) {
      print('---> dataset: $dataset');
      dataset.remove(value);
      prefs.setStringList(key, dataset);
    }
  }

  static Future<void> deleteAllStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = prefs.getBool(key);
    print('---> sharedPreference > get bool: $res');
    return Future.value(res);
  }

  static Future<void> saveInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    int? out;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = prefs.getInt(key);
    print('---> sharedPreference > getInt: $res');
    if (res != null) {
      out = res;
    }
    return Future.value(out);
  }

  static Future<void> saveString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    String? out;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final res = prefs.getString(key);
    print('---> sharedPreference > getString: $res');
    if (res != null) {
      out = res;
    }
    return Future.value(out);
  }
}