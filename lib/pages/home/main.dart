/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 18:24:05
/// LastEditTime: 2023-05-03 03:04:31
/// FilePath: /lib/pages/home/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/config/api.dart';
import 'package:srcat/icons/iconfont/srcat.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasNewVer = false;
  String _downloadUrl = "";

  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  void _checkUpdate() async {
    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(SRCatAPIConfig.checkUpdate),
      success: (response, content) {
        if (content["latest_version"] > Application.appNumVersion) {
          _hasNewVer = true;
          _downloadUrl = content["update_url"];
          setState(() {});
        }
      },
      fail: (code, message, failType, dioError) {}
    );
  }

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

    Widget newVerButton = Button(
      child: Row(
        children: const <Widget>[
          SCIcon(SRCatIcon.cat_food, size: 25),
          SizedBox(width: 5),
          Text("有新版本~", style: TextStyle(fontSize: 20, color: Color.fromRGBO(255, 112, 67, 1)))
        ],
      ),
      onPressed: () => launchUrl(Uri.parse(_downloadUrl))
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 40, child: button(SRCatIcon.github, "GitHub", "https://github.com/BoxCatTeam/SRCat")),
        _hasNewVer ? Container(height: 40, margin: const EdgeInsets.only(left: 10), child: newVerButton) : Container(),
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
