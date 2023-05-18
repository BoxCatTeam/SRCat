/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 23:10:31
/// LastEditTime: 2023-05-08 23:15:22
/// FilePath: /lib/utils/file/init.dart
/// ===========================================================================

import 'main.dart';
import 'package:srcat/utils/storage/main.dart';

/// 文件初始化类
class SRCatFileInitUtils {
  /// 初始化入口
  static Future<void> init() async {
    await _createDataDir();
    await _createMetaDir();
    await _createCacheDir();
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
}
