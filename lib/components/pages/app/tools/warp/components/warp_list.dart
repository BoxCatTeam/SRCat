/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 10:26:51
/// LastEditTime: 2023-05-18 09:06:09
/// FilePath: /lib/components/pages/app/tools/warp/components/warp_list.dart
/// ===========================================================================

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/libs/srcat/warp/data.dart';
import 'package:srcat/utils/main.dart';
import 'package:srcat/components/global/scroll/normal.dart';

class WarpContentList extends StatefulWidget {
  const WarpContentList({
    Key? key,
    required this.items
  }) : super(key: key);

  /// 列表项
  final List<WarpContentListItem> items;

  @override
  State<WarpContentList> createState() => _WarpContentListState();
}

class _WarpContentListState extends State<WarpContentList> {
  @override
  Widget build(BuildContext context) {
    Widget scs = SRCatNormalScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...widget.items]
      )
    );

    return SizedBox(height: double.infinity, child: scs);
  }
}

enum WarpContentListItemType {
  /// 角色
  character,
  /// 光锥
  lightcone,
  /// 未知
  unknown
}

class WarpContentListItem extends StatefulWidget {
  const WarpContentListItem({
    Key? key,
    required this.id,
    this.type = WarpContentListItemType.character,
    this.isUP = false,
    required this.lastNum,
    this.isGuaranteed = false,
    required this.time
  }) : super(key: key);

  /// ID
  final int id;

  /// 类型
  final WarpContentListItemType type;

  /// 是否 UP
  final bool isUP;

  /// 距离上次出金已过抽数
  final int lastNum;

  /// 是否保底
  final bool isGuaranteed;

  /// 时间
  final int time;

  @override
  State<WarpContentListItem> createState() => _WarpContentListItemState();
}

class _WarpContentListItemState extends State<WarpContentListItem> {
  String _name = "";
  int _nameColor = 0xffec407a;
  String _avatarPath = "";

  @override
  void initState() {
    super.initState();

    if (widget.type == WarpContentListItemType.character) {
      SRCatWarpDataLib.character().then((value) async => await _parseInfo(value));
    }
    if (widget.type == WarpContentListItemType.lightcone) {
      SRCatWarpDataLib.lightcone().then((value) async => await _parseInfo(value));
    }
  }

  Future<void> _parseInfo(List<Map<String, dynamic>>? value) async {
    if (value == null || value.isEmpty) return;

    for(int index = 0; index < value.length; index++) {
      if (value[index]["item_id"] == widget.id) {
        _name = value[index]["name"];
        _nameColor = value[index]["color"].isEmpty || value[index]["color"] == ""
          ? 0xffec407a :
          int.parse("0xff${value[index]["color"]}");
        
        _avatarPath = await SRCatWarpDataLib.image(value[index]["avatar"]) ?? "";
      }
    }

    setState(() {});
  }

  /// Avatar
  Widget _avatar() {
    /// 获取头像路径
    String path = "assets/images/srcat/pom-5.png";
    
    Widget avatar = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        image: DecorationImage(
          image:(_avatarPath != "" ?
            FileImage(File(_avatarPath))
            : AssetImage(path)
          ) as ImageProvider,
          fit: BoxFit.contain,
        )
      ),
    );

    return avatar;
  }

  /// Name
  Widget _title() {
    Widget title = Text(_name, style: TextStyle(
      fontSize: 16,
      color: Color(_nameColor)
    ));

    return title;
  }

  /// Right
  Widget _right() {
    Widget up = Text("UP", style: TextStyle(
      fontSize: 14,
      color: Colors.orange.normal
    ));

    /// 距今抽数
    Widget lastNum = Text(widget.lastNum.toString(), style: const TextStyle(fontSize: 16));

    /// 是否保底
    Widget isGuaranteed = Text("保底", style: TextStyle(
      fontSize: 14,
      color: Colors.blue.light
    ));

    Widget child = Row(
      children: <Widget>[
        Expanded(child: widget.isGuaranteed ? Center(child: isGuaranteed) : Container()),
        Expanded(child: widget.isUP ? Center(child: up) : Container()),
        Expanded(child: Center(child: lastNum))
      ],
    );

    return SizedBox(width: 100, child: child);
  }
  
  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      children: <Widget>[
        _avatar(),
        const SizedBox(width: 8),
        _title(),
        Expanded(child: Container()),
        _right(),
        const SizedBox(width: 8),
      ]
    );

    Widget item = Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Card(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: child
      ),
    );

    return Tooltip(
      message: "$_name：${SRCatUtils.unixTimeToStr(widget.time, format: "yyyy-MM-dd HH:mm:ss")}",
      triggerMode: TooltipTriggerMode.longPress,
      child: item,
    );
  }
}
