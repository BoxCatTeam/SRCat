/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 03:42:37
/// LastEditTime: 2023-05-22 23:18:58
/// FilePath: /lib/pages/app/settings.dart
/// ===========================================================================

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:srcat/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/base/app_title.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/config/api.dart';
import 'package:srcat/riverpod/global/dialog.dart';
import 'package:srcat/riverpod/global/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/riverpod/pages/settings.dart';
import 'package:srcat/utils/file/main.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/utils/main.dart';

import 'package:srcat/utils/settings.dart';
import 'package:srcat/config/settings.dart';

import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/scroll/normal.dart';
import 'package:srcat/utils/storage/main.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fluent_system_icons;
import 'package:srcat/utils/storage/sqlite.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  /// 主题类型
  late Map<String, String> _themeType = {};
  /// 背景材质
  late Map<String, String> _materialType = {};
  /// 语言
  late Map<String, String> _languageType = {};
  /// 是否禁用背景材质选择
  bool _isDisableMaterial = false;
  final _stateKey = GlobalKey<NavigatorState>();
  bool _setFont = true;

  /// 旧数据目录
  String _oldDataFolder = "";
  
  @override
  void initState() {
    super.initState();

    _themeType = {
      "auto": "跟随系统",
      "light": "亮色",
      "dark": "深色"
    };

    _materialType = {
      "default": "Default",
      "mica": "Mica",
      "acrylic": "Acrylic",
      "tabbed": "Tabbed"
    };

    _languageType = {
      "zh-CN": "中文（简体）"
    };

    if (Application.buildNumber < 22000) {
      _isDisableMaterial = true;
      if (SRCatSettingsUtils.get(SRCatSettingsKey.material) is String && SRCatSettingsUtils.get(SRCatSettingsKey.material) != "default") {
        SRCatSettingsUtils.set(SRCatSettingsKey.material, "default");
      }
    }

    super.initState();
  }

  Widget _header() {
    Widget title = SRCatAppTitle(
      size: 60,
      useCatFont: _setFont,
    );

    Widget copy = Text.rich(
      TextSpan(
        children: <TextSpan>[
          const TextSpan(text: "Copyright © 2023 BoxCat. "),
          const TextSpan(text: "under "),
          TextSpan(text: "MIT License",
            style: TextStyle(
              color: FluentTheme.of(context).accentColor
            ),
            recognizer: TapGestureRecognizer()..onTap = () => SRCatUtils.openUrl(Uri.parse("https://github.com/BoxCatTeam/SRCat/blob/master/LICENSE"))
          ),
        ]
      )
    );

    Widget buttons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Button(
          onPressed: () => SRCatUtils.openUrl(Uri.parse("https://github.com/BoxCatTeam/SRCat")),
          child: const Text("GitHub")
        ),
        const SizedBox(width: 10),
        Button(
          onPressed: () => SRCatUtils.openUrl(Uri.parse("https://srcat.boxcat.org")),
          child: const Text("官网")
        ),
        const SizedBox(width: 10),
        Button(
          onPressed: () => SRCatUtils.openUrl(Uri.parse("https://github.com/BoxCatTeam/SRCat/issues/new/choose")),
          child: const Text("建议与反馈")
        ),
        const SizedBox(width: 10),
        Button(
          onPressed: () => {},
          child: const Text("隐私协议")
        ),
        const SizedBox(width: 10),
        Button(
          onPressed: () => SRCatUtils.openUrl(Uri.parse("https://afdian.net/a/boxcat")),
          child: const Text("赞助我们")
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            ref.read(globalDialogRiverpod).set("喵？", titleSize: 20,
              child: const Text("喵，喵喵？喵！"),
              actions: <Widget>[
                Button(
                  onPressed: () {
                    ref.read(globalDialogRiverpod).set("喵...", titleSize: 18,
                      child: const Text("喵喵，喵喵... 喵——ヽ(*。>Д<)o゜"),
                      actions: <Widget>[
                        FilledButton(
                          onPressed: () async {
                            _setFont = false;
                            setState(() {});
                            ref.read(globalDialogRiverpod).hidden();
                            await Future.delayed(const Duration(milliseconds: 200));
                            ref.read(globalDialogRiverpod).clean();
                          },
                          child: const Text("😿")
                        )
                      ]
                    );
                  },
                  child: const Text("喵喵..."),
                ),
                FilledButton(
                  onPressed: () async {
                    _setFont = true;
                    setState(() {});
                    ref.read(globalDialogRiverpod).hidden();
                    await Future.delayed(const Duration(milliseconds: 200));
                    ref.read(globalDialogRiverpod).clean();
                  },
                  child: const Text("喵喵！")
                )
              ]
            ).show();
          },
          icon: const SRCatIcon(FluentIcons.cat)
        )
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 15),
          title, copy,
          const SizedBox(height: 15),
          buttons,
          const SizedBox(height: 20),
        ],
      )
    );
  }

  Widget _panel1() {
    Widget title = const Text("关于");

    bool isChecking = ref.watch(settingsRiverpod).isCheckingUpdate;

    Widget about = Expander(
      headerHeight: 55,
      header: Row(
        children: <Widget>[
          const SRCatIcon(fluent_system_icons.FluentIcons.apps_48_regular, size: 23),
          const SizedBox(width: 15),
          Center(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("SRCat"),
              Text("${Application.packageInfo.version}.0", style: const TextStyle(fontSize: 13))
            ]
          )),
          Expanded(child: Container()),
          Button(
            onPressed: isChecking ? null : () => _checkUpdate(),
            child: isChecking ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 15,
                  height: 15,
                  child: ProgressRing(strokeWidth: 2.5)
                ),
                SizedBox(width: 10),
                Text("检查更新中...")
              ]
            ) : const Text("检查更新")
          )
        ]
      ),
      content: const Text("暂无更新日志"),
      onStateChanged: (open) {}
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        const SizedBox(height: 10),
        about,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _panel2() {
    Widget title = const Text("外观");
    /* ============================== 主题 ==============================*/
    List<ComboBoxItem<String>> themeItem = [];
    _themeType.forEach((key, value) {
      themeItem.add(ComboBoxItem(
        value: key,
        child: Text(value))
      );
    });

    Widget theme = SRCatCard(
      icon: FluentIcons.color,
      title: "主题",
      description: "亮色、深色还是跟随系统呢？",
      margin: const EdgeInsets.only(bottom: 3),
      rightChild: ComboBox<String>(
        value: SRCatSettingsUtils.get(SRCatSettingsKey.theme) is String ? SRCatSettingsUtils.get(SRCatSettingsKey.theme) : "auto",
        items: themeItem,
        onChanged: (value) {
          if (SRCatSettingsUtils.get(SRCatSettingsKey.theme) != value) {
            ref.read(themeRiverpod.notifier).setTheme(value!);
          }
          SRCatSettingsUtils.set(SRCatSettingsKey.theme, value);
          setState(() => {});
        },
      ),
    );
    /* ============================== 主题[END] ==============================*/

    /* ============================== 背景材质 ==============================*/
    List<ComboBoxItem<String>> backgroundItem = [];
    _materialType.forEach((key, value) {
      backgroundItem.add(ComboBoxItem(
        value: key,
        child: Text(value))
      );
    });
    
    Widget background = SRCatCard(
      icon: FluentIcons.bucket_color,
      title: "背景材质",
      description: "更改窗体背景材质",
      margin: const EdgeInsets.only(bottom: 3),
      rightChild: ComboBox<String>(
        value: SRCatSettingsUtils.get(SRCatSettingsKey.material) is String ? SRCatSettingsUtils.get(SRCatSettingsKey.material) : "mica",
        items: backgroundItem,
        onChanged: _isDisableMaterial ? null : (value) {
          if (SRCatSettingsUtils.get(SRCatSettingsKey.material) != value) {
            ref.read(themeRiverpod.notifier).setMaterial(value!);
          }
          SRCatSettingsUtils.set(SRCatSettingsKey.material, value);
          setState(() => {});
        },
      ),
    );
    /* ============================== 背景材质[END] ==============================*/
    
    /* ============================== 语言 ==============================*/
    List<ComboBoxItem<String>> languageItem = [];
    _languageType.forEach((key, value) {
      languageItem.add(ComboBoxItem(
        value: key,
        child: Text(value))
      );
    });

    Widget lang = SRCatCard(
      icon: FluentIcons.locale_language,
      title: "语言",
      description: "SRCat 界面显示语言",
      margin: const EdgeInsets.only(bottom: 0),
      rightChild: ComboBox<String>(
        value: SRCatSettingsUtils.get(SRCatSettingsKey.language) is String ? SRCatSettingsUtils.get(SRCatSettingsKey.language) : "zh-CN",
        items: languageItem,
        onChanged: (value) {
          SRCatSettingsUtils.set(SRCatSettingsKey.language, value);
          setState(() => {});
        },
      ),
    );
    /* ============================== 语言[END] ==============================*/

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        const SizedBox(height: 10),
        theme,
        background,
        lang
      ],
    );
  }

  Widget _panel3() {
    Widget title = const Text("游戏");

    Widget hsrPathSelector = SRCatCard(
      title: "游戏路径",
      icon: fluent_system_icons.FluentIcons.games_24_regular,
      description: (SRCatStorageUtils.read("hsr_path") ?? "暂未设置") as String,
      rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 12),
      onTap: () async {
        const XTypeGroup typeGroup = XTypeGroup(label: "exe", extensions: <String>["exe"]);
        openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]).then((value) async {
          if (value?.path != null && value?.name == "srcat.exe") {
            _displayBar(title: "提示", text: "不可以原地 TP，请选择 StarRail.exe", severity: InfoBarSeverity.warning);
          } else if (value?.path != null && value?.name == "launcher.exe") {
            _displayBar(title: "错误", text: "请勿选择 launcher.exe，请选择 StarRail.exe");
          } else if (value?.path != null && (value?.name == "YuanShen.exe" || value?.name == "GenshinImpact.exe" || value?.name == "Genshin Impact Cloud Game.exe")) {
            _displayBar(title: "错误", text: "不可以选择原神，这里是星穹铁道，请选择 StarRail.exe");
          } else if (value?.path != null && value?.name != "StarRail.exe") {
            _displayBar(title: "错误", text: "您选择的不是游戏本体，请选择 StarRail.exe");
          } else if (value?.path != null && value?.name == "StarRail.exe") {
            await SRCatStorageUtils.write("hsr_path", value!.path);
            _displayBar(title: "好耶", text: "已选择游戏路径", severity: InfoBarSeverity.success);
          }
        }).catchError((onError) {
          _displayBar(title: "错误", text: onError.toString());
        });
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        title,
        const SizedBox(height: 10),
        hsrPathSelector
      ],
    );
  }

  Widget _panel4() {
    Widget title = const Text("用户数据");

    Widget openDataFolder = SRCatCard(
      icon: FluentIcons.fabric_user_folder,
      title: "打开 用户数据 目录",
      description: "用户数据、元数据、缓存文件 均在此目录",
      rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 12),
      margin: const EdgeInsets.only(bottom: 3),
      onTap: () => SRCatUtils.openFolder(Uri.parse(SRCatStorageUtils.read("data_path").toString()))
    );

    Widget changeDataFolder = SRCatCard(
      icon: FluentIcons.fabric_moveto_folder,
      title: "修改 用户数据 目录",
      description: "修改用户数据目录后将重启 SRCat，并且需要您手动将原目录下的文件复制到新目录",
      rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 12),
      margin: const EdgeInsets.only(bottom: 3),
      onTap: () async {
        _oldDataFolder = SRCatStorageUtils.read("data_path").toString();
        final String? directoryPath = await getDirectoryPath(
          initialDirectory: _oldDataFolder
        );

        if (directoryPath == _oldDataFolder) {
          _displayBar(title: "提示", text: "新旧数据目录一致，无需修改", severity: InfoBarSeverity.warning);
        } else if (directoryPath != null) {
          SRCatStorageUtils.write("data_path", directoryPath);
          ref.read(globalDialogRiverpod).set("数据目录修改提示", child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("旧目录: $_oldDataFolder"),
              Text("新目录: $directoryPath"),
              const Text("\n"),
              const Text("以上操作将在重启 SRCat 后生效。在此之前需要手动将旧目录的文件内容移动到新目录，否则数据将不会加载。")
            ]
          ), actions: <Widget>[
            Button(onPressed: () {
              windowManager.destroy();
            }, child: const Text("退出 SRCat")),
            FilledButton(
              onPressed: () {
                SRCatUtils.openFolder(Uri.parse(_oldDataFolder));
              },
              child: const Text("打开旧数据目录"),
            ),
          ]).show();
        }
      }
    );

    Widget reDownloadMetadata = SRCatCard(
      icon: fluent_system_icons.FluentIcons.arrow_reset_48_regular,
      title: "重置元数据",
      description: "元数据出现异常、不完整等情况时可以点此进行重新下载",
      rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 12),
      onTap: () async {
        ref.read(globalDialogRiverpod).set("元数据重置", child: const Text("请等待..."), cacheActions: false, actions: []).show();
        await Future.delayed(const Duration(milliseconds: 200));
        // 关闭数据库
        await (await SRCatSQLiteUtils.metadata()).close();

        // 删除元数据文件夹
        Directory metadataDir = Directory("${await SRCatStorageUtils.read("data_path")}/metadata");
        await metadataDir.delete(recursive: true);

        // 删除元数据的数据库文件
        File metadataDB = File("${await SRCatStorageUtils.read("data_path")}/database/metadata.db");
        await metadataDB.delete(recursive: true);

        ref.read(globalDialogRiverpod).hidden();
        await Future.delayed(const Duration(milliseconds: 200));
        ref.read(globalDialogRiverpod).clean();
        await Future.delayed(const Duration(milliseconds: 10));
        Application.router.go("/download");
      }
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        title,
        const SizedBox(height: 10),
        openDataFolder,
        changeDataFolder,
        reDownloadMetadata
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_header(), _panel1(), _panel2(), _panel3(), _panel4()],
    );

    return SRCatNormalScroll(
      child: Container(
        key: _stateKey,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: child,
      )
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

  void _checkUpdate() async {
    ref.read(settingsRiverpod).changeCheckUpdateStatus(true);

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse("${SRCatAPIConfig.checkUpdate}?version=${Application.packageInfo.version}"),
      success: (response, data) {
        if (data["code"].toString() == "-1") {
          _displayBar(title: "错误", text: "当前版本不在主分支中，或是开发版本。");
        } else if (SRCatUtils.getVersionNumber(data["latest_version"]) > SRCatUtils.getVersionNumber(Application.packageInfo.version)) {
          ref.read(globalDialogRiverpod).set("发现新版本", child: SizedBox(
            height: 300,
            child: SRCatNormalScroll(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "本地版本: ${Application.packageInfo.version}\n"
                  "远端版本: ${data["latest_version"]}\n"
                  "更新日期: ${SRCatUtils.unixTimeToStr(data["update_time"], format: "yyyy-MM-dd HH:mm:ss")}"
                ),
                const SizedBox(height: 10),
                const Text("更新日志: ", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 5),
                HtmlWidget(data["update_log"] ?? "", textStyle: const TextStyle(inherit: false, fontFamily: "PingFang")),
              ],
            ))),
            actions: [
              Button(onPressed: () async {
                ref.read(globalDialogRiverpod).hidden();
                await Future.delayed(const Duration(milliseconds: 200));
                ref.read(globalDialogRiverpod).clean();
              }, child: const Text("好的")),
              FilledButton(onPressed: () async {
                Process.start(
                  "${SRCatFileUtils.getExeDir()}/srcat-autoupdate.exe",
                  ["-c", "stable"],
                  runInShell: true,
                  mode: ProcessStartMode.detached
                );
                await windowManager.destroy();
              }, child: const Text("更新"))
            ]
          ).show();
        } else {
          _displayBar(title: "提示", text: "已是最新版本啦！", severity: InfoBarSeverity.success);
        }
        ref.read(settingsRiverpod).changeCheckUpdateStatus(false);
      },
      fail: (code, message, failType, dioError) {
        _displayBar(title: "发生错误", text: message);
      }
    );
  }
}
