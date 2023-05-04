/// 跃迁记录
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 19:08:54
/// LastEditTime: 2023-05-04 23:20:25
/// FilePath: /lib/pages/tools/warp.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/components/global/scroll/normal.dart';
import 'package:srcat/components/pages/tools/warp/record_panel.dart';
import 'package:srcat/libs/img/pak_loader.dart';
import 'package:srcat/libs/sr/services/tools/warp/cache_update.dart';
import 'package:srcat/libs/sr/services/tools/warp/db.dart';
import 'package:srcat/libs/sr/services/tools/warp/main.dart';

class ToolsWarpPage extends StatefulWidget {
  const ToolsWarpPage({
    Key? key,
    this.uid
  }) : super(key: key);

  /// 判断是否有 uid
  final String? uid;

  @override
  State<ToolsWarpPage> createState() => _ToolsWarpPageState();
}

class _ToolsWarpPageState extends State<ToolsWarpPage> {
  bool _loadStatus = false;
  int _nowSelectedUID = 0;
  late List<Map<String, Object?>> _warpUsers = [];
  bool _loadGachaLog = false;
  late final Map<GachaWarpType, dynamic> _gachaLog = {};
  final _stateKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    SrWrapToolDatabaseService.allWarpUser().then((value) async {
      _warpUsers = value;
      _loadStatus = true;
      if (_warpUsers.isEmpty) {
        setState(() {});
        return;
      }
      _nowSelectedUID = int.parse(widget.uid ?? value[0]["uid"].toString());

      _gachaLog[GachaWarpType.regular] = await SrWrapToolDatabaseService.userGachaLog(
        uid:_nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.regular]
      );

      _gachaLog[GachaWarpType.lightCone] = await SrWrapToolDatabaseService.userGachaLog(
        uid:_nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.lightCone]
      );

