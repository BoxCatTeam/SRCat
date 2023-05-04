/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 23:33:29
/// LastEditTime: 2023-05-05 02:06:41
/// FilePath: /lib/pages/settings/main.dart
/// ===========================================================================

import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/application.dart';
import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/components/global/scroll/normal.dart';
import 'package:srcat/icons/iconfont/srcat.dart';

import 'package:srcat/config/settings.dart';
import 'package:srcat/utils/settings/main.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../riverpod/global/theme.dart';

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

  @override
  void initState() {
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
      "zh_CN": "中文（简体）"
    };

    if (Application.buildNumber < 22000) {
      _isDisableMaterial = true;
      if (SCSettingsUtils.get(SCSettingsSPKey.material) is String && SCSettingsUtils.get(SCSettingsSPKey.material) != "default") {
        SCSettingsUtils.set(SCSettingsSPKey.material, "default");
      }
    }

    super.initState();
  }

  Widget _panel1() {
    /* ============================== 主题 ==============================*/
    List<ComboBoxItem<String>> themeItem = [];
    _themeType.forEach((key, value) {
      themeItem.add(ComboBoxItem(
        value: key,
        child: Text(value))
      );
    });

    Widget theme = SCItemCard(
      icon: FluentIcons.color,
      title: "主题",
      description: "亮色、深色还是跟随系统呢？",
      rightChild: ComboBox<String>(
        value: SCSettingsUtils.get(SCSettingsSPKey.theme) is String ? SCSettingsUtils.get(SCSettingsSPKey.theme) : "auto",
        items: themeItem,
        onChanged: (value) {
          SCSettingsUtils.set(SCSettingsSPKey.theme, value);
          ref.read(themeRiverpod.notifier).setTheme(value!);
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
    
    Widget background = SCItemCard(
      icon: FluentIcons.bucket_color,
      title: "背景材质",
      description: "更改窗体背景材质",
      rightChild: ComboBox<String>(
        value: SCSettingsUtils.get(SCSettingsSPKey.material) is String ? SCSettingsUtils.get(SCSettingsSPKey.material) : "mica",
        items: backgroundItem,
        onChanged: _isDisableMaterial ? null : (value) {
          SCSettingsUtils.set(SCSettingsSPKey.material, value);
          ref.read(themeRiverpod.notifier).setMaterial(value!);
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

    Widget lang = SCItemCard(
      icon: FluentIcons.locale_language,
      title: "语言",
      description: "SRCat 界面显示语言 | PS: 暂时没做",
      rightChild: ComboBox<String>(
        value: SCSettingsUtils.get(SCSettingsSPKey.language) is String ? SCSettingsUtils.get(SCSettingsSPKey.language) : "zh_CN",
        items: languageItem,
        onChanged: (value) {
          SCSettingsUtils.set(SCSettingsSPKey.language, value);
          setState(() => {});
        },
      ),
    );
    /* ============================== 语言[END] ==============================*/

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[theme, background, lang],
    );
  }

  Widget _panel2() {
    const XTypeGroup typeGroup = XTypeGroup(
      label: "exe",
      extensions: <String>["exe"]
    );

    void displayBar({
      required String title,
      required String text,
      InfoBarSeverity severity = InfoBarSeverity.error
    }) {
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: Text(title),
          content: Text(text),
          action: IconButton(
           icon: const Icon(FluentIcons.clear),
           onPressed: () => {}
          ),
          severity: severity,
       );
      });
    }

    Widget selectHSR = SCItemCard(
      icon: FluentIcons.game,
      title: "游戏路径",
      description: SCSettingsUtils.get(SCSettingsSPKey.hsrExe) is String ? SCSettingsUtils.get(SCSettingsSPKey.hsrExe) : "暂未选择",
      rightChild: const SCIcon(FluentIcons.chevron_right_small, size: 15),
      onTap: () {
        openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]).then((value) async {
          if (value?.path == null || value?.name == null) {
            displayBar(title: "警告：", text: "您未选择游戏本体 (StarRail.exe)", severity: InfoBarSeverity.warning);
          } else if (value?.name != "StarRail.exe") {
            displayBar(title: "错误：", text: "您选择的不是游戏本体，请选择 StarRail.exe");
          } else {
            SCSettingsUtils.set(SCSettingsSPKey.hsrExe, value?.path);
            displayBar(title: "好耶！", text: "已成功更新游戏路径", severity: InfoBarSeverity.success);
          }
        });
      }
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 15),
        selectHSR
      ],
    );
  }

  Widget _panel3() {
    Widget version = SCItemCard(
      icon: SRCatIcon.cat_food,
      title: "SRCat",
      description: "Ver.1.0.0",
      rightChild: const SCIcon(FluentIcons.link12, size: 20),
      onTap: () => launchUrl(Uri.parse("https://srcat.boxcat.org")),
    );

    Widget github = SCItemCard(
      icon: SRCatIcon.github,
      title: "GitHub",
      description: "https://github.com/BoxCatTeam/SRCat",
      rightChild: const SCIcon(FluentIcons.link12, size: 20),
      onTap: () => launchUrl(Uri.parse("https://github.com/BoxCatTeam/SRCat")),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 15),
        const Text("关于", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 5),
        version, github
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_panel1(), _panel2(), _panel3()],
    );

    return SCNormalScroll(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: child,
      )
    );
  }
}
