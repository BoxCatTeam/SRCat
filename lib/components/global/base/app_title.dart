/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 05:43:01
/// LastEditTime: 2023-05-09 21:24:09
/// FilePath: /lib/components/global/base/app_title.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

class SRCatAppTitle extends StatefulWidget {
  const SRCatAppTitle({
    Key? key,
    this.size = 20,
    this.useCatFont = true,
  }) : super(key: key);

  /// 标题大小
  final double size;

  /// Nya~
  final bool useCatFont;

  @override
  State<SRCatAppTitle> createState() => _SRCatAppTitleState();
}

class _SRCatAppTitleState extends State<SRCatAppTitle> {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: widget.size, fontFamily: "VarelaRound"),
        children: <InlineSpan>[
          const TextSpan(
            style: TextStyle(color: Color.fromRGBO(30, 136, 229, 1)),
            children: <InlineSpan>[
              TextSpan(text: "S"),
              TextSpan(text: "R"),
            ]
          ),
          TextSpan(
            style: const TextStyle(color: Color.fromRGBO(255, 112, 67, 1)),
            children: <InlineSpan>[
              TextSpan(text: "C", style: TextStyle(
                fontFamily: widget.useCatFont ? "Cattie" : null,
                fontWeight: FontWeight.w600
              )),
              const TextSpan(text: "a"),
              const TextSpan(text: "t"),
            ]
          ),
        ]
      )
    );
  }
}
