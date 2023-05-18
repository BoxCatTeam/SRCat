/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 00:43:28
/// LastEditTime: 2023-05-16 04:06:37
/// FilePath: /lib/utils/settings.dart
/// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:srcat/config/settings.dart';
import 'package:srcat/utils/storage/main.dart';

/// 设置工具类
class SRCatSettingsUtils {
  /// 设置存储的 Key 前缀
  static final String _settingsKeyPrefix = SRCatSettingsKey.prefix;

  /// 设置项
  static final Map<String, dynamic> _settings = {};

  /// 初始化所有设置项
  static Future<void> init() async {
    Map<String, dynamic> defaultSettings = _getDefaultSettings();

    try {
      /// 主题
      _settings.addEntries(<String, String>{
        SRCatSettingsKey.theme: await _get(
          SRCatSettingsKey.theme,
          defaultSettings[SRCatSettingsKey.theme]
        ),
      }.entries);

      /// 语言
      _settings.addEntries(<String, String>{
        SRCatSettingsKey.language: await _get(
          SRCatSettingsKey.language,
          defaultSettings[SRCatSettingsKey.language]
        ),
      }.entries);

      /// 背景材质
      _settings.addEntries(<String, String>{
        SRCatSettingsKey.material: await _get(
          SRCatSettingsKey.material,
          defaultSettings[SRCatSettingsKey.material]
        ),
      }.entries);
    } catch (e) {
      if (kDebugMode) print("[Settigns Utils] 设置初始化错误 ｜ 错误详细: $e");
    }

    if (kDebugMode) print("[Settigns Utils] 设置初始化完成 ｜ 设置项: $_settings");
  }

  /// 设置指定设置项
  static Future<bool> set(String key, dynamic value) async {
    if (!_settings.containsKey(key)) {
      if (kDebugMode) print("[Settigns Utils] 设置项不存在，设置/更新失败！ ｜ 设置项: $key ｜ 设置值: $value");
      return false;
    }

    if (_settings[key] == value) {
      if (kDebugMode) print("[Settigns Utils] 设置项的值未改动，无需更新设置 ｜ 设置项: $key ｜ 设置值: $value");
      return false;
    }

    _settings[key] = value;

    await SRCatStorageUtils.write(_settingsKeyPrefix + key, value);

    if (kDebugMode) {
      print("[Settigns Utils] 设置项设置/更新成功！ ｜ 设置项: $key ｜ 设置值: $value");
    }

    return true;
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

  /// 内部获取指定设置项
  static Future<dynamic> _get(String key, dynamic defaultValue) async {
    dynamic setting = SRCatStorageUtils.read(_settingsKeyPrefix + key);

    if (setting == null) return defaultValue;
    return setting;
  }

  /// 默认的设置项
  static Map<String, dynamic> _getDefaultSettings() {
    Map<String, dynamic> settings = {
      SRCatSettingsKey.theme: "auto",          // 主题
      SRCatSettingsKey.language: "zh-CN",      // 语言
      SRCatSettingsKey.material: "default",    // 背景材质
    };

    return settings;
  }
}
