/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 10:13:07
/// LastEditTime: 2023-07-20 03:58:44
/// FilePath: /lib/libs/srcat/warp/update.dart
/// ===========================================================================
// ignore_for_file: use_build_context_synchronously

import 'package:srcat/application.dart';
import 'package:flutter/foundation.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:srcat/riverpod/global/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:srcat/utils/main.dart';

import 'db.dart';
import 'main.dart';

class SRCatWarpUpdateLib {
  static int _refreshUID = 0;
  static bool _hasError = false;
  static String _errorMsg = "";
  static late GachaGetType gachaGetType;
  static ProviderContainer provider = Application.globalProviderScope;
  static Map<String, dynamic>? _stokenData = {};
  static String _userInptLink = "";

  /// 入口
  static Future<Map<String, dynamic>> init(GachaGetType type, { Map<String, dynamic>? stokenData, String? userInptLink }) async {
    gachaGetType = type;
    _stokenData = stokenData;
    _userInptLink = userInptLink ?? "";
    provider.read(globalDialogRiverpod).set("提示", child: const Text("获取数据中..."), cacheActions: false, actions: null).show();
    await Future.delayed(const Duration(milliseconds: 100));
    await _character();
    await Future.delayed(const Duration(milliseconds: 100));
    await _lightcone();
    await Future.delayed(const Duration(milliseconds: 100));
    await _regular();
    await Future.delayed(const Duration(milliseconds: 100));
    await _starter();
    await Future.delayed(const Duration(milliseconds: 100));
    provider.read(globalDialogRiverpod).hidden();
    await Future.delayed(const Duration(milliseconds: 200));
    provider.read(globalDialogRiverpod).clean();

    return {
      "refreshUID": _refreshUID,
      "hasError": _hasError,
      "errorMsg": _errorMsg,
    };
  }

  /// 判断数据库中是否包含相同抽卡记录
  static Future<bool> _isSameData(int uid, GachaWarpType warpType, int rawId,) async {
    List<Map<String, dynamic>> gachaItem = await SRCatWarpDatabaseLib.userGachaLog(
      uid: uid,
      rawId: rawId,
      gachaType: gachaWarpTypeValue[warpType]
    );

    return gachaItem.isNotEmpty ? true : false;
  }

  /// 获取 UP 池数据
  static Future<void> _character() async {
    await _gachaLogData(title: "角色活动", warpType: GachaWarpType.character);
  }
  /// 获取 UP 光锥池
  static Future<void> _lightcone() async {
    await _gachaLogData(title: "流光定影", warpType: GachaWarpType.lightCone);
  }
  /// 获取常驻池
  static Future<void> _regular() async {
    await _gachaLogData(title: "群星跃迁", warpType: GachaWarpType.regular);
  }
  /// 获取新手池
  static Future<void> _starter() async {
    await _gachaLogData(title: "始发跃迁", warpType: GachaWarpType.starter);
  }

