/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 18:24:05
/// LastEditTime: 2023-04-28 22:43:10
/// FilePath: /lib/pages/home/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/icons/iconfont/srcat.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 标题
  Widget _title() {
    return const Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 80, fontFamily: "VarelaRound"),
        children: <InlineSpan>[
          TextSpan(
            style: TextStyle(color: Color.fromRGBO(30, 136, 229, 1)),
            children: <InlineSpan>[
              TextSpan(text: "S"),
              TextSpan(text: "R"),
            ]
          ),
          TextSpan(
            style: TextStyle(color: Color.fromRGBO(255, 112, 67, 1)),
            children: <InlineSpan>[
              TextSpan(text: "C", style: TextStyle(fontFamily: "Cattie", fontWeight: FontWeight.w600)),
              TextSpan(text: "a"),
              TextSpan(text: "t"),
            ]
          ),
        ]
      )
    );
  }

  /// 链接列表
  Widget _links() {
    void openLink(String url) async => await launchUrl(Uri.parse(url));

    Widget button(IconData icon, String? text, String? url) {
      return Button(child: Row(
        children: <Widget>[
          SCIcon(icon, size: 25),
          if (text != null) const SizedBox(width: 5),
          if (text != null) Text(text, style: const TextStyle(fontSize: 20))
        ],
      ), onPressed: () => {
        if (url != null) openLink(url)
      });
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        button(SRCatIcon.github, "GitHub", "https://github.com/BoxCatTeam/SRCat")
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[_title(), _links()],
    );
  }
}
