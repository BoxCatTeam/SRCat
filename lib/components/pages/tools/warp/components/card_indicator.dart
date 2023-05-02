/// 卡片指示器
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-29 06:34:52
/// LastEditTime: 2023-04-29 06:45:20
/// FilePath: /lib/components/pages/tools/wrap/components/card_indicator.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

class WarpContentCardIndicator extends StatefulWidget {
  const WarpContentCardIndicator({
    Key? key,
    required this.text,
    required this.num,
    required this.valuePercent,
    required this.color,
  }) : super(key: key);

  /// 文字内容
  final String text;

  /// 抽数
  final String num;

  /// 百分比
  final double valuePercent;

  /// 颜色
  final Color color;

  @override
  State<WarpContentCardIndicator> createState() => _WarpContentCardIndicatorState();
}

class _WarpContentCardIndicatorState extends State<WarpContentCardIndicator> {
  Widget _content() => Row(
    children: <Widget>[
      // 数量
      Expanded(flex: 2, child: SizedBox(
        height: double.infinity,
        child: Align(child: Text(widget.num, style: TextStyle(
          color: widget.color,
          fontSize: 20,
        ))),
      )),

      // 文字
      Expanded(flex: 3, child: SizedBox(
        height: double.infinity,
        child: Align(alignment: Alignment.centerLeft, child: Container(
          margin: const EdgeInsets.only(left: 5),
          child: Text(widget.text, style: TextStyle(
            color: widget.color,
            fontSize: 16,
          )
        )))
      ))
    ],
  );

  // 进度条
  Widget _progress() => ProgressBar(
    value: widget.valuePercent,
    activeColor: widget.color
  );

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          Column(children: [Expanded(child: _content())]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 1),
              child: _progress()
            ),
          )
        ],
      )
    );

    return SizedBox(
      height: 40,
      width: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: card
      )
    );
  }
}
