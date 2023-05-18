/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 17:48:10
/// LastEditTime: 2023-05-08 18:07:11
/// FilePath: /lib/utils/file/main.dart
/// ===========================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';

/// 文件工具类
class SRCatFileUtils {
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
  /// 
  /// 交由后台异步创建，不阻塞进程
  static void createDirSync(String dirPath) {{
    Directory dir = Directory(dirPath);
    if (!dir.existsSync()) {{
      dir.createSync(recursive: true);
    }}
  }}

  /// 判断文件夹是否存在
  static Future<bool> dirExists(String dirPath) async {
    Directory dir = Directory(dirPath);
    return await dir.exists();
  }

  /// 判断文件是否存在
  static Future<bool> fileExists(String filePath) async {
    File file = File(filePath);
    return await file.exists();
  }

  /// 读取文件
  static Future<String> readFile(String filePath) async {
    File file = File(filePath);
    return await file.readAsString();
  }

  /// 仅创建文件
  static Future<File> createFile(String filePath) async {
    File file = File(filePath);
    return await file.create();
  }

  /// 以字符串形式写入文件
  static Future<File> writeStringFile(String filePath, String content) async {
    File file = File(filePath);
    return await file.writeAsString(content);
  }
}
