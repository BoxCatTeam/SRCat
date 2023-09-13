/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-09-13 20:36:20
/// LastEditTime: 2023-09-13 21:18:52
/// FilePath: /lib/compatible/config.dart
/// ===========================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:srcat/application.dart';
import 'package:srcat/utils/file/main.dart';

class SRCatConfigCompatibleUtils {
  /// 旧配置文件所在目录
  static final String _sourceConfig = "${SRCatFileUtils.getExeDir()}/data/config.srcat-conf";
  
  /// 检查文件是否存在
  static Future<bool> check() async => await SRCatFileUtils.fileExists(_sourceConfig);

  /// 迁移旧的数据
  static Future<void> migrate() async {
    File sourceConfigFile = File(_sourceConfig);
    File destinationConfigFile = File("${await SRCatFileUtils.getUserPackagesDir()}/${Application.msixAppSID}/AppData/srcat-conf");

    try {
      sourceConfigFile.copySync(destinationConfigFile.path);
      // 删除原先的配置
      sourceConfigFile.delete();
    } catch (e) {
      if (kDebugMode) print("[Storage Compatible Utils] 配置文件迁移失败");
    }

    if (kDebugMode) print("[Storage Compatible Utils] 配置文件迁移成功");
  }
}
