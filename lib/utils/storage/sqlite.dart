/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
<<<<<<< HEAD
/// Date: 2023-05-08 23:30:14
/// LastEditTime: 2023-05-18 07:15:28
/// FilePath: /lib/utils/storage/sqlite.dart
/// ===========================================================================

import 'main.dart';
=======
/// Date: 2023-05-01 22:53:02
/// LastEditTime: 2023-05-14 07:43:24
/// FilePath: /lib/utils/storage/sqlite.dart
/// ===========================================================================

import 'dart:io';

>>>>>>> bf52e1f8badeeb9d60ede91a40c54344d5a423a3
import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/storage/sqlite_fix.dart';

class SRCatSQLiteUtils {
  static late String _base;
  static Future<void> init() async {
    _base = "${await SRCatStorageUtils.read("data_path")}/database";
    await userdata();
    await metadata();
  }

  /// 用户数据库
  static Future<Database> userdata() async {
    Future<void> onCreate(Database db, int version) async {
      await db.execute(
        'CREATE TABLE ${SRCatDatabaseConfig.userdataWarpIndexTable} ('
          '"id" INTEGER NOT NULL PRIMARY KEY,'
          '"uid" int(9) default \'0\','
          '"select" int(1) default \'0\','
          '"created" int(10) default \'0\''
        ');'
      );
      await db.execute(
        'CREATE UNIQUE INDEX warp_uid ON ${SRCatDatabaseConfig.userdataWarpIndexTable} ("uid");'
      );
      await db.execute(
        'CREATE TABLE ${SRCatDatabaseConfig.userdataWarpGachaLogTable} ('
          '"id" INTEGER NOT NULL PRIMARY KEY,'                      // ID
          '"raw_id" int(25) NOT NULL UNIQUE,'                       // 原始 ID
          '"uid" int(10) NOT NULL default \'0\','                   // UID
          '"item_id" int(10) NOT NULL default \'0\','               // 物品 ID
          '"item_type" varchar(15) NOT NULL default \'unknown\','   // 物品类型 (lighecone/character)
          '"rank_type" int(2) NOT NULL default \'0\','              // 物品星级
          '"gacha_id" int(10) NOT NULL default \'0\','              // 卡池 ID
          '"gacha_type" int(3) NOT NULL default \'0\','             // 卡池类型
          '"time" int(10) NOT NULL default \'0\''                   // 抽卡时间
        ');'
      );
<<<<<<< HEAD
=======
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
>>>>>>> bf52e1f8badeeb9d60ede91a40c54344d5a423a3
      await db.execute(
        'CREATE TABLE ${SRCatDatabaseConfig.userdataGameAccountsTable} ('
          '"id" TEXT NOT NULL PRIMARY KEY,'                         // UUID
          '"uid" int(10) default \'0\','                            // UID
          '"name" TEXT NOT NULL default \'\','                      // 昵称
          '"sdkey" TEXT NOT NULL default \'\','                     // MiHoYo SDK Key
          '"type" int(3) NOT NULL default \'0\','                   // 账号类型
          '"time" int(10) NOT NULL default \'0\''                   // 创建时间
        ');'
      );
    }

    Database database = await openDatabase(
      "$_base/${SRCatDatabaseConfig.userdata}",
      version: 1,
      onCreate: (Database db, int version) => onCreate(db, version),
    );

    return database;
  }

  /// 元数据 数据库
  static Future<Database> metadata() async {
    Future<void> onCreate(Database db, int version) async {
      await db.execute(
        'CREATE TABLE ${SRCatDatabaseConfig.metadataVersionTable} ('
          '"id" INTEGER NOT NULL PRIMARY KEY,'                  // ID
          '"version" TEXT NOT NULL default \'\','               // 版本
          '"lang" TEXT NOT NULL default \'\','                  // 语言
          '"game_version" TEXT NOT NULL default \'\','          // 游戏版本
          '"last_updated" TEXT NOT NULL default \'\''           // 最近一次更新时间
        ');'
      );
      await db.execute(
        'CREATE TABLE ${SRCatDatabaseConfig.metadataImageTable} ('
          '"id" TEXT NOT NULL PRIMARY KEY,'                     // UUID
          '"name" TEXT NOT NULL default \'\','                  // 图片名称
          '"parent" TEXT NOT NULL default \'\','                // 所属类别
          '"path" TEXT NOT NULL default \'\','                  // 图片路径
          '"hash" TEXT NOT NULL default \'\','                  // 哈希值
          '"last_modified" int(10) NOT NULL default \'0\''      // 最后修改时间
        ');'
      );
      await db.execute(
        'CREATE TABLE ${SRCatDatabaseConfig.metadataFilesTable} ('
          '"id" TEXT NOT NULL PRIMARY KEY,'                     // UUID
          '"name" TEXT NOT NULL default \'\','                  // 文件名称
          '"parent" TEXT NOT NULL default \'\','                // 所属类别
          '"path" TEXT NOT NULL default \'\','                  // 文件路径
          '"hash" TEXT NOT NULL default \'\','                  // 哈希值
          '"last_modified" int(10) NOT NULL default \'0\''      // 最后修改时间
        ');'
      );
    }

    Database database = await openDatabase(
      "$_base/${SRCatDatabaseConfig.metadata}",
      version: 1,
      onCreate: (Database db, int version) => onCreate(db, version),
    );

    return database;
  }
}
