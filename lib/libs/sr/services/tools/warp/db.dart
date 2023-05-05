/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-02 00:28:47
/// LastEditTime: 2023-05-06 00:23:35
/// FilePath: /lib/libs/sr/services/tools/warp/db.dart
/// ===========================================================================

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/storage/sqlite.dart';

class SrWrapToolDatabaseService {
  /// 从数据库中获取所有用户
  static Future<List<Map<String, Object?>>> allWarpUser() async {
    Database database = await SCSQLiteUtils.warp();

    try {
      List<Map<String, Object?>> result = await database.query('warp_index');
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 向数据库中写入用户
  static Future<void> insertWarpUser({
    required int uid,
  }) async {
    Database database = await SCSQLiteUtils.warp();

    try {
      await database.rawInsert(
        'INSERT INTO ${SCDatabaseConfig.warpIndexTable}'
          '(uid, created)'
          ' VALUES($uid, ${DateTime.now().millisecondsSinceEpoch ~/ 1000})'
        ';'
      );
    } catch (e) {
      return;
    }
  }

  /// 从数据库获取指定用户的指定抽卡记录
  static Future<List<Map<String, Object?>>> userGachaLog({
    required int uid,
    int? gachaId,
    int? gachaType,
    int? itemId,
    String? itemType,
    int? rankType,
    int? time,
  }) async {
    Database database = await SCSQLiteUtils.warp();
    
    try {
      var result = await database.rawQuery(
        'SELECT * FROM ${SCDatabaseConfig.warpGachaLogTable}'
          ' WHERE uid=$uid'
          '${gachaId != null ? " AND gacha_id=$gachaId" : ""}'
          '${gachaType != null ? " AND gacha_type=$gachaType" : ""}'
          '${itemId != null ? " AND item_id=$itemId" : ""}'
          '${itemType != null ? " AND item_type=$itemType" : ""}'
          '${rankType != null ? " AND rank_type=$rankType" : ""}'
          '${time != null ? " AND time=$time" : ""}'
          ' ORDER BY'
          ' raw_id DESC'
        ';'
      );
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 向数据库中写入指定用户的指定抽卡记录
  static Future<void> insertUserGachaLog({
    required int rawId,
    required int uid,
    required int gachaId,
    required int gachaType,
    required int itemId,
    required String itemType,
    required int rankType,
    required int time,
  }) async {
    Database database = await SCSQLiteUtils.warp();

    try {
      await database.rawInsert(
        'INSERT INTO ${SCDatabaseConfig.warpGachaLogTable}'
          '(raw_id, uid, gacha_id, gacha_type, item_id, item_type, rank_type, time)'
          ' VALUES($rawId, $uid, $gachaId, $gachaType, $itemId, "$itemType", $rankType, $time)'
        ';'
      );
    } catch (e) {
      return;
    }
  }

  /// 删除指定用户的档案与跃迁记录
  static Future<Map<String, dynamic>> deleteUserProfileAndGachaLog({
    required int uid
  }) async {
    Database database = await SCSQLiteUtils.warp();

    /// 判断数据库内有无此用户
    try {
      var result = await database.rawQuery(
        'SELECT * FROM ${SCDatabaseConfig.warpIndexTable}'
          ' WHERE uid=$uid'
        ';'
      );

      if (result.isEmpty) {
        throw Exception("Not found this user");
      }
    } catch (e) {
      return {
        "status": false,
        "message": e.toString(),
      };
    }

    /// 从 gacha_log 表中删除用户的所有记录
    try {
      await database.rawDelete(
        'DELETE FROM ${SCDatabaseConfig.warpGachaLogTable}'
          ' WHERE uid=$uid'
        ';'
      );
    } catch (e) {
      return {
        "status": false,
        "message": e.toString()
      };
    }

    /// 从 warp_index 删除该用户信息
    try {
      await database.rawDelete(
        'DELETE FROM ${SCDatabaseConfig.warpIndexTable}'
          ' WHERE uid=$uid'
        ';'
      );
    } catch (e) {
      return {
        "status": false,
        "message": e.toString()
      };
    }

    return {"status": true, "message": "Success"};
  }
}
