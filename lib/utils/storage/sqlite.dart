/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 23:30:14
/// LastEditTime: 2023-05-27 19:08:52
/// FilePath: /lib/utils/storage/sqlite.dart
/// ===========================================================================

import 'main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';

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
      await db.execute(
        'CREATE TABLE ${SRCatDatabaseConfig.userdataUserAccountsTable} ('
          '"id" TEXT NOT NULL PRIMARY KEY,'                         // UUID
          '"select" int(1) NOT NULL default \'0\','                 // 是否选中当前账号
          '"aid" TEXT NOT NULL default \'\','                       // aid
          '"mid" TEXT NOT NULL default \'\','                       // mid
          '"uid" TEXT NOT NULL default \'\','                       // uid
          '"ltoken" TEXT NOT NULL default \'\','                    // LToken
          '"stoken" TEXT NOT NULL default \'\','                    // SToken
          '"cookie_token" TEXT NOT NULL default \'\''               // Cookie Token
        ');'
      );
    }

    Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
      if ((await db.rawQuery("select * from Sqlite_master where type = 'table' and name = '${SRCatDatabaseConfig.userdataUserAccountsTable}'")).isEmpty) {
        await db.execute(
          'CREATE TABLE ${SRCatDatabaseConfig.userdataUserAccountsTable} ('
            '"id" TEXT NOT NULL PRIMARY KEY,'                         // UUID
            '"select" int(1) NOT NULL default \'0\','                 // 是否选中当前账号
            '"aid" TEXT NOT NULL default \'\','                       // aid
            '"mid" TEXT NOT NULL default \'\','                       // mid
            '"uid" TEXT NOT NULL default \'\','                       // uid
            '"ltoken" TEXT NOT NULL default \'\','                    // LToken
            '"stoken" TEXT NOT NULL default \'\','                    // SToken
            '"cookie_token" TEXT NOT NULL default \'\''               // Cookie Token
          ');'
        );
      }
    }

    Database database = await openDatabase(
      "$_base/${SRCatDatabaseConfig.userdata}",
      version: 2,
      onCreate: (Database db, int version) => onCreate(db, version),
      onUpgrade: (Database db, int oldVersion, int newVersion) => onUpgrade(db, oldVersion, newVersion),
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
