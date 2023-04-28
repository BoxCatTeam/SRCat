/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 23:33:29
/// LastEditTime: 2023-04-29 01:28:20
/// FilePath: /lib/pages/settings/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/scroll/normal.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget _panel1() {
    Widget theme = SCItemCard(
      icon: FluentIcons.color,
      title: "主题",
      description: "亮色、深色还是跟随系统呢？",
      rightChild: ComboBox<String>(
        value: "auto",
        items: const <ComboBoxItem<String>>[
          ComboBoxItem(value: "auto", child: Text("跟随系统")),
          ComboBoxItem(value: "dark", child: Text("亮色")),
          ComboBoxItem(value: "light", child: Text("深色")),
        ],
        onChanged: (value) => {},
      ),
    );

    Widget background = SCItemCard(
      icon: FluentIcons.bucket_color,
      title: "背景材质",
      description: "更改窗体背景材质",
      rightChild: ComboBox<String>(
        value: "mica",
        items: const <ComboBoxItem<String>>[
          ComboBoxItem(value: "mica", child: Text("Mica")),
          ComboBoxItem(value: "arylic", child: Text("Arylic")),
          ComboBoxItem(value: "tabbed", child: Text("Tabbed")),
        ],
        onChanged: (value) => {},
      ),
    );
    
    Widget lang = SCItemCard(
      icon: FluentIcons.locale_language,
      title: "语言",
      description: "SRCat 界面显示语言",
      rightChild: ComboBox<String>(
        value: "zh_CN",
        items: const <ComboBoxItem<String>>[
          ComboBoxItem(value: "zh_CN", child: Text("中文（简体）"))
        ],
        onChanged: (value) => {},
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[theme, background, lang],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_panel1()],
    );

    return SCNormalScroll(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: child,
      )
    );
  }
}
