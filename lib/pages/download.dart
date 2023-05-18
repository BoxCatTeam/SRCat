/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 22:46:58
/// LastEditTime: 2023-05-18 04:33:17
/// FilePath: /lib/pages/download.dart
/// ===========================================================================


import 'package:srcat/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/config/api.dart';
import 'package:srcat/libs/metadata/db.dart';
import 'package:srcat/libs/srcat/download/utils.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:srcat/components/pages/download/box.dart';
import 'package:srcat/components/pages/download/item.dart';

import 'package:srcat/riverpod/global/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/riverpod/pages/download.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:window_manager/window_manager.dart';

class DownloadPage extends ConsumerStatefulWidget {
  const DownloadPage({
    Key? key,
    this.isUpdate
  }) : super(key: key);

  /// 是否有新版本
  final String? isUpdate;

  @override
  ConsumerState<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<DownloadPage> with WindowListener {
  final _stateKey = GlobalKey<NavigatorState>();

  String _gameVersion = "";
  String _lang = "";
  String _version = "";

  @override
  void initState() {
    windowManager.addListener(this);
    if (widget.isUpdate != "true") {
      _initDownload();
    } else {
      _initMetadataUpdateDownload();
    }
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

  Widget _left() {
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

    Map<String, bool> downloadState = ref.watch(downloadRiverpod).downloadState;
    bool allCompleted() {
      if (downloadState.isEmpty) return false;
      List<bool> status = downloadState.entries.map((e) => e.value).toList();
      return status.contains(false) ? false : true;
    }

    List<Widget> pomList = [
      _animatedBox(allCompleted(), pom(path: "assets/images/srcat/pom-8.png", width: 160,height: 146)),
      _animatedBox(!allCompleted(), pom(path: "assets/images/srcat/pom-4.png", width: 160, height: 136))
    ];

    return Stack(
      alignment: AlignmentDirectional.center,
      children: pomList
    );
  }

  Widget _right() {
    Widget box({ required List<Widget> children }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
      );
    }

    Map<String, DownloadMetadataListModel> downloadListWatch = ref.watch(downloadRiverpod).list;
    List<DownloadListItem> downloadListItem = [];

    downloadListWatch.forEach((key, value) {
      downloadListItem.add(DownloadListItem(
        title: value.toJson()["title"],
        progress: value.toJson()["progress"] as double,
        progressText: value.toJson()["progressText"],
        hidden: value.toJson()["hidden"] as bool,
      ));
    });

    Duration duration = const Duration(milliseconds: 200);
    Map<String, bool> downloadState = ref.watch(downloadRiverpod).downloadState;
    bool allCompleted() {
      if (downloadState.isEmpty) return false;
      List<bool> status = downloadState.entries.map((e) => e.value).toList();
      return status.contains(false) ? false : true;
    }

    Widget child = box(
      children: [
        Text(allCompleted() ?
          "下载完成" :
          "下载列表",
          style: const TextStyle(fontSize: 23)
        ),
        const SizedBox(height: 3),
        Text(allCompleted() ?
          "所有元数据已下载完成，可以开始使用啦！" :
          widget.isUpdate != "true" ? "正在下载基本的元数据文件，请勿关闭 SRCat" : "正在更新元数据文件，请勿关闭 SRCat",
          style: const TextStyle(fontSize: 16)
        ),
        const SizedBox(height: 15),
        AnimatedContainer(
          height: allCompleted() ? 0 : null,
          duration: duration,
          child: AnimatedOpacity(
            opacity: allCompleted() ? 0 : 1,
            duration: duration,
            child: DownloadListBox(items: downloadListItem),
          )
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: !allCompleted() ? null : () async {
            Application.router.go("/home");
          },
          child: allCompleted() ? const Text("开始使用") : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                width: 15,
                height: 15,
                child: ProgressRing(strokeWidth: 2.5)
              ),
              const SizedBox(width: 10),
              widget.isUpdate != "true" ? const Text("下载中...") : const Text("更新中...")
            ]
          ),
        )
      ]
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: child
    );
  }

  Widget _content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 240,
              height: 240,
              child: Center(child: _left())
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 500,
                maxWidth: 600,
                minWidth: 240
              ),
              child: _right(),
            )
          ]
        )
      ]
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
        children: [_header(), _content()],
      )
    );
  }

  @override
  void onWindowClose() async {
    return;
  }

  @override
  void onWindowFocus() {
    windowManager.focus();
    setState(() {});
  }

  /// 下载初始化
  void _initDownload() async {
    /// 从元数据 API 中获取所有数据的索引
    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(SRCatAPIConfig.metadata),
      success: (response, data) async {
        if (data is Map<String, dynamic>) {
          await SRCatDownloadPageUtilsLib.successParse(context, data);
          
          _gameVersion = data["game_version"];
          _version = data["metadata_version"];
          _lang = data["lang"];

          SRCatMetadataDatabaseLib.insertVersion(
            version: _version,
            lang: _lang,
            gameVersion: _gameVersion
          );
        }
      },
      fail: (code, message, failType, dioError) {}
    );
  }

  /// 更新元数据
  void _initMetadataUpdateDownload() async {
    /// 从数据库中取出所有文件的 uuid 与 hash
    List<Map<String, dynamic>> files = await SRCatMetadataDatabaseLib.getAllFileInfo();
    List<Map<String, dynamic>> images = await SRCatMetadataDatabaseLib.getAllImagesInfo();
    List<Map<String, dynamic>> allList = [];
    allList..addAll(files)..addAll(images);

    Map<String, String> result = {};

    for (var item in allList) { 
      result.addEntries({
        item["id"].toString(): item["hash"].toString(),
      }.entries);
    }

    await SCDioUtils.request(
      method: Method.POST,
      params: {
        "uuids": result,
      },
      uri: Uri.parse(SRCatAPIConfig.metadataCheckUpdate),
      success: (response, data) async {
        if (data is Map<String, dynamic>) {
          if ((data["data"] as List<dynamic>).isEmpty) {
            
            Application.router.go("/home");
          } else {
            await SRCatDownloadPageUtilsLib.successParse(context, data);
          }
          
          _gameVersion = data["game_version"];
          _version = data["metadata_version"];
          _lang = data["lang"];

          SRCatMetadataDatabaseLib.insertVersion(
            version: _version,
            lang: _lang,
            gameVersion: _gameVersion
          );
        }
      },
      fail: (code, message, failType, dioError) {}
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
}
