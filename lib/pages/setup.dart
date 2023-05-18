/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 00:45:39
/// LastEditTime: 2023-05-18 08:12:43
/// FilePath: /lib/pages/setup.dart
/// ===========================================================================

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/utils/file/init.dart';
import 'package:srcat/utils/main.dart';
import 'package:srcat/utils/file/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:srcat/utils/storage/main.dart';
import 'package:srcat/utils/storage/sqlite.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'package:srcat/riverpod/pages/setup.dart';
import 'package:srcat/riverpod/global/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:srcat/riverpod/global/theme.dart';
import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/components/global/base/app_title.dart';

import 'package:desktop_webview_window/desktop_webview_window.dart';

/// 引导页面
class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({
    Key? key
  }) : super(key: key);

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> with WindowListener {
  final _stateKey = GlobalKey<NavigatorState>();
  String _defaultFilePath = "";

  @override
  void initState() {
    windowManager.addListener(this);
    _initFilePath();
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Widget _header() {
    final FluentThemeData theme = FluentTheme.of(context);
    Widget button = SizedBox(width: 138, child: WindowCaption(
      brightness: theme.brightness,
      backgroundColor: Colors.transparent,
    ));
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: <Widget>[
          Expanded(child: button),
        ],
      ),
    );
  }

  List<Widget> _left() {
    bool isHidden1 = ref.watch(setupPageRiverpod).hideSetup1;
    bool isHidden2 = ref.watch(setupPageRiverpod).hideSetup2;
    bool isHidden3 = ref.watch(setupPageRiverpod).hideSetup3;
    bool isHidden4 = ref.watch(setupPageRiverpod).hideSetup4;

    Widget pom({
      required String path,
      required double height,
      required double width,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(path),
            fit: BoxFit.cover
          )
        )
      );
    }

    Widget setup1 = Transform(
      transform: Matrix4.rotationY(math.pi),
      alignment: Alignment.center,
      child: _animatedBox(isHidden1, pom(path: "assets/images/srcat/pom-1.png", width: 160, height: 158))
    );
    Widget setup2 = _animatedBox(isHidden2, pom(path: "assets/images/srcat/pom-4.png", width: 160, height: 136));
    Widget setup3 = _animatedBox(isHidden3, pom(path: "assets/images/srcat/pom-6.png", width: 160, height: 160));
    Widget setup4 = _animatedBox(isHidden4, pom(path: "assets/images/srcat/pom-2.png", width: 160, height: 140));

    return [setup1, setup2, setup3, setup4];
  }

  List<Widget> _right() {
    bool isHidden1 = ref.watch(setupPageRiverpod).hideSetup1;
    bool isHidden2 = ref.watch(setupPageRiverpod).hideSetup2;
    bool isHidden3 = ref.watch(setupPageRiverpod).hideSetup3;
    bool isHidden4 = ref.watch(setupPageRiverpod).hideSetup4;


    Widget box({ required List<Widget> children }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
      );
    }

    bool setup1CanNext = ref.watch(setupPageRiverpod).setup1CanNext;
    Widget setup1 = box(
      children: <Widget>[
        const SRCatAppTitle(size: 45),
        const Text("愿此行，有猫猫一直相伴", style: TextStyle(fontSize: 20)),
        const SizedBox(height: 30),
        FilledButton(onPressed: setup1CanNext ? () {
          ref.read(globalDialogRiverpod).set("注意",
            titleSize: 23,
            child: const Text(
              "『SRCat』是『崩坏：星穹铁道』的第三方工具箱，使用 MIT 许可证进行开源，且免费发布。\n\n"
              "在严格遵循相关法律且不会修改、删除您个人账号的前提下，为您提供便利的功能。\n"
              "但请注意：任何第三方工具都有一定的风险，点击下一步则代表您理解并同意可能潜在的未知风险。",
              style: TextStyle(fontSize: 15)
            ),
            actions: [
              Button(child: const Text("下一步"), onPressed: () async {
                // 点击下一步后立即禁用按钮，防止重复点击
                ref.read(setupPageRiverpod).changeSetup1CanNext(false);
                ref.read(globalDialogRiverpod).hidden();
                await Future.delayed(const Duration(milliseconds: 300));
                ref.read(globalDialogRiverpod).clean();
                ref.read(setupPageRiverpod).hiddenSetup(1);
                await Future.delayed(const Duration(milliseconds: 50));
                ref.read(setupPageRiverpod).showSetup(2);
                ref.read(setupPageRiverpod).changeContentBox(1);
              }),
              FilledButton(child: const Text("不同意并退出"), onPressed: () {
                windowManager.destroy();
              }),
            ]
          ).show();
        } : null, child: const Text("开始配置"))
      ],
    );

    bool setup2CanNext = ref.watch(setupPageRiverpod).setup2CanNext;
    String? gamePath = ref.watch(setupPageRiverpod).gamePath;
    String? filePath = ref.watch(setupPageRiverpod).filePath;
    bool setup2Loading = ref.watch(setupPageRiverpod).setup2Loading;
    Widget setup2 = box(
      children: <Widget>[
        const Text("配置项", style: TextStyle(fontSize: 23)),
        const Text("您可以在此自定义部分设置", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        SRCatCard(
          title: "[必选] 游戏位置",
          description: gamePath ?? "未设置 | 请选择 [星穹铁道安装目录\\Game\\StarRail.exe]",
          rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 14),
          onTap: setup2Loading ? null : () {
            const XTypeGroup typeGroup = XTypeGroup(label: "exe", extensions: <String>["exe"]);
            openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]).then((value) async {
              if (value?.path == null || value?.name == null) {
                _displayBar(title: "错误", text: "请选择游戏本体 (StarRail.exe)");
              } else if (value?.name != "StarRail.exe") {
                _displayBar(title: "错误", text: "您选择的不是游戏本体，请选择 StarRail.exe");
              } else if (value?.name == "StarRail.exe") {
                _displayBar(title: "好耶", text: "已选择游戏路径", severity: InfoBarSeverity.success);
                ref.read(setupPageRiverpod).setGamePath(value!.path);
                ref.read(setupPageRiverpod).changeSetup2CanNext(true);
              }
            }).catchError((onError) {
              _displayBar(title: "错误", text: onError.toString());
            });
          }
        ),
        const SizedBox(height: 5),
        SRCatCard(
          title: "当前用户数据存放目录",
          description: filePath,
          rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 14),
          onTap: setup2Loading ? null : () async {
            final String? directoryPath = await getDirectoryPath(
              initialDirectory: _defaultFilePath
            );

            if (directoryPath != null) {
              _displayBar(title: "好耶", text: "已更新用户数据目录", severity: InfoBarSeverity.success);
              ref.read(setupPageRiverpod).setFilePath(directoryPath);
            }
          }
        ),
        const SizedBox(height: 20),
        setup2Loading ? const FilledButton(
          onPressed: null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 15,
                height: 15,
                child: ProgressRing(strokeWidth: 2.5)
              ),
              SizedBox(width: 10),
              Text("初始化中...")
            ]
          )
        ) : FilledButton(onPressed: setup2CanNext ? () async {
          ref.read(setupPageRiverpod).changeSetup2Loading(true);

          await SRCatStorageUtils.write("hsr_path", gamePath);
          await SRCatStorageUtils.write("data_path", filePath);

          await SRCatFileUtils.createDir(filePath!);

          await Future.delayed(const Duration(seconds: 1));
          ref.read(setupPageRiverpod).hiddenSetup(2);
          await Future.delayed(const Duration(milliseconds: 50));
          ref.read(setupPageRiverpod).showSetup(3);
          ref.read(setupPageRiverpod).changeContentBox(2);
        } : null, child: const Text("下一步"))
      ]
    );

    bool setup3CanNext = ref.watch(setupPageRiverpod).setup3CanNext;
    bool hasWebView2= ref.watch(setupPageRiverpod).hasWebView2;
    bool checkedWebView2= ref.watch(setupPageRiverpod).checkedWebView2;
    Widget setup3 = box(
      children: <Widget>[
        const Text("环境依赖", style: TextStyle(fontSize: 23)),
        Text.rich(
          TextSpan(children: <InlineSpan>[
            const TextSpan(text: "部分功能需要依赖 WebView2 才能正常使用，需要您的设备上正确安装了 "),
            TextSpan(
              text: "WebView2 Runtime",
              style: TextStyle(fontWeight: FontWeight.bold, color: FluentTheme.of(context).accentColor),
              recognizer: TapGestureRecognizer()..onTap = () => SRCatUtils.openUrl(Uri.parse("https://developer.microsoft.com/microsoft-edge/webview2/"))
            ),
            const TextSpan(text: "。"),
          ])
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Button(child: const Text("检查安装情况"), onPressed: () async {
              ref.read(setupPageRiverpod).setCheckedWebView2();
              if (await WebviewWindow.isWebviewAvailable()) {
                ref.read(setupPageRiverpod).changeHasWebView2(true);
                ref.read(setupPageRiverpod).changeSetup3CanNext(true);
              } else {
                ref.read(setupPageRiverpod).changeHasWebView2(false);
                ref.read(setupPageRiverpod).changeSetup3CanNext(false);
              }
            }),
            const SizedBox(width: 10),
            checkedWebView2 ? Text(hasWebView2 ? "已安装" : "未安装", style: TextStyle(
              color: hasWebView2 ? FluentTheme.of(context).accentColor : Colors.red
            )) : const SizedBox()
          ],
        ),
        const SizedBox(height: 15),
        FilledButton(onPressed: setup3CanNext ? () async {
          ref.read(setupPageRiverpod).hiddenSetup(3);
          await Future.delayed(const Duration(milliseconds: 50));
          ref.read(setupPageRiverpod).showSetup(4);
          ref.read(setupPageRiverpod).changeContentBox(3);
        } : null, child: const Text("下一步"))
      ]
    );

    Widget setup4 = box(
      children: <Widget>[
        const Text("配置完成！", style: TextStyle(fontSize: 23)),
        const SizedBox(height: 3),
        const Text("好耶，已经全部配置完成啦！", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 3),
        const Text("但在开始使用之前，还需要检查元数据是否下载完成\n(￣﹃￣)", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 30),
        FilledButton(onPressed: () async {
          await SRCatStorageUtils.write("installed", true);
          if (await SRCatStorageUtils.read("data_path") != null) {
            await SRCatFileInitUtils.init();
            await SRCatSQLiteUtils.init();
          }
          Application.router.go("/download");
        }, child: const Text("完成配置并下载元数据"))
      ]
    );

    return [
      _animatedBox(isHidden1, setup1),
      _animatedBox(isHidden2, ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: setup2
      )),
      _animatedBox(isHidden3, ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: setup3
      )),
      _animatedBox(isHidden4, ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        child: setup4
      )),
    ];
  }

  Widget _content() {
    int contentBox = ref.read(setupPageRiverpod).contentBox;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 240,
              height: 240,
              child: Center(child: Stack(
                alignment: AlignmentDirectional.center,
                children: _left())
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 500,
                maxWidth: 600,
                minWidth: 240
              ),
              child: _right()[contentBox],
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    WindowEffect effect = WindowEffect.disabled;
    bool isDark = false;
    final String material = ref.watch(themeRiverpod)["material"];
    final String theme = ref.watch(themeRiverpod)["theme"];
    if (material == "mica") {
      effect = WindowEffect.mica;
    } else if (material == "acrylic") {
      effect = WindowEffect.acrylic;
    } else if (material == "tabbed") {
      effect = WindowEffect.tabbed;
    } else {
      effect = WindowEffect.disabled;
    }
    if (Application.buildNumber < 22000) {
      effect = WindowEffect.disabled;
    }
    if (theme == "auto") {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else if (theme == "dark") {
      isDark = true;
    } else {
      isDark = false;
    }
    Window.setEffect(
      effect: effect,
      dark: isDark,
    );
    
    return ScaffoldPage(
      key: _stateKey,
      padding: EdgeInsets.zero,
      content: Stack(
        children: <Widget>[_header(), _content()],
      )
    );
  }

  /// Opacity && IgnorePointer 组件
  Widget _animatedBox(bool isHidden, Widget child) {
    Widget opacity = AnimatedOpacity(
      opacity: isHidden ? 0 : 1,
      duration: const Duration(milliseconds: 100),
      child: child,
    );
    return IgnorePointer(
      ignoring: isHidden ? true : false,
      child: opacity,
    );
  }

  void _displayBar({
    required String title,
    required String text,
    InfoBarSeverity severity = InfoBarSeverity.error
  }) {
    displayInfoBar(_stateKey.currentContext!, builder: (context, close) {
      return InfoBar(
        title: Text(title),
        content: Text(text),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close
        ),
        severity: severity,
      );
    });
  }

  void _initFilePath() async {
    String path = (await getApplicationDocumentsDirectory()).path;
    _defaultFilePath = path;
    ref.read(setupPageRiverpod).setFilePath("$path\\SRCat");
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) windowManager.destroy();
  }

  @override
  void onWindowFocus() {
    windowManager.focus();
    setState(() {});
  }
}
