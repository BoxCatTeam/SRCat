/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 15:55:53
/// LastEditTime: 2023-05-01 23:43:27
/// FilePath: /lib/utils/file/init.dart
/// ===========================================================================

import 'main.dart';
import 'package:srcat/config/file.dart';

class FileInitUtils {
  /// 初始化入口
  static Future<void> init() async {
    await _createDataDir();
    await _createCacheDir();
    await _createImageCahceDir();
    await _createDatabaseDir();
  }

  /// 创建数据目录
  static Future<void> _createDataDir() async => await FileUtils.createDir("${FileUtils.getExeDir()}/${SCFileConfig.data}");

  /// 创建缓存目录
  static Future<void> _createCacheDir() async => await FileUtils.createDir("${FileUtils.getExeDir()}/${SCFileConfig.cache}");
  /// 创建图片缓存目录
  static Future<void> _createImageCahceDir() async => await FileUtils.createDir("${FileUtils.getExeDir()}/${SCFileConfig.imageCache}");

  /// 创建数据库存储目录
  static Future<void> _createDatabaseDir() async => await FileUtils.createDir("${FileUtils.getExeDir()}/${SCFileConfig.databases}");
}
