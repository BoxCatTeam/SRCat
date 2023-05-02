/// Splash 屏闪页 & 初始化页面
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 03:59:16
/// LastEditTime: 2023-05-03 02:16:07
/// FilePath: /lib/pages/splash/main.dart
/// ===========================================================================

import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/config/settings.dart';
import 'package:srcat/libs/sr/services/tools/warp/data.dart';
import 'package:srcat/libs/sr/services/tools/warp/db.dart';
import 'package:srcat/utils/settings/main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _stateKey = GlobalKey<NavigatorState>();
  bool _needDownload = false;

  @override
  void initState() {
    super.initState();
  }

  /// SRCat Init
  void initSRCatApp() async {
    await Future.delayed(const Duration(seconds: 1));

    /// 判断是否需要下载数据
    /// 检查 item_data 是否有数据
    await SrWrapToolDatabaseService.allItem().then((value) {
      if (value.isEmpty) {
        _needDownload = true;
      }
    });
    if (_needDownload) initDownload();

    if (initHSR() == false) return;

    Application.router.go("/home");
  }

  /// Init Game EXE
  bool initHSR()  {
    if (SCSettingsUtils.get(SCSettingsSPKey.hsrExe) != "") return true;

    const XTypeGroup typeGroup = XTypeGroup(
      label: "exe",
      extensions: <String>["exe"]
    );

    void displayBar({
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
           onPressed: () => Application.router.pop()
          ),
          severity: severity,
       );
      });
    }

    showDialog<String>(
      context: _stateKey.currentContext!,
      builder: (context) => ContentDialog(
        title: const Text("提示"),
        content: const Text("需要选择游戏本体 (StarRail.exe) 才能正常使用跃迁记录分析工具"),
        actions: <Widget>[
          Button(
            child: const Text("暂不选择"),
            onPressed: () {
              Application.router.go("/home");
            }
          ),
          FilledButton(
            child: const Text("选择..."),
            onPressed: () {
              openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]).then((value) async {
                if (value?.path == null || value?.name == null) {
                  displayBar(title: "错误：", text: "请选择游戏本体 (StarRail.exe)");
                } else if (value?.name != "StarRail.exe") {
                  displayBar(title: "错误：", text: "您选择的不是游戏本体，请选择 StarRail.exe");
                } else {
                  SCSettingsUtils.set(SCSettingsSPKey.hsrExe, value?.path);
                  displayBar(title: "好耶", text: "已成功保存设置", severity: InfoBarSeverity.success);
                  await Future.delayed(const Duration(seconds: 1));
                  Application.router.go("/home");
                }
              }).catchError((onError) {
                // TODO: 咕咕咕
              });
            }
          )
        ]
      )
    );

    return false;
  }

  /// Init Warp Data
  void initDownload() async {
    /// 从 API 下载角色/光锥数据
    Map<String, dynamic> data = await SrWrapToolDataService.downloadItemData();
    if (data.isNotEmpty) {
      if (data["character"].isNotEmpty) {
        for (Map<String, dynamic> item in data["character"]) {
          await SrWrapToolDatabaseService.insertItem(
            rawId: item["id"],
            name: '{"zh_CN": "${item["name"]["zh_CN"]}",'
              ' "zh_TW": "${item["name"]["zh_TW"]}",'
              ' "en_US": "${item["name"]["en_US"]}",'
              ' "ja_JP": "${item["name"]["ja_JP"]}",'
              ' "ko_KR": "${item["name"]["ko_KR"]}"}',
            type: "character",
            color: item["name_color"]
          );
        }
      }

      if (data["lightcone"].isNotEmpty) {
        for (Map<String, dynamic> item in data["lightcone"]) {
          if (item["id"] == 2333333) break;
          await SrWrapToolDatabaseService.insertItem(
            rawId: item["id"],
            name: '{"zh_CN": "${item["name"]["zh_CN"]}",'
              ' "zh_TW": "${item["name"]["zh_TW"]}",'
              ' "en_US": "${item["name"]["en_US"]}",'
              ' "ja_JP": "${item["name"]["ja_JP"]}",'
              ' "ko_KR": "${item["name"]["ko_KR"]}"}',
            type: "lightcone",
            color: item["name_color"]
          );
        }
      }
    }

    _needDownload = false;

    await Future.delayed(const Duration(seconds: 2));
  }

  /// 下载页面
  Widget _downloadPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text("正在下载数据，请稍后...", style: TextStyle(fontSize: 18)),
        SizedBox(height: 15),
        ProgressRing(
          strokeWidth: 5,
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    initSRCatApp();
    
    return Container(
      key: _stateKey,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: _needDownload ? _downloadPage() : const Center(
        child: ProgressRing(
          strokeWidth: 5,
        ),
      ),
    );
  }
}
