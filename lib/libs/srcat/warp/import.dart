/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-22 18:38:54
/// LastEditTime: 2023-07-20 04:10:59
/// FilePath: /lib/libs/srcat/warp/import.dart
/// ===========================================================================
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:srcat/application.dart';
import 'package:srcat/models/srgf/v1.dart';

import 'package:fluent_ui/fluent_ui.dart';

import 'package:srcat/utils/file/main.dart';
import 'package:file_selector/file_selector.dart';

import 'package:srcat/utils/main.dart';
import 'package:srcat/riverpod/global/dialog.dart';
import 'package:srcat/libs/extensions/provider/context.dart';

import 'db.dart';

/// 跃迁记录导入
class SRCatWarpGachaLogImport {
  /// 请求导入跃迁记录
  static Future<void> import(BuildContext context) async {
    const XTypeGroup typeGroup = XTypeGroup(label: "SRGF", extensions: <String>["json"]);
    XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
      confirmButtonText: "打开并导入跃迁数据"
    );

    if (file?.path == null || file?.name == null) {
      return;
    }

    Map<String, dynamic> importMap = {};

    List<Widget> errActions = [
      FilledButton(onPressed: () async {
        SRCatWarpGachaLogImport.import(context);
        await Future.delayed(const Duration(milliseconds: 10));
        context.read(globalDialogRiverpod).hidden();
        await Future.delayed(const Duration(milliseconds: 200));
        context.read(globalDialogRiverpod).clean();
      }, child: const Text("重新选择")),
      Button(onPressed: () async {
        context.read(globalDialogRiverpod).hidden();
        await Future.delayed(const Duration(milliseconds: 200));
        context.read(globalDialogRiverpod).clean();
      }, child: const Text("取消导入")),
    ];

    // 读取并解析
    try {
      importMap = json.decode(await SRCatFileUtils.readFile(file!.path));
    } catch (e) {
      context.read(globalDialogRiverpod).set("错误",
        child: const Text("导入数据格式不正确"),
        actions: errActions
      ).show();
      return;
    }

    /// 解析版本
    if (importMap["info"] == null || importMap["info"]["srgf_version"] == null) {
      context.read(globalDialogRiverpod).set("错误",
        child: const Text("导入数据为未知版本的 SRGF 存档，或是非 SRGF 存档记录。"),
        actions: errActions
      ).show();
      return;
    }

    if (
      importMap["info"]["srgf_version"].toString().toLowerCase() == "v1.0" ||
      importMap["info"]["srgf_version"].toString() == "1.0"
    ) {
      if (!SRGFVer1Model.validate(importMap)) {
        context.read(globalDialogRiverpod).set("错误",
          child: const Text("导入数据校验失败，可能是非标准的 SRGF 存档"),
          actions: errActions
        ).show();
        return;
      }
    } else {
      context.read(globalDialogRiverpod).set("导入失败",
        child: Text("导入数据的 SRGF 版本为 ${importMap["info"]["srgf_version"].toString()}，而目前 SRCat 支持的 SRGF 版本为 v1.0"),
        actions: errActions
      ).show();
      return;
    }

    Widget info({
      required String title,
      required String value
    }) {
      return SizedBox(
        height: 40,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(title)),
            Text(value)
          ],
        )
      );
    }
    
    context.read(globalDialogRiverpod).set("导入跃迁记录",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          info(title: "UID", value: importMap["info"]["uid"]),
          info(title: "记录数量", value: (importMap["list"]).length.toString()),
          info(title: "导出时间", value: SRCatUtils.unixTimeToStr(
            int.parse(importMap["info"]["export_timestamp"].toString()),
            format: "yyyy-MM-dd HH:mm:ss"
          )),
          info(title: "导出 APP", value: importMap["info"]["export_app"]),
          info(title: "导出 APP 版本", value: importMap["info"]["export_app_version"]),
          info(title: "SRGF 版本", value: importMap["info"]["srgf_version"]),
        ],
      ),
      actions: [
        FilledButton(onPressed: () {
          _importToSRCat(importMap, context);
        }, child: const Text("导入")),
        Button(onPressed: () async {
          context.read(globalDialogRiverpod).hidden();
          await Future.delayed(const Duration(milliseconds: 200));
          context.read(globalDialogRiverpod).clean();
        }, child: const Text("取消")),
      ]
    ).show();
  }

  /// 导入跃迁数据到数据库
  static Future<void> _importToSRCat(Map<String, dynamic> data, BuildContext context) async {
    context.read(globalDialogRiverpod).set("导入跃迁记录",
      child: const SizedBox(width: double.infinity, child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: double.infinity, child: ProgressBar())
        ],
      )),
      cacheActions: false,
      actions: null
    );

    // 从数据库中查询 UID 是否存在
    bool hasUser = await SRCatWarpDatabaseLib.hasUser(uid: int.parse(data["info"]["uid"].toString()));

    if (!hasUser) {
      await SRCatWarpDatabaseLib.insertWarpUser(uid: int.parse(data["info"]["uid"].toString()));
    }

    int importDone = 0;
    int importBreak = 0;

    for (Map<String, dynamic> item in data["list"]) {
      List<Map<String, dynamic>> gachaItem = await SRCatWarpDatabaseLib.userGachaLog(
        uid: int.parse(data["info"]["uid"].toString()),
        rawId: int.parse(item["id"].toString()),
        gachaType: int.parse(item["gacha_type"].toString()),
      );

      if (gachaItem.isEmpty) {
        await SRCatWarpDatabaseLib.insertUserGachaLog(
          rawId: int.parse(item["id"].toString()),
          uid: int.parse(data["info"]["uid"].toString()),
          gachaId: int.parse(item["gacha_id"].toString()),
          gachaType: (() {
            switch (int.parse(item["gacha_type"].toString())) {
              case 1:
                return gachaWarpTypeValue[GachaWarpType.regular]!;
              case 2:
                return gachaWarpTypeValue[GachaWarpType.starter]!;
              case 11:
                return gachaWarpTypeValue[GachaWarpType.character]!;
              case 12:
                return gachaWarpTypeValue[GachaWarpType.lightCone]!;
              default:
                return 0;
            }
          })(),
          itemId: int.parse(item["item_id"].toString()),
          itemType: (() {
            if (item["item_type"] == "character" || item["item_type"] == "角色") {
              return "character";
            }
            if (item["item_type"] == "lightcone" || item["item_type"] == "光锥") {
              return "lightcone";
            }

            return "";
          })(),
          rankType: int.parse(item["rank_type"].toString()),
          time: SRCatUtils.strToUnixTime(item["time"].toString())
        );
        importDone = importDone + 1;
      } else {
        importBreak = importBreak + 1;
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));

    context.read(globalDialogRiverpod).set("导入完成",
      child: Text("跃迁记录总 ${(data["list"]).length.toString()} 条，成功导入 $importDone 条记录，跳过 $importBreak 条记录。"),
      actions: [
        FilledButton(
          onPressed: () async {
            context.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            context.read(globalDialogRiverpod).clean();
            await Future.delayed(const Duration(milliseconds: 10));
            Application.router.push("/tools/warp?uid=${data["info"]["uid"]}");
          },
          child: const Text("好的"),
        )
      ]
    ).show();
  }
}
