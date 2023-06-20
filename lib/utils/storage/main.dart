/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 17:46:03
/// LastEditTime: 2023-06-07 22:38:28
/// FilePath: /lib/utils/storage/main.dart
/// ===========================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:srcat/utils/file/main.dart';

/// 公用配置工具类
class SRCatStorageUtils {
  static final String _defaultConfigPath = "${SRCatFileUtils.getExeDir()}/data/config.srcat-conf";
  static bool _loaded = false;
  static Map<String, dynamic> _configMap = {};
  /// 初始化类
  static Future<void> init() async {
    if (_loaded) {
      if (kDebugMode) print("[Storage Utils] 请勿重复初始化。");
      return;
    }

    if (await SRCatFileUtils.fileExists(_defaultConfigPath)) {
      if (kDebugMode) print("[Storage Utils] 发现配置文件，开始初始化。");

      /// 读取配置文件
      String config = await SRCatFileUtils.readFile(_defaultConfigPath);
      if (config.isEmpty) {
        if (kDebugMode) print("[Storage Utils] 配置文件为空，开始创建。");
        await SRCatFileUtils.writeStringFile(_defaultConfigPath, "{}");
      } else {
        if (kDebugMode) print("[Storage Utils] 配置文件读取成功，开始解析。");

        try {
          /// 将字符串转换为 Map
          _configMap = json.decode(config);
        } catch (e) {
          if (kDebugMode) print("[Storage Utils] 解析出错：$e");
        }

        _loaded = true;
      }
    } else {
      if (kDebugMode) print("[Storage Utils] 未发现配置文件，开始创建。");
      await SRCatFileUtils.createFile(_defaultConfigPath);
      await SRCatFileUtils.writeStringFile(_defaultConfigPath, "{}");
      _loaded = true;
    }
  }

  static Future<void> write(String key, dynamic value) async {
    if (!_loaded) {
      if (kDebugMode) print("[Storage Utils] 未初始化，无法写入。");
      return;
    }
    if (_configMap[key] != null) {
      _configMap[key] = value;
    } else {
      _configMap.addEntries(<String, dynamic>{
        key: value
      }.entries);
    }

    await SRCatFileUtils.writeStringFile(_defaultConfigPath, json.encode(_configMap));
  }

  static dynamic read(String key) {
    if (_loaded) {
      return _configMap[key];
    } else {
      if (kDebugMode) print("[Storage Utils] 未初始化，无法读取。");
      return null;
    }
  }

  static Future<dynamic> asyncRead(String key) async {
    if (!_loaded) return null;

    String config = await SRCatFileUtils.readFile(_defaultConfigPath);
    Map<String, dynamic> configMap = {};
    if (config.isNotEmpty) {
      try {
        /// 将字符串转换为 Map
        configMap = json.decode(config);
      } catch (e) {
        if (kDebugMode) print("[Storage Utils] 解析出错：$e");
      }

      return configMap[key];
    }

    return null;
  }
}