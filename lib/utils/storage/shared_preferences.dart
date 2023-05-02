/// Shared Preferences
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 16:15:02
/// LastEditTime: 2023-05-01 23:40:26
/// FilePath: /lib/utils/storage/shared_preferences.dart
/// ===========================================================================

import 'package:shared_preferences/shared_preferences.dart';

class SCSharedPreferencesUtils {
   /// 设置
  static Future<bool> set(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    late bool result;

    if (value is int) result = await prefs.setInt(key, value);
    if (value is bool) result = await prefs.setBool(key, value);
    if (value is double) result = await prefs.setDouble(key, value);
    if (value is String) result = await prefs.setString(key, value);
    if (value is List<String>) result = await prefs.setStringList(key, value);

    return result;
  }

  /// 获取
  static Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  /// 获取 int
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// 获取 bool
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// 获取 double
  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  /// 获取 String
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// 获取 List<String>
  static Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  /// 删除
  static Future<bool> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
