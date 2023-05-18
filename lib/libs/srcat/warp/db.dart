/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 09:55:24
/// LastEditTime: 2023-05-18 10:38:49
/// FilePath: /lib/libs/srcat/warp/db.dart
/// ===========================================================================

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/main.dart';
import 'package:srcat/utils/storage/sqlite.dart';

class SRCatWarpDatabaseLib {
  /// 从数据库中获取所有用户
  static Future<List<Map<String, Object?>>> allWarpUser() async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      List<Map<String, Object?>> result = await database.query(SRCatDatabaseConfig.userdataWarpIndexTable);
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 向数据库中写入用户
  static Future<void> insertWarpUser({
    required int uid,
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      await database.rawInsert(
        'INSERT INTO ${SRCatDatabaseConfig.userdataWarpIndexTable}'
          '(uid, created)'
          ' VALUES($uid, ${SRCatUtils.getUnixTime()})'
        ';'
      );
    } catch (e) {
      return;
    }
  }

  /// 修改当前选中用户
  static Future<void> updateSelectUser({
    required int uid
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      database.update(SRCatDatabaseConfig.userdataWarpIndexTable, {
        "select": 0
      });
    } catch (e) {
      return;
    }

    try {
      database.update(SRCatDatabaseConfig.userdataWarpIndexTable,
        {
          "select": 1
        },
        where: "uid=?",
        whereArgs: [uid]
      );
    } catch (e) {
      return;
    }
  }

  /// 从数据库获取指定用户的指定抽卡记录
  static Future<List<Map<String, Object?>>> userGachaLog({
    required int uid,
    int? rawId,
    int? gachaId,
    int? gachaType,
    int? itemId,
    String? itemType,
    int? rankType,
    int? time,
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();
    
    try {
      var result = await database.rawQuery(
        'SELECT * FROM ${SRCatDatabaseConfig.userdataWarpGachaLogTable}'
          ' WHERE uid=$uid'
          '${rawId != null ? " AND raw_id=$rawId" : ""}'
          '${gachaId != null ? " AND gacha_id=$gachaId" : ""}'
          '${gachaType != null ? " AND gacha_type=$gachaType" : ""}'
          '${itemId != null ? " AND item_id=$itemId" : ""}'
          '${itemType != null ? " AND item_type='$itemType'" : ""}'
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
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      await database.rawInsert(
        'INSERT INTO ${SRCatDatabaseConfig.userdataWarpGachaLogTable}'
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
    Database database = await SRCatSQLiteUtils.userdata();

    /// 判断数据库内有无此用户
    try {
      var result = await database.rawQuery(
        'SELECT * FROM ${SRCatDatabaseConfig.userdataWarpIndexTable}'
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
        'DELETE FROM ${SRCatDatabaseConfig.userdataWarpGachaLogTable}'
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
        'DELETE FROM ${SRCatDatabaseConfig.userdataWarpIndexTable}'
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
