/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 04:54:12
/// LastEditTime: 2023-05-16 04:40:09
/// FilePath: /lib/libs/srcat/game/accounts.dart
/// ===========================================================================

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/main.dart';
import 'package:srcat/utils/storage/sqlite.dart';

/// 游戏账号工具库
class SRCatGameAccountsLib {
  static final String _table = SRCatDatabaseConfig.userdataGameAccountsTable;

  /// 从数据库中获取所有账号
  static Future<List<Map<String, dynamic>>> getAll() async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      List<Map<String, dynamic>> result = await database.query(_table);
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 插入一个账号
  static Future<void> insert({
    required String sdkey,
    required String nickname
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      /// 根据 sdkey 生成 UUID
      String uuid = SRCatUtils.getUUIDv5(sdkey);
      await database.insert(_table, {
        "id": uuid,
        "name": nickname,
        "sdkey": sdkey,
        "type": 0,
        "time": SRCatUtils.getUnixTime()
      });
    } catch (e) {
      return;
    }
  }

  /// 根据 UUID 删除账号
  static Future<void> delete({
    required String uuid
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      await database.rawDelete(
        'DELETE FROM $_table WHERE id = "$uuid";'
      );
    } catch (e) {
      return;
    }
  }

  /// 根据 uuid 修改账号信息
  static Future<void> update({
    required String uuid,
    required String nickname
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      await database.update(_table,
        {
          "name": nickname
        },
        where: "id=?",
        whereArgs: [uuid]
      );
    } catch (e) {
      return;
    }
  } 
}