  /// 获取卡池数据
  static Future<void> _gachaLogData({
    required String title,
    GachaWarpType warpType = GachaWarpType.character
  }) async {
    int page = 1;
    int size = 20;
    bool isEnd = false;
    int uid = 0;
    int endId = 0;
    List<dynamic> firstData = [];
    bool firstSame = false;

    /// 有错误直接终止
    if (_hasError) return;

    /// 从数据库中获取所有用户
    List<Map<String, dynamic>> allUser = await SRCatWarpDatabaseLib.allWarpUser();

    /// 预先请求一次，获取 uid
    await SRCatWarpLib.getGachaData(
      type: gachaGetType,
      stokenData: _stokenData,
      userInptLink: _userInptLink,
      success: (response, data) async {
        if (data is Map<String, dynamic>) {
          if (data["retcode"] != 0) {
            return;
          }
          firstData = data["data"]["list"];

          if (firstData.isEmpty) return;

          uid = int.parse(firstData[0]?["uid"] ?? "0");
          _refreshUID = uid;

          /// 显示进度弹窗
          provider.read(globalDialogRiverpod).set(title, child: const Text("正在获取第 1 页数据..."));
        } else {
          isEnd = true;
        }
      },
      fail: (code, message, failType, dioError) {
        _hasError = true;
        _errorMsg = message;
      },
      page: page,
      size: size,
      endId: endId,
      warpType: warpType
    );

    if (uid == 0) {
      return;
    }

    bool hasUser = false;
    for (var user in allUser) {
      /// 判断用户是否存在，不存在则新建用户
      int nowId = 0;
      if (user["uid"] is int) nowId = user["uid"];
      if (user["uid"] is String) nowId = int.parse(user["uid"]);

      if (uid == nowId) {
        hasUser = true;
        break;
      }
    }
    if (!hasUser) {
      await SRCatWarpDatabaseLib.insertWarpUser(uid: uid);
    }

    for (var log in firstData) {
      if (await _isSameData(uid, warpType, int.parse(log["id"]))) {
        firstSame = true;
        break;
      }

      String itemType = "";
      if (log["item_type"] == "光锥") itemType = "lightcone";
      if (log["item_type"] == "角色") itemType = "character";

      /// 写入数据库
      await SRCatWarpDatabaseLib.insertUserGachaLog(
        rawId: int.parse(log["id"]),
        uid: int.parse(log["uid"]),
        gachaId: int.parse(log["gacha_id"]),
        gachaType: gachaWarpTypeValue[warpType]!,
        itemId: int.parse(log["item_id"]),
        itemType: itemType,
        rankType: int.parse(log["rank_type"]),
        time: SRCatUtils.strToUnixTime(log["time"]),
      );
    }

    if (firstSame) return;

    /// 如果当前数据条数少于每页条数，则已到末页
    /// 不用继续请求
    if (firstData.length < size) return;

    /// 循环请求之前，页数先加一
    page = page + 1;
    /// 顺带赋值 end_id
    endId = int.parse(firstData[firstData.length - 1]["id"]);
    /// 循环请求
    while (true) {
      if (isEnd) break;
      /// 显示进度弹窗
      provider.read(globalDialogRiverpod).set(title, child: Text("正在获取第 $page 页数据..."));
      if (kDebugMode) print("当前页数：$page");
      await SRCatWarpLib.getGachaData(
        type: gachaGetType,
        stokenData: _stokenData,
        userInptLink: _userInptLink,
        success: (response, data) async {
          if (data is Map<String, dynamic>) {
            if (data["data"].isEmpty) return;
            List<dynamic> list = data["data"]?["list"];

            /// 遍历列表
            for (var log in list) {
              if (await _isSameData(uid, warpType, int.parse(log["id"]))) {
                if (kDebugMode) print("while:存在相同的记录，跳过插入。");
                break;
              }

              String itemType = "";
              if (log["item_type"] == "光锥") itemType = "lightcone";
              if (log["item_type"] == "角色") itemType = "character";

              /// 写入数据库
              await SRCatWarpDatabaseLib.insertUserGachaLog(
                rawId: int.parse(log["id"]),
                uid: int.parse(log["uid"]),
                gachaId: int.parse(log["gacha_id"]),
                gachaType: gachaWarpTypeValue[warpType]!,
                itemId: int.parse(log["item_id"]),
                itemType: itemType,
                rankType: int.parse(log["rank_type"]),
                time: SRCatUtils.strToUnixTime(log["time"]),
              );
              if (kDebugMode) print("while: 插入数据成功");
            }

            /// 如果当前列表条数小于每页条数，则已到末页
            if (list.length < size) {
              isEnd = true;
              if (kDebugMode) print("while: 页数小于每页条数");
              return;
            }

            /// 每次执行完 Success 方法后，给 endId 赋值
            endId = int.parse(list[list.length - 1]["id"]);
          }
        },
        fail: (code, message, failType, dioError) {},
        page: page,
        size: size,
        endId: endId,
        warpType: warpType
      );

      page = page + 1;

      /// 每五页休息 5 秒
      if (page % 10 == 0) {
        await Future.delayed(const Duration(seconds: 6));
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }
}
