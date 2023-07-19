/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-07-20 00:59:14
/// LastEditTime: 2023-07-20 01:25:14
/// FilePath: /lib/libs/hoyolab/qrcode.dart
/// ===========================================================================

import 'dart:async';
import 'dart:convert';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:srcat/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/config/hoyolab.dart';
import 'package:srcat/riverpod/global/dialog.dart';
import 'package:srcat/utils/http/dio.dart';

class HoYoLabQRCodeLib {
  Timer? timer;
  String deviceId = "";
  Function(String uid, String gameToken)? onConfirmed;

  void setDeviceId(String id) {
    deviceId = id;
  }

  void setOnConfirmed(Function(String uid, String gameToken) func) {
    onConfirmed = func;
  }

  Future<void> init() async {
    // 启动前先取消所有定时任务
    timer?.cancel();
    
    Application.globalProviderScope.read(globalDialogRiverpod).set(
      "二维码登录",
      child: Container(
        height: 200,
        width: 400,
        color: Colors.transparent,
        child: const Center(child: ProgressRing()),
      ),
      actions: [
        Button(child: const Text("取消登录"), onPressed: () async {
          timer?.cancel();
          Application.globalProviderScope.read(globalDialogRiverpod).hidden();
          await Future.delayed(const Duration(milliseconds: 200));
          Application.globalProviderScope.read(globalDialogRiverpod).clean();
        }),
      ]
    ).show();

    await SCDioUtils.request(
      method: Method.POST,
      uri: Uri.parse(HoYoLabConfig.hk4eSdkQRCodeFetch),
      params: {
        "app_id": 8,
        "device": deviceId
      },
      success: (response, data) async {
        await checkQRCodeStatus(data["data"]["url"].toString());
      },
      fail: (code, message, failType, dioError) {
      }
    );
  }

  Future<void> checkQRCodeStatus(String url) async {
    await initQRCode(url);
    String ticket = Uri.parse(url).queryParameters["ticket"] ?? "";

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        await SCDioUtils.request(
          method: Method.POST,
          uri: Uri.parse(HoYoLabConfig.hk4eSdkQRCodeQuery),
          params: {
            "app_id": 8,
            "device": deviceId,
            "ticket": ticket
          },
          success: (response, data) async {
            String message = data["message"].toString().toLowerCase();
            if (message == "ok") {
              String status = data["data"]["stat"].toString().toLowerCase();
              if (status == "scanned") {
                await initQRCode(url, scanned: true);
              } else if (status == "confirmed") {
                timer.cancel();
                if (onConfirmed != null) {
                  Map<String, dynamic> rawData = json.decode(data["data"]["payload"]["raw"]);
                  onConfirmed!(
                    rawData["uid"].toString(),
                    rawData["token"].toString()
                  );
                }
              }
            } else if (message == "expiredcode") {
              await initQRCode(url, expired: true, enableRefreshButton: true);
            }
          },
          fail: (code, message, failType, dioError) {}
        );
      }
    );
  }

  Future<void> initQRCode(String url, {
    bool enableRefreshButton = false,
    bool scanned = false,
    bool expired = false,
  }) async {
    List<Widget> buttons = [];

    if (enableRefreshButton) {
      buttons.add(
        FilledButton(child: const Text("刷新二维码"), onPressed: () {
          timer?.cancel();
          init();
        }
      ));
    }

    buttons.add(
      Button(child: const Text("取消登录"), onPressed: () async {
        timer?.cancel();
        Application.globalProviderScope.read(globalDialogRiverpod).hidden();
        await Future.delayed(const Duration(milliseconds: 200));
        Application.globalProviderScope.read(globalDialogRiverpod).clean();
      }
    ));

    Application.globalProviderScope.read(globalDialogRiverpod).set(
      "二维码登录",
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 400),
        child: Center(child: Container(
          height: 200,
          width: 200,
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              QrImageView(
                data: url,
                version: QrVersions.auto,
                eyeStyle: QrEyeStyle(color: Colors.white.withOpacity(0.8)),
                dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.white.withOpacity(0.8)),
                size: 200.0,
              ),
              (scanned || expired) ? Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white.withOpacity(0.6),
                    child: Center(
                      child: Text((() {
                        if (scanned) return "已扫描";
                        if (expired) return "已过期";
                        return "";
                      })(), style: const TextStyle(color: Colors.black, fontSize: 40)),
                    ),
                  )
                )
              ) : Container()
            ],
          )
        ))
      ),
      actions: buttons
    );
  }
}