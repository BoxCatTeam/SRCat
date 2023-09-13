/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 17:48:10
/// LastEditTime: 2023-05-08 18:07:11
/// FilePath: /lib/utils/file/main.dart
/// ===========================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

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

  /// 使用 ffi 与 win32 获取 用户目录/AppData/Local/Packages 目录
  static Future<String> getUserPackagesDir() async {
    String dir = "";
    final Pointer<Pointer<Utf16>> pathPtrPtr = calloc<Pointer<Utf16>>();
    final Pointer<GUID> knownFolderID = calloc<GUID>()..ref.setGUID(FOLDERID_LocalAppData);

    try {
      final int hr = SHGetKnownFolderPath(
        knownFolderID,
        KF_FLAG_DEFAULT,
        NULL,
        pathPtrPtr,
      );

      if (FAILED(hr)) {
        if (hr == E_INVALIDARG || hr == E_FAIL) {
          throw WindowsException(hr);
        }
        dir = await Future<String?>.value() ?? getExeDir();
      }

      final String path = pathPtrPtr.value.toDartString();
      dir = await Future<String>.value(path);
    } finally {
      calloc.free(pathPtrPtr);
      calloc.free(knownFolderID);
    }

    return "$dir/Packages";
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
