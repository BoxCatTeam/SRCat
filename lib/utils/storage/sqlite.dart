/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 22:53:02
/// LastEditTime: 2023-05-03 00:32:20
/// FilePath: /lib/utils/storage/sqlite.dart
/// ===========================================================================

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';

class SCSQLiteUtils {
  static Future<void> init() async {
    await warp();
  }

  /// Warp
  static Future<Database> warp() async {
    Future<void> onCreate(Database db, int version) async {
      await db.execute(
        'CREATE TABLE ${SCDatabaseConfig.warpIndexTable} ('
          '"id" INTEGER NOT NULL PRIMARY KEY,'
          '"uid" int(9) default \'0\','
          '"created" int(10) default \'0\''
        ');'
      );
      await db.execute(
        'CREATE UNIQUE INDEX warp_uid ON ${SCDatabaseConfig.warpIndexTable} ("uid");'
      );
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
      await db.execute(
        'CREATE TABLE ${SCDatabaseConfig.warpItemTable} ('
          '"id" INTEGER NOT NULL PRIMARY KEY,'                      // ID
          '"raw_id" int(25) NOT NULL default \'0\','                // 原始 ID
          '"name" TEXT NOT NULL default \'{}\','                    // 名称
          '"color" varchar(10) NOT NULL default \'000000\','        // 颜色
          '"type" varchar(15) NOT NULL default \'unknown\''         // 物品类型 (lighecone/character)
        ');'
      );
    }

    Database database = await openDatabase(
      SCDatabaseConfig.warpMaster,
      version: 1,
      onCreate: (Database db, int version) => onCreate(db, version)
    );

    return database;
  }
}
