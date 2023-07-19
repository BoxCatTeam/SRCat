/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-25 01:23:45
/// LastEditTime: 2023-07-20 03:05:50
/// FilePath: /lib/libs/user/main.dart
/// ===========================================================================

import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:srcat/application.dart';
import 'package:srcat/libs/hoyolab/bbs.dart';
import 'package:srcat/libs/hoyolab/db.dart';
import 'package:srcat/libs/hoyolab/main.dart';
import 'package:srcat/libs/hoyolab/qrcode.dart';
import 'package:srcat/libs/hoyolab/role.dart';
import 'package:srcat/riverpod/global/user.dart';
import 'package:srcat/utils/main.dart';
import 'package:srcat/utils/webview2/main.dart';
import 'package:srcat/riverpod/global/dialog.dart';
import 'package:webview_windows/webview_windows.dart';

class SRCatMHYUserLib {
  /// 以 Cookie 方式登录
  static Future<void> cookieLogin() async {
    Application.globalProviderScope.read(globalDialogRiverpod).set(
      "Cookie 登录",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextBox(
            placeholder: "输入包含 SToken 的 Cookie",
            minLines: 1,
            maxLines: 10,
            onChanged: (value) {}
          )
        ],
      ),
      actions: <Widget>[
        FilledButton(onPressed: () {

        }, child: const Text("登录")),
        Button(onPressed: () async {
          Application.globalProviderScope.read(globalDialogRiverpod).hidden();
          await Future.delayed(const Duration(milliseconds: 200));
          Application.globalProviderScope.read(globalDialogRiverpod).clean();
        }, child: const Text("取消"))
      ]
    ).show();
  }

  /// Web 登录
  static Future<void> startWebLogin(WebviewController controller) async {
    Widget cancel = FilledButton(onPressed: () async {
      Application.globalProviderScope.read(globalDialogRiverpod).hidden();
      await Future.delayed(const Duration(milliseconds: 200));
      Application.globalProviderScope.read(globalDialogRiverpod).clean();
    }, child: const Text("好的"));
    
    String? rawCookies = await controller.getCookies();
    if (rawCookies == null || rawCookies == "") {
      Application.globalProviderScope.read(globalDialogRiverpod).set(
        "提示",
        child: const Text("未检测到 Cookie，请确认是否登录。"),
        actions: [cancel]
      ).show();
      return;
    }

    Map<String, String> cookies = SRCatWebView2HelperUtils.strCookieToMap(rawCookies);

    if (cookies["login_ticket"] == "" || cookies["login_uid"] == "") {
      Application.globalProviderScope.read(globalDialogRiverpod).set(
        "提示",
        child: const Text("未检测到 Cookie，请确认是否登录。"),
        actions: [cancel]
      ).show();
      return;
    }

    bool result = await _webLogin((cookies["login_ticket"] ?? "").toString(), (cookies["login_uid"] ?? "").toString(), controller);
    if (result) {
      try {
        await controller.dispose();
      } catch (e) {
        if (kDebugMode) print("销毁 WebView 时遇到错误：$e");
      }
      Application.router.push("/home");
    }
  }

  /// 刷新当前账号
  static Future<void> refreshCurrentAcc() async {
    String deviceId = Application.globalProviderScope.read(globalUserManagerRiverpod).nowSelectUser;

    if (deviceId == "") return;

    Map<String, dynamic>? user = await HoYoLabDatabaseLib.user(deviceId: deviceId);
    if (user == null) return;

    Map<String, dynamic>? userinfo = await HoYoLabBBSLib.selfInfo(
      stoken: user["stoken"].toString(),
      uid: user["uid"].toString(),
      mid: user["mid"].toString(),
      deviceId: user["id"].toString(),
    );

    Map<String, dynamic> roleList = {
      "role": []
    };

    if (userinfo != null) {
      List<Map<String, dynamic>>? roles = await HoYoLabGameRolesLib.stokenGetRoles(
        stoken: user["stoken"].toString(),
        uid: user["uid"].toString(),
        mid: user["mid"].toString(),
        deviceId: user["id"].toString(),
        ltoken: user["ltoken"].toString(),
      );
      if (roles != null && roles.isNotEmpty) {
        roleList = {
          "role": roles
        };
      }
    }

    Map<String, dynamic> userInfoMap = {
      ...user,
      ...roleList,
      "avatar": (userinfo?["avatar"] ?? "").toString(),
      "nickname": (userinfo?["nickname"] ?? "").toString(),
    };

    Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
      deviceId,
      aid: userInfoMap["aid"].toString(),
      uid: userInfoMap["uid"].toString(),
      mid: userInfoMap["mid"].toString(),
      ltoken: userInfoMap["ltoken"].toString(),
      stoken: userInfoMap["stoken"].toString(),
      cookieToken: userInfoMap["cookie_token"].toString(),
      avatar: userInfoMap["avatar"].toString(),
      isExpired: false,
      nickname: userInfoMap["nickname"].toString(),
      role: userInfoMap["role"]
    );
  }

  /// 登录流程
  static Future<bool> _webLogin(String loginTicket, String loginUid, WebviewController controller) async {
    void errDialog({
      String? title,
      String? desc
    }) {
      Application.globalProviderScope.read(globalDialogRiverpod).set(
        title ?? "登录失败",
        child: Text(desc ?? "登录时遇到错误，无法获取登录凭据"),
        actions: [
          FilledButton(onPressed: () async {
            Application.globalProviderScope.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            Application.globalProviderScope.read(globalDialogRiverpod).clean();
            Application.router.push("/webview/hoyolab/login");
          }, child: const Text("重试")),
          Button(onPressed: () async {
            Application.globalProviderScope.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            Application.globalProviderScope.read(globalDialogRiverpod).clean();
            try {
              await controller.dispose();
            } catch (e) {
              if (kDebugMode) print("销毁 WebView 时遇到错误：$e");
            }
            Application.router.push("/home");
          }, child: const Text("取消"))
        ]
      ).show();
    }
    
    if (loginTicket.isEmpty || loginUid.isEmpty) {
      errDialog(title: "操作取消", desc: "未检测到登录状态，操作已被取消");
      return false;
    }

    Map<String, String>? muiltToken;
    muiltToken = await HoYoLabLib.generatedMuiltToken(loginTicket: loginTicket, loginUid: loginUid);

    if (muiltToken == null) {
      errDialog();
      return false;
    }

    Map<String, String>? v2Stoken = await HoYoLabLib.getV2StokenBySToekn(v1Stoken: muiltToken["stoken"].toString(), v1Uid: loginUid);
    
    if (v2Stoken == null) {
      errDialog();
      return false;
    }

    String? cookieToken = await HoYoLabLib.getCookieToken(
      uid: loginUid,
      v2Stoken: v2Stoken["token"].toString(),
      mid: v2Stoken["mid"].toString(),
      deviceId: v2Stoken["deviceId"].toString()
    );

    /// 判断用户是否存在
    if (await HoYoLabDatabaseLib.hasUser(v2Stoken["deviceId"].toString())) {
      // 更新
      await HoYoLabDatabaseLib.updateUser(
        deviceId: v2Stoken["deviceId"].toString(),
        aid: v2Stoken["aid"].toString(),
        mid: v2Stoken["mid"].toString(),
        ltoken: muiltToken["ltoken"].toString(),
        stoken: v2Stoken["token"].toString(),
        cookieToken: cookieToken
      );
      Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
        v2Stoken["deviceId"].toString(),
        aid: v2Stoken["aid"].toString(),
        uid: loginUid,
        mid: v2Stoken["mid"].toString(),
        ltoken: muiltToken["ltoken"].toString(),
        stoken: v2Stoken["token"].toString(),
        cookieToken: cookieToken ?? "",
        isExpired: false,
      );
    } else {
      // 添加
      await HoYoLabDatabaseLib.insertUser(
        deviceId: v2Stoken["deviceId"].toString(),
        aid: v2Stoken["aid"].toString(),
        uid: loginUid,
        mid: v2Stoken["mid"].toString(),
        ltoken: muiltToken["ltoken"].toString(),
        stoken: v2Stoken["token"].toString(),
        cookieToken: cookieToken ?? ""
      );

      Application.globalProviderScope.read(globalUserManagerRiverpod).addUser(
        id: v2Stoken["deviceId"].toString(),
        aid: v2Stoken["aid"].toString(),
        uid: loginUid,
        mid: v2Stoken["mid"].toString(),
        ltoken: muiltToken["ltoken"].toString(),
        stoken: v2Stoken["token"].toString(),
        cookieToken: cookieToken ?? "",
        avatar: "",
        isExpired: false,
        nickname: "",
        role: []
      );
    }

    // 异步获取用户信息
    HoYoLabBBSLib.selfInfo(
      stoken: v2Stoken["token"].toString(),
      uid: loginUid,
      mid: v2Stoken["mid"].toString(),
      deviceId: v2Stoken["deviceId"].toString()
    ).then((userinfo) {
      if (userinfo == null) {
        return false;
      }

      Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
        v2Stoken["deviceId"].toString(),
        nickname: userinfo["nickname"].toString(),
        avatar: userinfo["avatar"].toString()
      );

      // 异步获取角色信息
      HoYoLabGameRolesLib.stokenGetRoles(
        stoken: v2Stoken["token"].toString(),
        uid: loginUid,
        mid: v2Stoken["mid"].toString(),
        deviceId: v2Stoken["deviceId"].toString(),
        ltoken: muiltToken!["ltoken"].toString(),
      ).then((roles) {
        if (roles != null && roles.isNotEmpty) {
          Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
            v2Stoken["deviceId"].toString(),
            role: roles
          );
        }
      });
    });

    Application.globalProviderScope.read(globalDialogRiverpod).hidden();
    await Future.delayed(const Duration(milliseconds: 200));
    Application.globalProviderScope.read(globalDialogRiverpod).clean();

    return true;
  }

  // 二维码方式登录
  static Future<void> qrcodeLogin() async {
    

    String deviceId = SRCatUtils.getUUIDv4();
    HoYoLabQRCodeLib qrcodeLib = HoYoLabQRCodeLib();
    qrcodeLib.setDeviceId(deviceId);
    qrcodeLib.setOnConfirmed((String uid, String gameToken) async {
      Application.globalProviderScope.read(globalDialogRiverpod).set("二维码扫描",
        child: const SizedBox(width: double.infinity, child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: double.infinity, child: ProgressBar())
          ],
        )),
        cacheActions: false,
        actions: null,   
      ).show();

      // 将 GameToken 转换为 SToken
      Map<String, String>? stoken = await HoYoLabLib.getStokenByGameToken(aid: "284769672", gameToken: "f3juSnanjHcF3eaOZRKbg1LaC5HDr8Gr", deviceId: deviceId);
      if (stoken == null) {
        return;
      }

      String? ltoken = await HoYoLabLib.getLtokenByStoken(v2Stoken: stoken["token"]!, uid: stoken["aid"]!, mid: stoken["mid"]!, deviceId: stoken["deviceId"]!);

      if (ltoken == null) {
        return;
      }

      String? cookieToken = await HoYoLabLib.getCookieToken(
        uid: stoken["aid"]!,
        v2Stoken: stoken["token"].toString(),
        mid: stoken["mid"].toString(),
        deviceId: stoken["deviceId"].toString()
      );

      /// 判断用户是否存在
      if (await HoYoLabDatabaseLib.hasUser(stoken["deviceId"].toString())) {
        // 更新
        await HoYoLabDatabaseLib.updateUser(
          deviceId: stoken["deviceId"].toString(),
          aid: stoken["aid"].toString(),
          mid: stoken["mid"].toString(),
          ltoken: ltoken.toString(),
          stoken: stoken["token"].toString(),
          cookieToken: cookieToken
        );
        Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
          stoken["deviceId"].toString(),
          aid: stoken["aid"].toString(),
          uid: stoken["aid"].toString(),
          mid: stoken["mid"].toString(),
          ltoken: ltoken.toString(),
          stoken: stoken["token"].toString(),
          cookieToken: cookieToken ?? "",
          isExpired: false,
        );
      } else {
        // 添加
        await HoYoLabDatabaseLib.insertUser(
          deviceId: stoken["deviceId"].toString(),
          aid: stoken["aid"].toString(),
          uid: stoken["aid"].toString(),
          mid: stoken["mid"].toString(),
          ltoken: ltoken.toString(),
          stoken: stoken["token"].toString(),
          cookieToken: cookieToken ?? ""
        );

        Application.globalProviderScope.read(globalUserManagerRiverpod).addUser(
          id: stoken["deviceId"].toString(),
          aid: stoken["aid"].toString(),
          uid: stoken["aid"].toString(),
          mid: stoken["mid"].toString(),
          ltoken: ltoken.toString(),
          stoken: stoken["token"].toString(),
          cookieToken: cookieToken ?? "",
          avatar: "",
          isExpired: false,
          nickname: "",
          role: []
        );
      }

      // 异步获取用户信息
      HoYoLabBBSLib.selfInfo(
        stoken: stoken["token"].toString(),
        uid: stoken["aid"].toString(),
        mid: stoken["mid"].toString(),
        deviceId: stoken["deviceId"].toString()
      ).then((userinfo) {
        if (userinfo == null) {
          return false;
        }

        Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
          stoken["deviceId"].toString(),
          nickname: userinfo["nickname"].toString(),
          avatar: userinfo["avatar"].toString()
        );

        // 异步获取角色信息
        HoYoLabGameRolesLib.stokenGetRoles(
          stoken: stoken["token"].toString(),
          uid: stoken["aid"].toString(),
          mid: stoken["mid"].toString(),
          deviceId: stoken["deviceId"].toString(),
          ltoken: ltoken.toString(),
        ).then((roles) {
          if (roles != null && roles.isNotEmpty) {
            Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
              stoken["deviceId"].toString(),
              role: roles
            );
          }
        });
      });

      Application.globalProviderScope.read(globalDialogRiverpod).hidden();
      await Future.delayed(const Duration(milliseconds: 200));
      Application.globalProviderScope.read(globalDialogRiverpod).clean();
    });
    qrcodeLib.init();
  }
}
