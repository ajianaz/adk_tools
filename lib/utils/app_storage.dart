import 'package:adk_tools/config/adk_tools_init.dart';
import 'package:hive/hive.dart';

class AppStorage {
  static final _hive = Hive.box<dynamic>(ADKTools.appName);

  static read({required String key, dynamic defaultvalue}) {
    return _hive.get(key, defaultValue: defaultvalue);
  }

  static write({required String key, dynamic data}) {
    return _hive.put(key, data);
  }

  static delete({required String key}) {
    return _hive.delete(key);
  }

  static bool isContain({required dynamic key}) {
    bool check = _hive.containsKey(key);
    return check;
  }
}
