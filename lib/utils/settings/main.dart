/// 设置工具类
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 16:18:35
/// LastEditTime: 2023-05-01 16:56:56
/// FilePath: /lib/utils/settings/main.dart
/// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:srcat/config/settings.dart';
import 'package:srcat/utils/storage/shared_preferences.dart';

class SCSettingsUtils {
  /// 设置存储的 SP Key 前缀
  static final String _settingsSPKeyPrefix = SCSettingsSPKey.prefix;

  /// 设置项
  static final Map<String, dynamic> _settings = {};

  /// 初始化所有设置项
  static Future<void> init() async {
    Map<String, dynamic> defaultSettings = _getDefaultSettings();

    try {
      /// hsr exe
      _settings.addEntries(<String, String>{
        SCSettingsSPKey.hsrExe: await _get(
          SCSettingsSPKey.hsrExe,
          defaultSettings[SCSettingsSPKey.hsrExe]
        ),
      }.entries);

      /// 主题
      _settings.addEntries(<String, String>{
        SCSettingsSPKey.theme: await _get(
          SCSettingsSPKey.theme,
          defaultSettings[SCSettingsSPKey.theme]
        ),
      }.entries);

      /// 语言
      _settings.addEntries(<String, String>{
        SCSettingsSPKey.language: await _get(
          SCSettingsSPKey.language,
          defaultSettings[SCSettingsSPKey.language]
        ),
      }.entries);

      /// 背景材质
      _settings.addEntries(<String, String>{
        SCSettingsSPKey.material: await _get(
          SCSettingsSPKey.material,
          defaultSettings[SCSettingsSPKey.material]
        ),
      }.entries);
    } catch (e) {
      if (kDebugMode) print("[Settigns Utils] 设置初始化错误 ｜ 错误详细: $e");
    }

    if (kDebugMode) print("[Settigns Utils] 设置初始化完成 ｜ 设置项: $_settings");
  }

  /// 获取指定设置项
  static dynamic get(String key) {
    // 判断设置项是否存在
    if (!_settings.containsKey(key)) {
      if (kDebugMode) print("[Settigns Utils] 设置项不存在，获取失败！ ｜ 设置项: $key");
      return null;
    }
    
    return _settings[key];
  }

  /// 设置指定设置项
  static Future<bool> set(String key, dynamic value) async {
    // 判断设置项是否存在
    if (!_settings.containsKey(key)) {
      if (kDebugMode) print("[Settigns Utils] 设置项不存在，设置/更新失败！ ｜ 设置项: $key ｜ 设置值: $value");
      return false;
    }
    _settings[key] = value;
    bool result = await SCSharedPreferencesUtils.set(_settingsSPKeyPrefix + key, value);
    if (kDebugMode) {
      if (result) {
        print("[Settigns Utils] 设置项设置/更新成功！ ｜ 设置项: $key ｜ 设置值: $value");
      } else {
        print("[Settigns Utils] 设置项设置/更新失败！ ｜ 设置项: $key ｜ 设置值: $value");
      }
    }

    return result;
  }

  /// 内部获取指定设置项
  static Future<dynamic> _get(String key, dynamic defaultValue) async {
    dynamic setting;

    if (defaultValue is List<String>) {
      setting = await SCSharedPreferencesUtils.getStringList(_settingsSPKeyPrefix + key);
    } else if (defaultValue is bool) {
      setting = await SCSharedPreferencesUtils.getBool(_settingsSPKeyPrefix + key);
    } else if (defaultValue is String) {
      setting = await SCSharedPreferencesUtils.getString(_settingsSPKeyPrefix + key);
    } else {
      setting = await SCSharedPreferencesUtils.get(_settingsSPKeyPrefix + key);
    }

    if (setting == null) return defaultValue;
    return setting;
  }

  /// 默认的设置项
  static Map<String, dynamic> _getDefaultSettings() {
    Map<String, dynamic> settings = {
      SCSettingsSPKey.hsrExe: "",             // HSR EXE
      SCSettingsSPKey.theme: "auto",          // 主题
      SCSettingsSPKey.language: "zh_CN",      // 语言
      SCSettingsSPKey.material: "mica",       // 背景材质
    };

    return settings;
  }
}
