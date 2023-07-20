/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-16 12:25:48
/// LastEditTime: 2023-07-21 03:47:21
/// FilePath: /lib/libs/metadata/db.dart
/// ===========================================================================

import 'package:sqflite/sqflite.dart';
import 'package:srcat/config/db.dart';
import 'package:srcat/utils/main.dart';
import 'package:srcat/utils/storage/sqlite.dart';

class SRCatMetadataDatabaseLib {
  static final String _fileTable = SRCatDatabaseConfig.metadataFilesTable;
  static final String _imagesTable = SRCatDatabaseConfig.metadataImageTable;
  static final String _versionTable = SRCatDatabaseConfig.metadataVersionTable;

  /// 保存文件信息
  static Future<void> saveFileInfo({
    required String id,
    required String name,
    required String parent,
    required String hash,
    required String path,
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      await database.insert(_fileTable, {
        "id": id,
        "name": name,
        "path": path,
        "hash": hash,
        "parent": parent,
        "last_modified": SRCatUtils.getUnixTime(),
      });
    } catch (e) {
      return;
    }
  }

  /// 更新文件信息
  static Future<void> updateFileInfo({
    required String id,
    required String name,
    required String parent,
    required String hash,
    required String path,
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      await database.update(_fileTable,
        {
          "name": name,
          "path": path,
          "parent": parent,
          "hash": hash,
          "last_modified": SRCatUtils.getUnixTime()
        },
        where: "id=?",
        whereArgs: [id]
      );
    } catch (e) {
      return;
    }
  }

  /// 删除文件信息
  static Future<void> deleteFileInfo({
    required String id
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      await database.rawDelete(
        'DELETE FROM $_fileTable'
          ' WHERE id=$id'
        ';'
      );
    } catch (e) {
      return;
    }
  }

  /// 查询文件信息
  static Future<List<Map<String, dynamic>>> getFileInfo({
    String? id,
    String? name
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      String nameHasWhere = (id != null) ? " AND " : "";

      List<Map<String, Object?>> result = await database.rawQuery(
        'SELECT * FROM $_fileTable'
          '${id != null ? " WHERE id='$id'" : ""}'
          '${name != null ? "$nameHasWhere WHERE name='$name'" : ""}'
        ';'
      );

      return result;
    } catch (e) {
      return [];
    }
  }

  /// 保存图片信息
  static Future<void> saveImageInfo({
    required String id,
    required String name,
    required String parent,
    required String hash,
    required String path,
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      await database.insert(_imagesTable, {
        "id": id,
        "name": name,
        "path": path,
        "hash": hash,
        "parent": parent,
        "last_modified": SRCatUtils.getUnixTime(),
      });
    } catch (e) {
      return;
    }
  }

  /// 更新图片信息
  static Future<void> updateImageInfo({
    required String id,
    required String name,
    required String parent,
    required String hash,
    required String path,
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      await database.update(_imagesTable,
        {
          "name": name,
          "path": path,
          "parent": parent,
          "hash": hash,
          "last_modified": SRCatUtils.getUnixTime()
        },
        where: "id=?",
        whereArgs: [id]
      );
    } catch (e) {
      return;
    }
  }

  /// 删除图片信息
  static Future<void> deleteImageInfo({
    required String id
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      await database.rawDelete(
        'DELETE FROM $_imagesTable'
          ' WHERE id=$id'
        ';'
      );
    } catch (e) {
      return;
    }
  }

  /// 查询图片信息
  static Future<List<Map<String, dynamic>>> getImageInfo({
    required String? id
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      List<Map<String, Object?>> result = await database.query(_imagesTable,
        where: "id=?",
        whereArgs: [id]
      );

      return result;
    } catch (e) {
      return [];
    }
  }

  /// 增加版本信息
  static Future<void> insertVersion({
    required String version,
    required String lang,
    required String gameVersion,
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      await database.insert(_versionTable, {
        "version": version,
        "lang": lang,
        "game_version": gameVersion,
        "last_updated": SRCatUtils.getUnixTime(),
      });
    } catch (e) {
      return;
    }
  }

  /// 查询版本信息
  static Future<List<Map<String, dynamic>>> getVersionInfo({
    String? version,
    String? lang,
    String? gameVersion
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      String langHasWhere = (version != null) ? " AND " : "";
      String gameVersionHasWhere = (version != null || lang != null) ? " AND " : "";

      List<Map<String, Object?>> result = await database.rawQuery(
        'SELECT * FROM $_versionTable'
          '${version != null ? " WHERE version='$version'" : ""}'
          '${lang != null ? "$langHasWhere WHERE lang='$lang'" : ""}'
          '${gameVersion != null ? "$gameVersionHasWhere WHERE game_version='$gameVersion'" : ""}'
          ' ORDER BY'
          ' version DESC'
        ';'
      );

      return result;
    } catch (e) {
      return [];
    }
  }

  /// 更新指定版本信息
  static Future<void> updateVersion({
    required String version,
    required String lang,
    required String gameVersion,
  }) async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      List<Map<String, Object?>> result = await database.query(_versionTable,
        where: "version=? and lang=? and game_version=?",
        whereArgs: [version, lang, gameVersion]
      );
      if (result.isNotEmpty) {
        await database.update(_versionTable, {
          "last_updated": SRCatUtils.getUnixTime(),
        }, where: "id=?", whereArgs: [result[0]["id"]]);
      }
    } catch (e) {
      return;
    }
  }

  /// 获取所有图片信息
  static Future<List<Map<String, dynamic>>> getAllImagesInfo() async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      List<Map<String, Object?>> result = await database.query(_imagesTable);
      return result;
    } catch (e) {
      return [];
    }
  }


  /// 查询所有文件信息
  static Future<List<Map<String, dynamic>>> getAllFileInfo() async {
    Database database = await SRCatSQLiteUtils.metadata();

    try {
      List<Map<String, Object?>> result = await database.query(_fileTable);
      return result;
    } catch (e) {
      return [];
    }
  }
}