      _gachaLog[GachaWarpType.character] = await SrWrapToolDatabaseService.userGachaLog(
        uid:_nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.character]
      );

      _gachaLog[GachaWarpType.starter] = await SrWrapToolDatabaseService.userGachaLog(
        uid:_nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.starter]
      );

      await Future.delayed(const Duration(seconds: 1));

      _loadGachaLog = true;
      setState(() {});
    });

    super.initState();
  }

  Widget _bar() {
    Widget dorpDownButton({
      required IconData icon,
      String? text,
      required List<MenuFlyoutItemBase> items
    }) {
      return DropDownButton(
        trailing: null,
        items: items,
        buttonBuilder: (context, onOpen) => IconButton(
          icon: Row(
            children: [
              SCIcon(icon, size: 16, weight: FontWeight.w600),
              if (text != null) const SizedBox(width: 5),
              if (text != null) Text(text, style: const TextStyle(fontSize: 15))
            ],
          ),
          onPressed: () => onOpen!(),
        ),
      );
    }

    Widget divider = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 10),
      child: const Divider(direction: Axis.vertical)
    );

    Widget refreshBtn = dorpDownButton(
      icon: FluentIcons.refresh,
      text: "刷新",
      items: <MenuFlyoutItemBase>[
        /*MenuFlyoutItem(
          leading: const SCIcon(FluentIcons.globe, size: 16, weight: FontWeight.w600),
          text: const Text("代理刷新"),
          onPressed: null
        ),*/
        MenuFlyoutItem(
          leading: const SCIcon(FluentIcons.apps_content, size: 16, weight: FontWeight.w600),
          text: const Text("网页缓存刷新"),
          onPressed: () async => refreshGachaLog()
        ),
        /*MenuFlyoutItem(
          leading: const SCIcon(FluentIcons.link12, size: 16, weight: FontWeight.w600),
          text: const Text("手动输入链接刷新"),
          onPressed: () {}
        ),*/
      ],
    );

    /*Widget importOrOutputButton = dorpDownButton(
      icon: FluentIcons.sharei_o_s,
      text: "导入/导出",
      items: <MenuFlyoutItemBase>[
        MenuFlyoutItem(
          leading: const SCIcon(FluentIcons.save, size: 16, weight: FontWeight.w600),
          text: const Text("导入"),
          onPressed: () {}
        ),
        MenuFlyoutItem(
          leading: const SCIcon(FluentIcons.save_as, size: 16, weight: FontWeight.w600),
          text: const Text("导出"),
          onPressed: () {}
        )
      ],
    );*/

    Widget actions = Row(
      children: <Widget>[
        refreshBtn,
        divider,
        //importOrOutputButton
      ],
    );

    Widget profileSelect = ComboBox<String>(
      value: _nowSelectedUID.toString(),
      items: _warpUsers.map(
        (item) => ComboBoxItem(value: item["uid"].toString(), child: Text(item["uid"].toString()))
      ).toList(),
      onChanged: (value) {
        if (value != null && value != _nowSelectedUID.toString()) {
          Application.router.push("/tools/warp?uid=$value");
        }
      },
    );

    /*Widget deleteButton = Tooltip(
      message: "删除当前记录",
      child: IconButton(
        icon: SCIcon(
          FluentIcons.delete,
          size: 16,
          weight: FontWeight.w600,
          color: Colors.red
        ),
        onPressed: () => {},
      )
    );*/

    return SizedBox(
      height: 50,
      child: Card(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            actions,
            Expanded(child: Container()),
            SizedBox(
              width: 150,
              child: profileSelect,
            ),
            const SizedBox(width: 8),
            divider,
            const SizedBox(width: 2),
            //deleteButton
          ],
        ),
      )
    );
  }

  Widget _content() {
    // 常驻
    Widget regular = WarpRecordPanel(
      title: "群星跃迁",
      height: 260,
      data: _gachaLog[GachaWarpType.regular],
      type: GachaWarpType.regular,
    );

    // 角色 UP / Character UP
    Widget characterUP = WarpRecordPanel(
      title: "角色活动",
      data: _gachaLog[GachaWarpType.character],
      type: GachaWarpType.character,
    );

    // 光锥 UP / Light Cone UP
    Widget lightConeUP = WarpRecordPanel(
      title: "流光定影",
      data: _gachaLog[GachaWarpType.lightCone],
      type: GachaWarpType.lightCone,
    );

    // 始发跃迁 / Starter
    Widget starter = WarpRecordPanel(
      title: "始发跃迁",
      height: 240,
      disableInfoScroll: true,
      data: _gachaLog[GachaWarpType.starter],
      type: GachaWarpType.starter,
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          characterUP,
          const SizedBox(height: 15),
          lightConeUP,
          const SizedBox(height: 15),
          regular,
          const SizedBox(height: 15),
          starter
        ],
      )
    );
  }

  /// 加载页面
  Widget _loadPage() {
    return const Center(
      child: ProgressRing(
        strokeWidth: 5,
      ),
    );
  }

  /// 空白的页面
  Widget _emptyPage() {
    Widget left = Container(
      width: 160,
      height: 137,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(SRCatPackLoader.parse(SRCatImagePack.smile_hm_7_pack)),
          fit: BoxFit.cover
        )
      ),
    );

    Widget divider = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 180),
      child: const Divider(direction: Axis.vertical)
    );

    Widget right = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text("获取跃迁数据...", style: TextStyle(
          fontSize: 20
        )),
        const SizedBox(height: 15),
        SCItemCard(
          title: "从网页缓存获取",
          description: "需要在游戏中打开一次抽卡记录页面",
          icon: FluentIcons.apps_content,
          rightChild: const SCIcon(FluentIcons.chevron_right_small, size: 18),
          onTap: () async => refreshGachaLog()
        ),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        left,
        const SizedBox(width: 15),
        divider,
        const SizedBox(width: 15),
        SizedBox(width: 320, child: right)
      ],
    );
  }

  /// 刷新数据
  void refreshGachaLog() async {
    await SrWrapToolCacheUpdateService.init(_stateKey.currentContext!);
    _warpUsers = await SrWrapToolDatabaseService.allWarpUser();
    _loadStatus = true;
    _nowSelectedUID = _nowSelectedUID == 0 ? int.parse(_warpUsers[0]["uid"].toString()) : _nowSelectedUID;

    _gachaLog[GachaWarpType.regular] = await SrWrapToolDatabaseService.userGachaLog(
      uid: _nowSelectedUID,
      gachaType: gachaWarpTypeValue[GachaWarpType.regular]
    );

    _gachaLog[GachaWarpType.lightCone] = await SrWrapToolDatabaseService.userGachaLog(
      uid: _nowSelectedUID,
      gachaType: gachaWarpTypeValue[GachaWarpType.lightCone]
    );

    _gachaLog[GachaWarpType.character] = await SrWrapToolDatabaseService.userGachaLog(
      uid: _nowSelectedUID,
      gachaType: gachaWarpTypeValue[GachaWarpType.character]
    );

    _gachaLog[GachaWarpType.starter] = await SrWrapToolDatabaseService.userGachaLog(
      uid: _nowSelectedUID,
      gachaType: gachaWarpTypeValue[GachaWarpType.starter]
    );

    await Future.delayed(const Duration(seconds: 1));

    _loadGachaLog = true;
    setState(() {});

    Application.router.push("/tools/warp");
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadStatus) {
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: _loadPage(),
      );
    } else {
      if (_warpUsers.isEmpty) {
        return SizedBox(
          key: _stateKey,
          height: double.infinity,
          width: double.infinity,
          child: _emptyPage(),
        );
      }
    }

    Widget column = Column(
      key: _stateKey,
      crossAxisAlignment: _loadGachaLog ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [_bar(), _loadGachaLog ? _content() : _loadPage()]
    );

    return _loadGachaLog == false ?
      column :
      SCNormalScroll(
        child: column
      );
  }
}
