/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-22 16:38:08
/// LastEditTime: 2023-07-11 04:12:27
/// FilePath: /lib/libs/srcat/warp/output.dart
/// ===========================================================================
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:srcat/models/srgf/v1.dart';

import 'package:fluent_ui/fluent_ui.dart';

import 'package:srcat/utils/file/main.dart';
import 'package:file_selector/file_selector.dart';

import 'package:srcat/riverpod/global/dialog.dart';
import 'package:srcat/libs/extensions/provider/context.dart';

import 'db.dart';
import 'data.dart';

/// 跃迁记录导出
class SRCatWarpGachaLogOutput {
  /// 导出跃迁记录
  static Future<void> output(BuildContext context, int uid) async {
    String fileName = "SRCat-SRGF-${uid.toString()}.json";

    List<XTypeGroup> acceptedTypeGroups = [
      const XTypeGroup(
        label: "SRGF 1.0",
        extensions: <String>['json'],
      )
    ];

    final FileSaveLocation? path = await getSaveLocation(
      suggestedName: fileName,
      confirmButtonText: "导出跃迁记录",
      acceptedTypeGroups: acceptedTypeGroups
    );

    if (path == null) {
      return;
    }

    List<Map<String, dynamic>>? data = await _data(uid);

    if (data == null) {
      context.read(globalDialogRiverpod).set("导出错误",
        child: const Text("导出内容为空，可能是解析失败，或是数据库为空"),
        actions: [
          Button(onPressed: () async {
            context.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            context.read(globalDialogRiverpod).clean();
          }, child: const Text("好的")),
          FilledButton(onPressed: () async {
            context.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            context.read(globalDialogRiverpod).clean();
            await Future.delayed(const Duration(milliseconds: 10));
            SRCatWarpGachaLogOutput.output(context, uid);
          }, child: const Text("重试"))
        ]
      ).show();
      return;
    }

    Map<String, dynamic> result = SRGFVer1Model.generateMap(
      uid: uid,
      regionTimeZone: 8,
      list: data
    );

    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(result);
    await SRCatFileUtils.writeStringFile(path.path, prettyprint);
  }

  /// 获取所有抽卡数据
  static Future<List<Map<String, dynamic>>?> _data(int uid) async {
    /// 从数据库取出数据
    List<Map<String, dynamic>> data = await SRCatWarpDatabaseLib.userGachaLog(uid: uid);

    if (data.isEmpty) {
      return null;
    }

    List<Map<String, dynamic>> result = [];

    GachaWarpType? parseGachaType(int type) {
      switch (type) {
        case 1:
          return GachaWarpType.regular;
        case 2:
          return GachaWarpType.starter;
        case 11:
          return GachaWarpType.character;
        case 12:
          return GachaWarpType.lightCone;
        default:
          return null;
      }
    }

    List<Map<String, dynamic>>? character = await SRCatWarpDataLib.character();
    List<Map<String, dynamic>>? lightcone = await SRCatWarpDataLib.lightcone();

    for (var item in data) {
      result.add(SRGFVer1Model.generateListDataMap(
        gachaId: item["gacha_id"],
        gachaType: parseGachaType(item["gacha_type"])!,
        itemId: item["item_id"],
        time: item["time"],
        name: await (() async {
          String name = "";
          if (item["item_type"] == "character" && character != null) {
            for (var char in character) {
              if (char["item_id"] == item["item_id"]) {
                name = char["name"];
                break;
              }
            }
          } else if (item["item_type"] == "lightcone" && lightcone != null) {
            for (var lc in lightcone) {
              if (lc["item_id"] == item["item_id"]) {
                name = lc["name"];
                break;
              }
            }
          }

          return name;
        })(),
        itemType: (() {
          String itemType = "";

          if (item["item_type"] == "character") {
            itemType = "角色";
          } else if (item["item_type"] == "lightcone") {
            itemType = "光锥";
          }

          return itemType;
        })(),
        rankType: item["rank_type"],
        rawId: item["raw_id"]
      ));
    }

    if (result.isEmpty) {
      return null;
    }

    return result;
  }
}
