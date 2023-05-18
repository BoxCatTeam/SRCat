/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 10:22:04
/// LastEditTime: 2023-05-18 08:37:28
/// FilePath: /lib/components/pages/app/tools/warp/record_panel.dart
/// ===========================================================================

// ignore_for_file: unused_local_variable

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:srcat/utils/main.dart';
import 'package:srcat/libs/srcat/warp/main.dart';
import 'package:srcat/libs/srcat/warp/utils.dart';

import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/components/global/scroll/normal.dart';

import 'components/warp_list.dart';
import 'components/card_indicator.dart';

class WarpRecordPanel extends StatefulWidget {
  const WarpRecordPanel({
    Key? key,
    required this.title,
    required this.data,
    required this.type,
    this.height = 200,
    this.disableInfoScroll = false,
    required this.gachaPool,
  }) : super(key: key);

  /// 面板标题
  final String title;

  /// 数据
  final List<Map<String, dynamic>> data;

  /// 类型
  final GachaWarpType type;

  /// 高度
  final double height;

  /// 禁用详细面板滚动
  final bool disableInfoScroll;

  /// 卡池数据
  final List<Map<String, dynamic>> gachaPool;

  @override
  State<WarpRecordPanel> createState() => _WarpRecordPanelState();
}

class _WarpRecordPanelState extends State<WarpRecordPanel> {
  int touchedIndex = -1;

  /// 三星光锥颜色
  final Color star3LigheCone = Colors.blue.light;
  /// 四星光锥颜色
  final Color star4LigheCone = Colors.green.light;
  /// 四星角色颜色
  final Color star4Character = Colors.magenta.light;
  /// 五星角色颜色
  final Color star5Character = Colors.orange.normal;
  /// 五星光锥颜色
  final Color star5LigheCone = Colors.red.light;

  /// 五星角色
  final List<dynamic> star5CharacterData = [];
  /// 五星光锥
  final List<dynamic> star5LigheConeData = [];
  /// 四星角色
  final List<dynamic> star4CharacterData = [];
  /// 四星光锥
  final List<dynamic> star4LigheConeData = [];
  /// 三星光锥
  final List<dynamic> star3LigheConeData = [];

  /// 五星
  List<Map<String, dynamic>> star5 = [];

  /// 抽卡时间合集
  final List<int> times = [];
  /// 抽卡时间区间 [min, max]
  List<int> timesRange = [];

  /// 已处理的数据
  List<Map<String, dynamic>> resultData = [];

  @override
  void initState() {
    super.initState();

    for (var item in widget.data) {
      switch (item['item_type']) {
        case 'character':
          if (item['rank_type'] == 5) {
            star5CharacterData.add(item);
          } else if (item['rank_type'] == 4) {
            star4CharacterData.add(item);
          }
          break;
        case 'lightcone':
          if (item['rank_type'] == 5) {
            star5LigheConeData.add(item);
          } else if (item['rank_type'] == 4) {
            star4LigheConeData.add(item);
          } else if (item['rank_type'] == 3) {
            star3LigheConeData.add(item);
          }
          break;
      }
    }

    for (var item in widget.data) {
      times.add(item['time']);
    }
    timesRange = SRCatWarpUtilsLib.timeRange(times);
    resultData = SRCatWarpUtilsLib.parseStar5(widget.data);
    star5 = SRCatWarpUtilsLib.parseGuaranteed(resultData, widget.gachaPool, type: widget.type);
  }

  Widget _header() {
    Widget icon = const SRCatIcon(FluentIcons.starburst, size: 16, weight: FontWeight.w600);
    Widget title = Text(widget.title, style: const TextStyle(fontSize: 16,));

    return Row(
      children: <Widget>[icon, const SizedBox(width: 8), title],
    );
  }

