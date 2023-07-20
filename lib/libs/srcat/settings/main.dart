/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-07-21 00:15:04
/// LastEditTime: 2023-07-21 01:10:18
/// FilePath: /lib/libs/srcat/settings/main.dart
/// ===========================================================================

export "package:srcat/config/settings_db.dart";

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/storage/sqlite.dart';

class SRCatSettingsDatabaseLib {
  static final String _table = SRCatDatabaseConfig.userdataSettingsTable;
  
  /// 获取设置项
  static Future<String?> get({
    required String option,
    String? defaultValue,
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      List<Map<String, Object?>> result = await database.query(_table,
        where: "option=?",
        whereArgs: [option]
      );

      if (result.isEmpty) {
        return defaultValue;
      } else {
        return result[0]["value"]?.toString() ?? defaultValue;
      }
    } catch (e) {
      return defaultValue;
    }
  }

  /// 保存或更新设置项
  static Future<void> save({
    required String option,
    String? value,
  }) async {
    bool hasOption = false;
    Database database = await SRCatSQLiteUtils.userdata();

    /// 判断设置项是否存在
    try {
      List<Map<String, Object?>> result = await database.query(_table,
        where: "option=?",
        whereArgs: [option]
      );

      if (result.isNotEmpty) {
        hasOption = true;
      }
    } catch (e) {
      return;
    }

    try {
      if (!hasOption) {
        await database.insert(_table, {
          "option": option,
          "value": value
        });
      } else {
        await database.update(_table,
          {
            "value": value
          },
          where: "option=?",
          whereArgs: [option]
        );
      }
    } catch (e) {
      return;
    }
  }
}
