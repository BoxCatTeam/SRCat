/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-04 18:43:00
/// LastEditTime: 2023-05-04 21:49:42
/// FilePath: /lib/libs/sr/services/data/base_item.dart
/// ===========================================================================

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/api.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/utils/storage/sqlite.dart';

class SrBaseItemDataService {
  static final String _table = SCDatabaseConfig.dataItemBaseTable;

  /// 从 SRCat API 下载 item 数据
  static Future<Map<String, dynamic>> download() async {
    String api = SRCatAPIConfig.itemBaseData;
    Map<String, dynamic> data = {};

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(api),
      success: (response, rawData) {
        Map<String, dynamic> res = rawData["data"];
        if (res.isNotEmpty) {
          data = res;
        } else {
          data = {};
        }
      },
      fail: (code, message, failType, error) {
        data = {};
      }
    );

    return data;
  }

  /// 将数据写入数据库
  /// 判断是否需要更新
  static Future<bool> updateItemData() async {
    return false;
  }

  /// 从数据库获取所有角色/光锥信息
  static Future<List<Map<String, Object?>>> allItem() async {
    Database database = await SCSQLiteUtils.data();

    try {
      List<Map<String, Object?>> result = await database.query(_table);
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 从数据库中获取角色/光锥信息
  static Future<List<Map<String, Object?>>> item({
    int id = 1001,
    String type = "character"
  }) async {
    Database database = await SCSQLiteUtils.data();

    try {
      List<Map<String, Object?>> result = await database.rawQuery(
        'SELECT * FROM $_table'
          ' WHERE raw_id=$id'
          ' AND type="$type"'
        ';'
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 插入角色/光锥信息
  static Future<void> insert({
    required int rawId,
    required String zhCNName,
    required String zhTWName,
    required String enUSName,
    required String jaJPName,
    required String koKRName,
    required int rank,
    required String type,
    required String color,
  }) async {
    Database database = await SCSQLiteUtils.data();

    try {
      await database.rawInsert(
        'INSERT INTO $_table '
          '(raw_id, name_zh_CN, name_zh_TW, name_en_US, name_ko_KR, name_ja_JP, rank, type, color)'
          ' VALUES($rawId, "$zhCNName", "$zhTWName", "$enUSName", "$koKRName", "$jaJPName", $rank, "$type", "$color")'
        ';'
      );
    } catch (e) {
      return;
    }
  }
}
