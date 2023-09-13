/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 23:10:31
/// LastEditTime: 2023-09-13 21:18:08
/// FilePath: /lib/utils/file/init.dart
/// ===========================================================================

import 'main.dart';
import 'package:srcat/application.dart';
import 'package:srcat/utils/storage/main.dart';
import 'package:srcat/utils/webview2/main.dart';

/// 文件初始化类
class SRCatFileInitUtils {
  /// 初始化入口
  static Future<void> init() async {
    await _createDataDir();
    await _createMetaDir();
    await _createCacheDir();
    await _createWebView2CacheDir();
  }

  /// 初始化私有目录
  static Future<void> initPrivateDir() async {
    String base = "${await SRCatFileUtils.getUserPackagesDir()}/${Application.msixAppSID}";
    await SRCatFileUtils.createDir(base);
    await SRCatFileUtils.createDir("$base/AppData");
  }

  /// 创建数据库存放目录
  static Future<void> _createDataDir() async => await SRCatFileUtils.createDir(
    "${await SRCatStorageUtils.read("data_path") as String}/database"
  );

  /// 创建元数据存放目录
  static Future<void> _createMetaDir() async => await SRCatFileUtils.createDir(
    "${await SRCatStorageUtils.read("data_path") as String}/metadata"
  );

  /// 创建缓存目录
  static Future<void> _createCacheDir() async => await SRCatFileUtils.createDir(
    "${await SRCatStorageUtils.read("data_path") as String}/cache"
  );

  /// 创建 WebView2 缓存目录
  static Future<void> _createWebView2CacheDir() async => await SRCatFileUtils.createDir(SRCatWebView2HelperUtils.cacheDir);
}
