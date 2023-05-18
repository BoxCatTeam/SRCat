/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-18 04:52:14
/// LastEditTime: 2023-05-18 08:57:34
/// FilePath: /lib/libs/srcat/warp/data.dart
/// ===========================================================================

import 'dart:convert';

import 'package:srcat/libs/metadata/db.dart';
import 'package:srcat/utils/file/main.dart';
import 'package:srcat/utils/storage/main.dart';

class SRCatWarpDataLib {
  /// 获取卡池信息
  static Future<List<Map<String, dynamic>>?> gachaPool() async {
    String name = "gacha-pool_chs";

    List<Map<String, dynamic>> result = await SRCatMetadataDatabaseLib.getFileInfo(name: name);

    if (result.isEmpty) {
      return null;
    }

    String path = "${SRCatStorageUtils.read("data_path")}/metadata${result[0]["path"]}";
    
    if (!await SRCatFileUtils.fileExists(path)) {
      return null;
    }

    List<dynamic> data = json.decode(await SRCatFileUtils.readFile(path));

    return data.cast<Map<String, dynamic>>();
  }

  /// 获取角色信息
  static Future<List<Map<String, dynamic>>?> character() async {
    String name = "character_chs";

    List<Map<String, dynamic>> result = await SRCatMetadataDatabaseLib.getFileInfo(name: name);

    if (result.isEmpty) {
      return null;
    }

    String path = "${SRCatStorageUtils.read("data_path")}/metadata${result[0]["path"]}";

    if (!await SRCatFileUtils.fileExists(path)) {
      return null;
    }

    List<dynamic> data = json.decode(await SRCatFileUtils.readFile(path));

    return data.cast<Map<String, dynamic>>();
  }

  /// 获取光锥信息
  static Future<List<Map<String, dynamic>>?> lightcone() async {
    String name = "lightcone_chs";

    List<Map<String, dynamic>> result = await SRCatMetadataDatabaseLib.getFileInfo(name: name);

    if (result.isEmpty) {
      return null;
    }

    String path = "${SRCatStorageUtils.read("data_path")}/metadata${result[0]["path"]}";

    if (!await SRCatFileUtils.fileExists(path)) {
      return null;
    }

    List<dynamic> data = json.decode(await SRCatFileUtils.readFile(path));

    return data.cast<Map<String, dynamic>>();
  }

  /// 根据 uuid 获取图片路径
  static Future<String?> image(String uuid) async {
    /// 从数据库查询
    List<Map<String, dynamic>> image = await SRCatMetadataDatabaseLib.getImageInfo(id: uuid);

    if (image.isEmpty) {
      return null;
    }

    String path = "${SRCatStorageUtils.read("data_path")}/metadata${image[0]["path"]}";

    if (!await SRCatFileUtils.fileExists(path)) {
      return null;
    }

    return path;
  }
}
