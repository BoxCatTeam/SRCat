/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-06-07 02:17:05
/// LastEditTime: 2023-06-07 21:14:33
/// FilePath: /lib/pages/app/webview/login.dart
/// ===========================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/config/hoyolab.dart';
import 'package:srcat/libs/user/main.dart';

import 'package:srcat/riverpod/global/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:webview_windows/webview_windows.dart';

class AppLoginWebview extends ConsumerStatefulWidget {
  const AppLoginWebview({ Key? key }) : super(key: key);

  @override
  ConsumerState<AppLoginWebview> createState() => _AppLoginWebviewState();
}

class _AppLoginWebviewState extends ConsumerState<AppLoginWebview> {
  late WebviewController _controller;
  
  @override
  void initState() {
    super.initState();
    initWebView();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initWebView() async {
    _controller = WebviewController();
    try {
      await _controller.initialize();
      
      await _controller.clearCache();
      await _controller.clearCookies();

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);

      await _controller.loadUrl(HoYoLabConfig.hoyolabLoginPageUrl);

      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(globalDialogRiverpod).set(
          "发生错误",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Code: ${e.code}'),
              Text('Message: ${e.message}'),
            ]
          ),
          actions: <Widget>[
            FilledButton(child: const Text("好的"), onPressed: () async {
              ref.read(globalDialogRiverpod).hidden();
              await Future.delayed(const Duration(milliseconds: 200));
              ref.read(globalDialogRiverpod).clean();
            })
          ]
        ).show();
      });
    }
  }

  Widget _bar() {
    Widget title = const Text("在下方登录后点「我已登录」", style: TextStyle(
      fontSize: 16,
    ));

    Widget submit = FilledButton(onPressed: () async {
      SRCatMHYUserLib.startWebLogin(_controller);
    }, child: const Text("我已登录"));

    Widget devtool = Button(
      onPressed: () {
        _controller.openDevTools();
      },
      child: const Row(
        children: <Widget>[
          SRCatIcon(FluentIcons.developer_tools),
          SizedBox(width: 5),
          Text("开发者工具")
        ],
      ),
    );

    return SizedBox(
      height: 60,
      child: Card(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: <Widget>[
            title,
            Expanded(child: Container()),
            submit,
            if (kDebugMode) const SizedBox(width: 8),
            if (kDebugMode) devtool
          ]
        )
      ),
    );
  }

  Widget _loadPage() {
    return const Center(
      child: ProgressRing(
        strokeWidth: 5,
      ),
    );
  }

  Widget _webview() {
    return Webview(
      _controller,
      permissionRequested: _onPermissionRequested,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _bar()
        ),

        if (!_controller.value.isInitialized) Positioned(child: _loadPage()),
        if (_controller.value.isInitialized) Positioned(
          top: 60,
          left: 0,
          right: 0,
          bottom: 0,
          child: _webview(),
        ),
      ],
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: Application.rootNavigatorKey.currentContext!,
      builder: (BuildContext context) => ContentDialog(
        title: const Text('WebView 权限申请'),
        content: Text('WebView 需要请求的权限：\'$kind\''),
        actions: <Widget>[
          Button(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text("拒绝"),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text("同意"),
          ),
        ],
      ),
    );
    
    return decision ?? WebviewPermissionDecision.none;
  }
}
