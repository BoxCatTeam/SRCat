/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-13 18:09:45
/// LastEditTime: 2023-05-13 19:59:09
/// FilePath: /lib/utils/storage/sqlite_fix.dart
/// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';

class SCSQLiteFixUtils {
  static Future<bool> init(Database db) async {
    bool hasTable = await _queryOldTable(db, SCDatabaseConfig.warpGachaLogOldTable);
    if (hasTable) {
      await _createAndFix(db);
    }
    return false;
  }

  /// 新建新表并剔除重复数据
  static Future<void> _createAndFix(Database db) async {
    /// 判断新表是否存在
    bool hasNewTable = await _queryOldTable(db, SCDatabaseConfig.warpGachaLogTable);

    if (!hasNewTable) {
      await db.execute(
        'CREATE TABLE ${SCDatabaseConfig.warpGachaLogTable} ('
          '"id" INTEGER NOT NULL PRIMARY KEY,'                      // ID
          '"raw_id" int(25) NOT NULL default \'0\','                // 原始 ID
          '"uid" int(9) NOT NULL default \'0\','                    // UID
          '"item_id" int(10) NOT NULL default \'0\','               // 物品 ID
          '"item_type" varchar(15) NOT NULL default \'unknown\','   // 物品类型 (lighecone/character)
          '"rank_type" int(2) NOT NULL default \'0\','              // 物品星级
          '"gacha_id" int(10) NOT NULL default \'0\','              // 卡池 ID
          '"gacha_type" int(3) NOT NULL default \'0\','             // 卡池类型
          '"time" int(10) NOT NULL default \'0\''                   // 抽卡时间
        ');'
      );
    }
    
    List<Map<String, dynamic>> oldData;
    /// 查询旧表内所有数据
    try {
      oldData = await db.query(SCDatabaseConfig.warpGachaLogOldTable);
    } catch (e) {
      return;
    }

    if (oldData.isNotEmpty) {
      List<int> insert = [];
      for (var newLog in oldData) {
        if (!insert.contains(newLog["raw_id"])) {
          try {
            await db.insert(SCDatabaseConfig.warpGachaLogTable, {
              "raw_id": newLog["raw_id"],
              "uid": newLog["uid"],
              "item_id": newLog["item_id"],
              "item_type": newLog["item_type"],
              "rank_type": newLog["rank_type"],
              "gacha_id": newLog["gacha_id"],
              "gacha_type": newLog["gacha_type"],
              "time": newLog["time"],
            });
          } catch(e) {
            if (kDebugMode) print("数据存在，跳过插入");
          }
          insert.add(newLog["raw_id"]);
        }
      }
      /// 将旧表删除
      await db.execute('DROP TABLE ${SCDatabaseConfig.warpGachaLogOldTable}');
    }
  }

  /// 检查数据库表是否存在
  static Future<bool> _queryOldTable(Database db, String table) async {
    List<Map<String, dynamic>> tables = await db.rawQuery(
      "select * from Sqlite_master where type = 'table' and name = '$table'"
    );
    return tables.isEmpty ? false : true;
  }
}
