/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-25 01:23:45
/// LastEditTime: 2023-05-27 20:24:35
/// FilePath: /lib/libs/user/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/libs/hoyolab/bbs.dart';
import 'package:srcat/libs/hoyolab/db.dart';
import 'package:srcat/libs/hoyolab/main.dart';
import 'package:srcat/riverpod/global/user.dart';
import 'package:srcat/utils/webview2/main.dart';
import 'package:srcat/riverpod/global/dialog.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

class SRCatMHYUserLib {
  /// 以网页方式登录
  static Future<void> openLoginWebView() async {
    WebviewWindow.clearAll(
      userDataFolderWindows: SRCatWebView2HelperUtils.cacheDir
    );

    final webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        title: "米哈游通行证",
        userDataFolderWindows: SRCatWebView2HelperUtils.cacheDir
      )
    );

    webview.launch("https://user.mihoyo.com/#/login/password");

    String title = "网页登录";
    Widget child = const Text("请在弹出的网页窗口中登录米哈游通行证，登录完成后请勿关闭弹出的窗口，然后返回此处点击下方的「我已登录」。");
    Widget cancel = Button(onPressed: () async {
      webview.close();
      Application.globalProviderScope.read(globalDialogRiverpod).hidden();
      await Future.delayed(const Duration(milliseconds: 200));
      Application.globalProviderScope.read(globalDialogRiverpod).clean();
    }, child: const Text("取消"));

    List<Widget> actions = [
      FilledButton(onPressed: () async {
        Application.globalProviderScope.read(globalDialogRiverpod).set(title, child: child, actions: [
          const FilledButton(
            onPressed: null,
            child: Text("登录中...")
          ),
          cancel
        ]);
        String? cookies = await webview.getAllCookies();
        Map<String, String> parseCookies = SRCatWebView2HelperUtils.strCookieToMap(cookies);
        await _webLogin(parseCookies["login_ticket"] ?? "", parseCookies["login_uid"] ?? "");
        webview.close();
      }, child: const Text("我已登录")),
      cancel
    ];

    Application.globalProviderScope.read(globalDialogRiverpod).set(
      title,
      child: child,
      actions: actions
    ).show();

    webview.onClose.whenComplete(() async {
      Application.globalProviderScope.read(globalDialogRiverpod).hidden();
      await Future.delayed(const Duration(milliseconds: 200));
      Application.globalProviderScope.read(globalDialogRiverpod).clean();
    });
  }

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

  /// 登录流程
  static Future<void> _webLogin(String loginTicket, String loginUid) async {
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
            openLoginWebView();
          }, child: const Text("重试")),
          Button(onPressed: () async {
            Application.globalProviderScope.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            Application.globalProviderScope.read(globalDialogRiverpod).clean();
          }, child: const Text("取消"))
        ]
      );
    }
    
    if (loginTicket.isEmpty || loginUid.isEmpty) {
      errDialog(title: "操作取消", desc: "未检测到登录状态，操作已被取消");
      return;
    }

    Map<String, String>? muiltToken;
    muiltToken = await HoYoLabLib.generatedMuiltToken(loginTicket: loginTicket, loginUid: loginUid);

    if (muiltToken == null) {
      errDialog();
      return;
    }

    Map<String, String>? v2Stoken = await HoYoLabLib.getV2StokenBySToekn(v1Stoken: muiltToken["stoken"].toString(), v1Uid: loginUid);
    
    if (v2Stoken == null) {
      errDialog();
      return;
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
        return;
      }

      Application.globalProviderScope.read(globalUserManagerRiverpod).editUser(
        v2Stoken["deviceId"].toString(),
        nickname: userinfo["nickname"].toString(),
        avatar: userinfo["avatar"].toString()
      );
    });

    Application.globalProviderScope.read(globalDialogRiverpod).hidden();
    await Future.delayed(const Duration(milliseconds: 200));
    Application.globalProviderScope.read(globalDialogRiverpod).clean();
  }
}
