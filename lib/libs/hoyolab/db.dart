/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-27 14:22:36
/// LastEditTime: 2023-05-27 20:56:55
/// FilePath: /lib/libs/hoyolab/db.dart
/// ===========================================================================

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/storage/sqlite.dart';

class HoYoLabDatabaseLib {
  static final String _userTable = SRCatDatabaseConfig.userdataUserAccountsTable;

  /// 通过 DeviceId 查询用户是否存在
  static Future<bool> hasUser(String deviceId) async {
    bool hasUser = false;
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      List<Map<String, dynamic>> result = await database.query(_userTable,
        where: "id=?",
        whereArgs: [deviceId]
      );

      if (result.isNotEmpty) {
        hasUser = true;
      }
    } catch (e) {
      hasUser = false;
    }

    return hasUser;
  }

  /// 获取所有用户
  static Future<List<Map<String, dynamic>>> allUsers() async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      List<Map<String, dynamic>> result = await database.query(_userTable);
      return result;
    } catch (e) {
      return [];
    }
  }

  /// 添加用户
  static Future<void> insertUser({
    required String deviceId,
    required String aid,
    required String uid,
    required String mid,
    required String ltoken,
    required String stoken,
    required String cookieToken,
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      database.insert(_userTable, {
        "id": deviceId,
        "aid": aid,
        "uid": uid,
        "mid": mid,
        "ltoken": ltoken,
        "stoken": stoken,
        "cookie_token": cookieToken
      });
    } catch (e) {
      return;
    }
  }

  /// 更新用户
  static Future<void> updateUser({
    required String deviceId,
    String? aid,
    String? mid,
    String? ltoken,
    String? stoken,
    String? cookieToken,
  }) async {
    Database database = await SRCatSQLiteUtils.userdata();
    Map<String, dynamic> updateMap = {};
    if (aid != null) {
      updateMap.addEntries({
        "aid": aid
      }.entries);
    }

    if (mid != null) {
      updateMap.addEntries({
        "mid": mid
      }.entries);
    }
    
    if (ltoken != null) {
      updateMap.addEntries({
        "ltoken": ltoken
      }.entries);
    }
    
    if (stoken != null) {
      updateMap.addEntries({
        "stoken": stoken
      }.entries);
    }
    
    if (cookieToken != null) {
      updateMap.addEntries({
        "cookieToken": cookieToken
      }.entries);
    }

    /// 为空则不需要更新
    if (updateMap.isEmpty) {
      return;
    }

    try {
      database.update(_userTable, updateMap,
        where: "id=?",
        whereArgs: [deviceId]
      );
    } catch (e) {
      return;
    }
  }

  /// 选中用户
  static Future<void> selectUser(String deviceId) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      database.update(_userTable, {
        "select": 0
      });
    } catch (e) {
      return;
    }

    try {
      database.update(_userTable,
        {
          "select": 1,
        },
        where: "id=?",
        whereArgs: [deviceId]
      );
    } catch (e) {
      return;
    }
  }

  /// 删除用户
  static Future<void> deleteUser(String deviceId) async {
    Database database = await SRCatSQLiteUtils.userdata();

    try {
      database.delete(_userTable,
        where: "id=?",
        whereArgs: [deviceId]
      );
    } catch (e) {
      return;
    }
  }
}
