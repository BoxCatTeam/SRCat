/// 文件类
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-29 13:02:57
/// LastEditTime: 2023-05-02 06:41:55
/// FilePath: /lib/utils/file/main.dart
/// ===========================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';

class FileUtils {
  /// 应用可执行文件路径
  static String exePath = Platform.resolvedExecutable;

  /// 获取 Windows 可执行文件名字
  static String getExeName() {
    return exePath.substring(exePath.lastIndexOf(Platform.pathSeparator) + 1);
  }

  /// 获取 Windows 可执行文件所在目录
  static String getExeDir() {
    return exePath.substring(0, exePath.lastIndexOf(Platform.pathSeparator));
  }

  /// 创建文件夹
  static Future<String> createDir(String dirPath) async {
    Directory dir = Directory(dirPath);

    try {
      if (!await dir.exists()) {
        await dir.create();
      } else {
        if (kDebugMode) print("[File Utils] 文件夹 \"$dirPath\" 已存在，跳过创建。");
      }
    } catch (e) {
      if (kDebugMode) print("[File Utils] 文件夹 \"$dirPath\" 创建出错 | 错误原因: $e");
    }

    return dir.path;
  }

  /// 异步创建文件夹
  /// 交由后台异步创建，不阻塞进程
  static void createDirSync(String dirPath) {{
    Directory dir = Directory(dirPath);
    if (!dir.existsSync()) {{
      dir.createSync(recursive: true);
    }}
  }}
}
