/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-18 07:27:16
/// LastEditTime: 2023-05-18 08:14:17
/// FilePath: /lib/compatible/warp_db.dart
/// ===========================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/file/main.dart';
import 'package:srcat/utils/storage/main.dart';
import 'package:srcat/utils/storage/sqlite.dart';

/// 旧版数据库迁移到新版兼容类
class SRCatWaroDatabaseCompatibleUtils {
  static Future<bool> check() async {
    if (await SRCatFileUtils.fileExists("${SRCatFileUtils.getExeDir()}/data/databases/warp.db")) {
      return true;
    }

    if (await SRCatFileUtils.fileExists("${SRCatStorageUtils.read("data_path")}/old_warp.db")) {
      return true;
    }

    return false;
  }

  static Future<void> import() async {
    String path = "";
    String filename = "";
    if (await SRCatFileUtils.fileExists("${SRCatFileUtils.getExeDir()}/data/databases/warp.db")) {
      path = "${SRCatFileUtils.getExeDir()}/data/databases/";
      filename = "warp.db";
    }
    if (await SRCatFileUtils.fileExists("${SRCatStorageUtils.read("data_path")}/old_warp.db")) {
      path = "${SRCatStorageUtils.read("data_path")}/";
      filename = "old_warp.db";
    }

    if (path == "") return;

    String warpV1Table = "gacha_log";
    String warpV2Table = "warp_gacha_log";
    String oldProfile = "warp_index";

    Database database = await openDatabase("$path$filename");
    if (await _queryOldTable(database, warpV1Table)) {
      await _migrate(database, warpV1Table);
    }
    if (await _queryOldTable(database, warpV2Table)) {
      await _migrate(database, warpV2Table);
    }
    if (await _queryOldTable(database, oldProfile)) {
      await _migrateProfile(database, oldProfile);
    }

    /// 关闭数据库
    await database.close();

    /// 重命名旧数据库文件名，防止下次启动检测到
    File oldDatabaseFile = File("$path$filename");
    await oldDatabaseFile.rename("${path}old_warp.db.bak");
  }

  /// 从旧数据库迁移数据
  static Future<void> _migrate(Database db, String table) async {
    List<int> insert = [];
    List<Map<String, dynamic>> oldData;

    try {
      oldData = await db.query(table);
    } catch (e) {
      return;
    }

    Database userdata = await SRCatSQLiteUtils.userdata();

    for (var newLog in oldData) {
      if (!insert.contains(newLog["raw_id"])) {
        try {
          await userdata.insert(SRCatDatabaseConfig.userdataWarpGachaLogTable, {
            "raw_id": newLog["raw_id"],
            "uid": newLog["uid"],
            "item_id": newLog["item_id"],
            "item_type": newLog["item_type"],
            "rank_type": newLog["rank_type"],
            "gacha_id": newLog["gacha_id"],
            "gacha_type": newLog["gacha_type"],
            "time": newLog["time"],
          });
        } catch (e) {
          if (kDebugMode) print("数据存在，跳过插入");
        }

        insert.add(newLog["raw_id"]);
      }
    }
  }

  /// 从旧数据库导入用户档案
  static Future<void> _migrateProfile(Database db, String table) async {
    List<int> insert = [];
    List<Map<String, dynamic>> oldData;

    try {
      oldData = await db.query(table);
    } catch (e) {
      return;
    }

    Database userdata = await SRCatSQLiteUtils.userdata();

    for (var newProfile in oldData) {
      if (!insert.contains(newProfile["uid"])) {
        try {
          await userdata.insert(SRCatDatabaseConfig.userdataWarpIndexTable, {
            "uid": newProfile["uid"],
            "created": newProfile["created"],
          });
        } catch (e) {
          if (kDebugMode) print("数据存在，跳过插入");
        }

        insert.add(newProfile["uid"]);
      }
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
