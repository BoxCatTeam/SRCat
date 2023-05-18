/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 01:10:32
/// LastEditTime: 2023-05-07 02:12:15
/// FilePath: /lib/pages/app/home/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

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

  /// 内容
  Widget _content() {
    return const Text("一个还在开发中的「崩坏：星穹铁道」工具箱", style: TextStyle(fontSize: 20));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[_title(), _content()],
    ); 
  }
}
