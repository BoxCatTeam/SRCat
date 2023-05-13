/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 22:53:02
/// LastEditTime: 2023-05-14 07:43:24
/// FilePath: /lib/utils/storage/sqlite.dart
/// ===========================================================================

import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/storage/sqlite_fix.dart';

class SCSQLiteUtils {
  static Future<void> init() async {
    await warp();
    await data();
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
    }

    Future<void> onUpgrade(Database db) async {
      /// DELETE WarpItemTable
      /// 判断是否存在表
      List<Map<String, dynamic>> tables = await db.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '${SCDatabaseConfig.warpItemTable}'"
      );
      if (tables.isNotEmpty) {
        await db.execute(
          'DROP TABLE ${SCDatabaseConfig.warpItemTable};'
        );
      }

      /// 备份旧表
      File v2WarpDatabase = File(SCDatabaseConfig.warpMaster);
      await v2WarpDatabase.copy("${SCDatabaseConfig.base}/warp.v2.db");

      await SCSQLiteFixUtils.init(db);
    }

    Database database = await openDatabase(
      SCDatabaseConfig.warpMaster,
      version: 3,
      onCreate: (Database db, int version) => onCreate(db, version),
      onUpgrade: (Database db, int version, int un) => onUpgrade(db)
    );

    return database;
  }

  /// Data
  static Future<Database> data() async {
    Future<void> onCreate(Database db, int version) async {
      await db.execute(
        'CREATE TABLE ${SCDatabaseConfig.dataItemBaseTable} ('
          '"id" INTEGER NOT NULL PRIMARY KEY,'                      // ID
          '"raw_id" int(25) NOT NULL default \'0\','                // 原始 ID
          '"name_zh_CN" TEXT NOT NULL default \'\','                // 名称 zh_CN
          '"name_zh_TW" TEXT NOT NULL default \'\','                // 名称 zh_TW
          '"name_en_US" TEXT NOT NULL default \'\','                // 名称 en_US
          '"name_ko_KR" TEXT NOT NULL default \'\','                // 名称 ko_KR
          '"name_ja_JP" TEXT NOT NULL default \'\','                // 名称 ja_JP
          '"color" varchar(10) NOT NULL default \'000000\','        // 颜色
          '"rank" int(2) NOT NULL default \'0\','                   // 物品星级
          '"type" varchar(15) NOT NULL default \'unknown\''         // 物品类型 (lighecone/character)
        ');'
      );
    }

    Database database = await openDatabase(
      SCDatabaseConfig.dataMaster,
      version: 2,
      onCreate: (Database db, int version) => onCreate(db, version)
    );

    return database;
  }
}