  Widget _content() {
    // 饼状图
    Widget pieChart = PieChart(
      PieChartData(
        sections: showingSections(),
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          }
        )
      )
    );

    Widget divider = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: const Divider(direction: Axis.vertical)
    );

    Widget cardTextItem(String start, String end) {
      return Row(
        children: [
          Text(start, style: const TextStyle(fontSize: 14)),
          Expanded(child: Container()),
          Text(end, style: const TextStyle(fontSize: 14)),
        ],
      );
    }

    List<Widget> cardChildItem = [];

    if (widget.type == GachaWarpType.regular || widget.type == GachaWarpType.starter) {
      cardChildItem = [
        Row(children: <Widget>[
          Expanded(child: WarpContentCardIndicator(text: "五星角色", valuePercent: 100, num: star5CharacterData.length.toString(), color: star5Character)),
          const SizedBox(width: 10),
          Expanded(child: WarpContentCardIndicator(text: "五星光锥", valuePercent: 100, num: star5LigheConeData.length.toString(), color: star5LigheCone)),
        ]),
        const SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(child: WarpContentCardIndicator(text: "四星角色", valuePercent: 100, num: star4CharacterData.length.toString(), color: star4Character)),
          const SizedBox(width: 10),
          Expanded(child: WarpContentCardIndicator(text: "四星光锥", valuePercent: 100, num: star4LigheConeData.length.toString(), color: star4LigheCone)),
        ]),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: WarpContentCardIndicator(text: "三星光锥", valuePercent: 100, num: star3LigheConeData.length.toString(), color: star3LigheCone)),
      ];
    }

    if (widget.type == GachaWarpType.character) {
      cardChildItem = [
        Row(children: <Widget>[
          Expanded(child: WarpContentCardIndicator(text: "五星角色", valuePercent: 100, num: star5CharacterData.length.toString(), color: star5Character)),
          const SizedBox(width: 10),
          Expanded(child: WarpContentCardIndicator(text: "四星角色", valuePercent: 100, num: star4CharacterData.length.toString(), color: star4Character)),
        ]),
        const SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(child: WarpContentCardIndicator(text: "四星光锥", valuePercent: 100, num: star4LigheConeData.length.toString(), color: star4LigheCone)),
          const SizedBox(width: 10),
          Expanded(child: WarpContentCardIndicator(text: "三星光锥", valuePercent: 100, num: star3LigheConeData.length.toString(), color: star3LigheCone)),
        ]),
      ];
    }

    if (widget.type == GachaWarpType.lightCone) {
      cardChildItem = [
        Row(children: <Widget>[
          Expanded(child: WarpContentCardIndicator(text: "五星光锥", valuePercent: 100, num: star5LigheConeData.length.toString(), color: star5LigheCone)),
          const SizedBox(width: 10),
          Expanded(child: WarpContentCardIndicator(text: "四星光锥", valuePercent: 100, num: star4LigheConeData.length.toString(), color: star4LigheCone)),
        ]),
        const SizedBox(height: 10),
        Row(children: <Widget>[
          Expanded(child: WarpContentCardIndicator(text: "四星角色", valuePercent: 100, num: star4CharacterData.length.toString(), color: star4Character)),
          const SizedBox(width: 10),
          Expanded(child: WarpContentCardIndicator(text: "三星光锥", valuePercent: 100, num: star3LigheConeData.length.toString(), color: star3LigheCone)),
        ]),
      ];
    }

    List<int> upAndDownRange = SRCatWarpUtilsLib.upAndDownRange(resultData);

    Widget cardItems = Column(
      children: <Widget>[
        ...cardChildItem,

        const SizedBox(height: 18),
        cardTextItem("总抽数", "${widget.data.length} 抽"),
        const SizedBox(height: 2),
        widget.type == GachaWarpType.character || widget.type == GachaWarpType.lightCone ? cardTextItem("UP 平均抽数", "${SRCatWarpUtilsLib.upAverage(star5, 5)} 抽") : Container(),
        SizedBox(height: widget.type == GachaWarpType.character || widget.type == GachaWarpType.lightCone ? 2 : 0),
        cardTextItem("五星平均抽数", "${SRCatWarpUtilsLib.star5Average(resultData)} 抽"),
        SizedBox(height: widget.type == GachaWarpType.character || widget.type == GachaWarpType.lightCone ? 2 : 0),
        widget.type != GachaWarpType.starter ? cardTextItem("最欧 ${upAndDownRange[0]} 抽", "最非 ${upAndDownRange[1]} 抽") : Container(),
      ],
    );

    Widget warpListEmpty = SizedBox(
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 103,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/srcat/pom-5.png"),
                fit: BoxFit.cover
              )
            ),
          ),
          const SizedBox(height: 10),
          const Text("坏欸，空的！", style: TextStyle(fontSize: 18))
        ],
      ),
    );

    /// 谁叫你这么缩写变量名的？
    List<WarpContentListItem> wclitem = [];
    /// 类型转换
    WarpContentListItemType getWarpContentType(String itemType) {
      switch (itemType) {
        case "lightcone":
          return WarpContentListItemType.lightcone;
        case "character":
          return WarpContentListItemType.character;
        default:
          return WarpContentListItemType.unknown;
      }
    }
    
    for (Map<String, dynamic> gacha in star5) {
      if (gacha["rank_type"] == 5) {
        wclitem.add(WarpContentListItem(
          id: gacha["item_id"],
          type: getWarpContentType(gacha["item_type"]),
          lastNum: gacha["lastNum"] != null && gacha["lastNum"] is int ? gacha["lastNum"] : 0,
          time: gacha["time"],
          isUP: gacha["isUP"] != null && gacha["isUP"] is bool ? gacha["isUP"] : false,
          isGuaranteed: gacha["isGuaranteed"] != null && gacha["isGuaranteed"] is bool ? gacha["isGuaranteed"] : false,
        ));
      }
    }
    

    Widget warpList = Expanded(child: star5.isEmpty ? warpListEmpty : WarpContentList(
      items: <WarpContentListItem>[...wclitem],
    ));

    String time = "";
    String timeFormat = "yyyy.MM.dd";

    if (!timesRange[0].isNaN && !timesRange[1].isNaN) {
      time = "${SRCatUtils.unixTimeToStr(timesRange[0], format: timeFormat)}-${SRCatUtils.unixTimeToStr(timesRange[1], format: timeFormat)}";
    } else if (!timesRange[0].isNaN && timesRange[1].isNaN) {
      time = "${SRCatUtils.unixTimeToStr(timesRange[0], format: timeFormat)}";
    }

    return SizedBox(
      height: widget.height,
      child: Row(
        children: <Widget>[
          SizedBox(width: 200, child: Column(children: <Widget>[
            Expanded(child: pieChart),
            const SizedBox(height: 10),
            Text(time, style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: (FluentTheme.of(context).brightness.isDark ? Colors.white : Colors.black).withOpacity(0.8)
            ))
          ])),
          const SizedBox(width: 10),
          divider,
          const SizedBox(width: 10),
          SizedBox(
            width: 300,
            child: SRCatNormalScroll(
              hiddenBar: true,
              physics: widget.disableInfoScroll ? const NeverScrollableScrollPhysics() : null,
              child: cardItems
            )
          ),
          const SizedBox(width: 10),
          divider,
          const SizedBox(width: 10),
          warpList
        ],
      ),
    );
  }

  Widget _emptyPage() {
    return SizedBox(
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 98,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/srcat/syq-5.png"),
                fit: BoxFit.cover
              )
            ),
          ),
          const SizedBox(height: 10),
          const Text("没有数据欸...", style: TextStyle(fontSize: 18))
        ],
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Widget panel = Expander(
      initiallyExpanded: true,
      header: _header(),
      content: widget.data.isEmpty ? _emptyPage(): _content(),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: panel,
    );
  }

  /// 饼状图数据源
  List<PieChartSectionData> showingSections() {
    PieChartSectionData data(int index, {
      String? title,
      required double value,
      required Color color,
    }) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      return PieChartSectionData(
        color: color,
        title: title,
        value: value,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          color: Colors.transparent,
        )
      );
    }

    List<PieChartSectionData> pdata = [];

    /// 角色 UP 池
    if (widget.type == GachaWarpType.character) {
      double v0 = star5CharacterData.length / widget.data.length * 100;
      double v1 = star4LigheConeData.length / widget.data.length * 100;
      double v2 = star4CharacterData.length / widget.data.length * 100;
      double v3 = star3LigheConeData.length / widget.data.length * 100;
      pdata = [
        data(0, value: v0, color: star5Character),  // 五星角色
        data(1, value: v1, color: star4LigheCone),  // 四星光锥
        data(2, value: v2, color: star4Character),  // 四星角色
        //data(3, value: v3, color: star3LigheCone),  // 三星光锥
      ];
    }

    if (widget.type == GachaWarpType.lightCone) {
      double v0 = star5LigheConeData.length / widget.data.length * 100;
      double v1 = star4LigheConeData.length / widget.data.length * 100;
      double v2 = star4CharacterData.length / widget.data.length * 100;
      double v3 = star3LigheConeData.length / widget.data.length * 100;
      pdata = [
        data(0, value: v0, color: star5LigheCone),  // 五星光锥
        data(1, value: v1, color: star4LigheCone),  // 四星光锥
        data(2, value: v2, color: star4Character),  // 四星角色
        //data(3, value: v3, color: star3LigheCone),  // 三星光锥
      ];
    }

    if (widget.type == GachaWarpType.regular || widget.type == GachaWarpType.starter) {
      double v0 = star5LigheConeData.length / widget.data.length * 100;
      double v1 = star5CharacterData.length / widget.data.length * 100;
      double v2 = star4LigheConeData.length / widget.data.length * 100;
      double v3 = star4CharacterData.length / widget.data.length * 100;
      double v4 = star3LigheConeData.length / widget.data.length * 100;
      pdata = [
        data(0, value: v0, color: star5LigheCone),  // 五星光锥
        data(1, value: v1, color: star5Character),  // 五星角色
        data(2, value: v2, color: star4LigheCone),  // 四星光锥
        data(3, value: v3, color: star4Character),  // 四星角色
        //data(4, value: v4, color: star3LigheCone),  // 三星光锥
      ];
    }

    return pdata;
  }
}
