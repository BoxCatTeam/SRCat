/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 00:33:35
/// LastEditTime: 2023-07-21 02:53:44
/// FilePath: /lib/pages/app/tools/warp.dart
/// ===========================================================================

import 'package:srcat/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/compatible/warp_db.dart';

import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/components/global/scroll/page.dart';
import 'package:srcat/components/pages/app/tools/warp/record_panel.dart';
import 'package:srcat/libs/srcat/settings/main.dart';
//import 'package:srcat/libs/hoyolab/authkey.dart';
import 'package:srcat/libs/srcat/warp/data.dart';
import 'package:srcat/libs/srcat/warp/import.dart';
import 'package:srcat/libs/srcat/warp/output.dart';

import 'package:srcat/riverpod/global/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:srcat/libs/srcat/warp/db.dart';
import 'package:srcat/libs/srcat/warp/main.dart';
import 'package:srcat/libs/srcat/warp/update.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fluent_system_icons;
//import 'package:srcat/riverpod/global/user.dart';
//import 'package:srcat/utils/main.dart';

/// 工具 - 跃迁记录页面
class ToolsWarpPage extends ConsumerStatefulWidget {
  const ToolsWarpPage({
    Key? key,
    this.uid
  }) : super(key: key);

  /// 判断是否有 uid
  final String? uid;

  @override
  ConsumerState<ToolsWarpPage> createState() => _ToolsWarpPageState();
}

class _ToolsWarpPageState extends ConsumerState<ToolsWarpPage> {
  bool _loadStatus = false;
  int _nowSelectedUID = 0;
  List<Map<String, dynamic>> _gachaPool = [];
  late List<Map<String, Object?>> _warpUsers = [];
  bool _loadGachaLog = false;
  late final Map<GachaWarpType, dynamic> _gachaLog = {};
  final _stateKey = GlobalKey<NavigatorState>();
  bool _hasOldDatabase = false;
  String _userGachaLogLink = "";
  String _fullRefreshGachaLog = "false";
  String _showStarterGachaLog = "false";

  @override
  void initState() {
    super.initState();

    SRCatWarpDatabaseLib.allWarpUser().then((value) async {
      if (await SRCatWaroDatabaseCompatibleUtils.check()) {
        _hasOldDatabase = true;
      }

      _warpUsers = value;
      _loadStatus = true;

      if (_warpUsers.isEmpty) {
        setState(() {});
        return;
      }

      String selectUIDStr = value[0]["uid"].toString();
      for(Map<String, dynamic> item in value) {
        if (item["select"] == 1) {
          selectUIDStr = item["uid"].toString();
          break;
        }
      }

      int uid = int.parse(widget.uid ?? selectUIDStr);
      
      _nowSelectedUID = uid != 0 ? uid : int.parse(selectUIDStr);

      _gachaLog[GachaWarpType.regular] = await SRCatWarpDatabaseLib.userGachaLog(
        uid: _nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.regular]
      );

      _gachaLog[GachaWarpType.lightCone] = await SRCatWarpDatabaseLib.userGachaLog(
        uid: _nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.lightCone]
      );

      _gachaLog[GachaWarpType.character] = await SRCatWarpDatabaseLib.userGachaLog(
        uid: _nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.character]
      );

      _gachaLog[GachaWarpType.starter] = await SRCatWarpDatabaseLib.userGachaLog(
        uid: _nowSelectedUID,
        gachaType: gachaWarpTypeValue[GachaWarpType.starter]
      );

      List<Map<String, dynamic>>? gachaPool = await SRCatWarpDataLib.gachaPool();

      if (gachaPool != null) {
        _gachaPool = gachaPool;
      }

      _fullRefreshGachaLog = (await SRCatSettingsDatabaseLib.get(option: SRCatSettingsDatabaseKey.fullRefreshGachaLog, defaultValue: "false"))!;
      _showStarterGachaLog = (await SRCatSettingsDatabaseLib.get(option: SRCatSettingsDatabaseKey.showStarterGachaLog, defaultValue: "false"))!;

      await Future.delayed(const Duration(milliseconds: 500));
      _loadGachaLog = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
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
              SRCatIcon(icon, size: 16, weight: FontWeight.w600),
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
       /* MenuFlyoutItem(
          leading: const SRCatIcon(FluentIcons.globe, size: 16, weight: FontWeight.w600),
          text: const Text("SToken 刷新"),
          onPressed: () => _refreshGachaLogBySToken(),
        ),*/
        /*MenuFlyoutItem(
          leading: const SCIcon(FluentIcons.globe, size: 16, weight: FontWeight.w600),
          text: const Text("代理刷新"),
          onPressed: null
        ),*/
        MenuFlyoutItem(
          leading: const SRCatIcon(FluentIcons.apps_content, size: 16, weight: FontWeight.w600),
          text: const Text("网页缓存刷新"),
          onPressed: () async => _refreshGachaLog()
        ),
        MenuFlyoutItem(
          leading: const SRCatIcon(FluentIcons.link12, size: 16, weight: FontWeight.w600),
          text: const Text("手动输入链接刷新"),
          onPressed: () async => _refreshGachaLogFromLink()
        ),
      ],
    );

    Widget importOrOutputButton = dorpDownButton(
      icon: FluentIcons.sharei_o_s,
      text: "导入/导出",
      items: <MenuFlyoutItemBase>[
        MenuFlyoutItem(
          leading: const SRCatIcon(FluentIcons.save, size: 16, weight: FontWeight.w600),
          text: const Text("导入"),
          onPressed: () => SRCatWarpGachaLogImport.import(context)
        ),
        MenuFlyoutItem(
          leading: const SRCatIcon(FluentIcons.save_as, size: 16, weight: FontWeight.w600),
          text: const Text("导出"),
          onPressed: () => SRCatWarpGachaLogOutput.output(context, _nowSelectedUID)
        )
      ],
    );

    Widget actions = Row(
      children: <Widget>[
        refreshBtn,
        divider,
        importOrOutputButton
      ],
    );

    Widget profileSelect = ComboBox<String>(
      value: _nowSelectedUID.toString(),
      items: _warpUsers.map(
        (item) => ComboBoxItem(value: item["uid"].toString(), child: Text(item["uid"].toString()))
      ).toList(),
      onChanged: (value) async {
        if (value != null && value != _nowSelectedUID.toString()) {
          await SRCatWarpDatabaseLib.updateSelectUser(uid: int.parse(value));
          Application.router.push("/tools/warp?uid=$value");
        }
      },
    );

    Widget deleteButton = Tooltip(
      message: "删除当前记录",
      child: IconButton(
        icon: SRCatIcon(
          FluentIcons.delete,
          size: 16,
          weight: FontWeight.w600,
          color: Colors.red
        ),
        onPressed: () => {
          ref.read(globalDialogRiverpod).set("确定要删除「$_nowSelectedUID」的跃迁记录吗？",
            titleSize: 18,
            child: const Text("该操作将永久（真的很久很久）删除当前用户的存档以及跃迁记录，且将不可逆 (＃°Д°)"),
            actions: <Widget>[
              Button(child: const Text("确认删除"), onPressed: () => _deleteUserWarpLog()),
              FilledButton(child: const Text("手滑了！不删了！"), onPressed: () async {
                ref.read(globalDialogRiverpod).hidden();
                await Future.delayed(const Duration(milliseconds: 200));
                ref.read(globalDialogRiverpod).clean();
              })
            ]
          ).show()
        },
      )
    );

    Widget warpSettings = Tooltip(
      message: "设置项",
      child: dorpDownButton(
        icon: FluentIcons.settings,
        items: [
          MenuFlyoutItem(
            leading: _fullRefreshGachaLog == "false" ? const SizedBox(
              width: 12,
              height: 12,
            ) : const SRCatIcon(
              FluentIcons.accept_medium,
              size: 12,
              weight: FontWeight.w600
            ),
            text: const Text("全量刷新跃迁数据"),
            onPressed: () async {
              if (_fullRefreshGachaLog == "false") {
                await SRCatSettingsDatabaseLib.save(option: SRCatSettingsDatabaseKey.fullRefreshGachaLog, value: "true");
                _fullRefreshGachaLog = "true";
              } else if (_fullRefreshGachaLog == "true") {
                await SRCatSettingsDatabaseLib.save(option: SRCatSettingsDatabaseKey.fullRefreshGachaLog, value: "false");
                _fullRefreshGachaLog = "false";
              }

              setState(() {});
            }
          ),
          MenuFlyoutItem(
            leading: _showStarterGachaLog == "false" ? const SizedBox(
              width: 12,
              height: 12,
            ) : const SRCatIcon(
              FluentIcons.accept_medium,
              size: 12,
              weight: FontWeight.w600
            ),
            text: const Text("显示始发跃迁数据"),
            onPressed: () async {
              if (_showStarterGachaLog == "false") {
                await SRCatSettingsDatabaseLib.save(option: SRCatSettingsDatabaseKey.showStarterGachaLog, value: "true");
                _showStarterGachaLog = "true";
              } else if (_showStarterGachaLog == "true") {
                await SRCatSettingsDatabaseLib.save(option: SRCatSettingsDatabaseKey.showStarterGachaLog, value: "false");
                _showStarterGachaLog = "false";
              }

              setState(() {});
            }
          ),
        ]
      )
    );

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
            deleteButton,
            const SizedBox(width: 2),
            warpSettings
          ],
        ),
      )
    );
  }

  Widget _content() {
    // 常驻
    Widget regular = WarpRecordPanel(
      title: "群星跃迁",
      height: 240,
      data: _gachaLog[GachaWarpType.regular],
      type: GachaWarpType.regular,
      gachaPool: _gachaPool,
    );

    // 角色 UP / Character UP
    Widget characterUP = WarpRecordPanel(
      title: "角色活动",
      height: 220,
      data: _gachaLog[GachaWarpType.character],
      type: GachaWarpType.character,
      gachaPool: _gachaPool,
    );

    // 光锥 UP / Light Cone UP
    Widget lightConeUP = WarpRecordPanel(
      title: "流光定影",
      data: _gachaLog[GachaWarpType.lightCone],
      type: GachaWarpType.lightCone,
      gachaPool: _gachaPool,
    );

    // 始发跃迁 / Starter
    Widget starter = WarpRecordPanel(
      title: "始发跃迁",
      height: 200,
      disableInfoScroll: true,
      data: _gachaLog[GachaWarpType.starter],
      type: GachaWarpType.starter,
      gachaPool: _gachaPool,
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
          _showStarterGachaLog == "true" ? starter : Container()
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/srcat/pom-7.png"),
          fit: BoxFit.cover
        )
      ),
    );

    Widget divider = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 180),
      child: const Divider(direction: Axis.vertical)
    );

    List<Widget> compatible = _hasOldDatabase ? [
      const SizedBox(height: 5),
      SRCatCard(
        title: "从旧版导入数据",
        description: "检测到旧版本数据库，可以通过此方式导入数据",
        icon: fluent_system_icons.FluentIcons.arrow_import_24_regular,
        rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 18),
        onTap: () async {
          ref.read(globalDialogRiverpod).set("", child: const SizedBox(
            height: 60,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: ProgressRing(),
                ),
                SizedBox(width: 15),
                Text("正在从旧版本数据库导入跃迁数据...")
              ],
            ),
          )).show();
          await SRCatWaroDatabaseCompatibleUtils.import();
          ref.read(globalDialogRiverpod).hidden();
          await Future.delayed(const Duration(milliseconds: 300));
          ref.read(globalDialogRiverpod).clean();
          Application.router.push("/tools/warp");
        }
      )
    ] : [];

    Widget right = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text("获取跃迁数据...", style: TextStyle(
          fontSize: 20
        )),
        const SizedBox(height: 15),
        SRCatCard(
          title: "从网页缓存获取",
          description: "需要在游戏中打开一次抽卡记录页面",
          icon: FluentIcons.apps_content,
          rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 18),
          onTap: () async => _refreshGachaLog()
        ),
        ...compatible
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
      children: [_loadGachaLog ? _content() : _loadPage()]
    );

    return SRCatPageScroll(
      padding: EdgeInsets.zero,
      header: _bar(),
      child: column
    );
  }

  /// 删除用户存档和跃迁记录
  void _deleteUserWarpLog() async {
    ref.read(globalDialogRiverpod).set("操作执行中",
      titleSize: 18,
      child: Text("正在删除「$_nowSelectedUID」的存档和跃迁记录，请稍后..."),
      actions: <Widget>[
        const Button(
          onPressed: null,
          child: SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 15,
                  height: 15,
                  child: ProgressRing(strokeWidth: 2.5)
                ),
                SizedBox(width: 10),
                Text("删除中")
              ],
            )
          ),
        ),
        const FilledButton(onPressed: null, child: Text("现在手滑已经晚了..."))
      ]
    );

    Map<String, dynamic> result = await SRCatWarpDatabaseLib.deleteUserProfileAndGachaLog(uid: _nowSelectedUID);
    if (result["status"] == false) {
      ref.read(globalDialogRiverpod).set("错误",
        titleSize: 18,
        child: Text("删除存档时发生错误：${result['message']}"),
        actions: null,
        cacheActions: false
      );

      await Future.delayed(const Duration(seconds: 2));
      ref.read(globalDialogRiverpod).hidden();
      await Future.delayed(const Duration(milliseconds: 200));
      ref.read(globalDialogRiverpod).clean();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      ref.read(globalDialogRiverpod).hidden();
      await Future.delayed(const Duration(milliseconds: 200));
      ref.read(globalDialogRiverpod).clean();
      Application.router.push("/tools/warp");
    }
  }

  /// 刷新数据
  void _refreshGachaLog() async {
    Map<String, dynamic> udata = await SRCatWarpUpdateLib.init(
      GachaGetType.cache,
      fullRefreshGachaLog: _fullRefreshGachaLog == "true" ? true : false
    );
    _warpUsers = await SRCatWarpDatabaseLib.allWarpUser();
    _loadStatus = true;
    if (_warpUsers.isNotEmpty && udata["refreshUID"] != 0) {
      await Future.delayed(const Duration(seconds: 1));
      Application.router.push("/tools/warp?uid=${udata["refreshUID"]}");
    } else {
      ref.read(globalDialogRiverpod).set("提示", titleSize: 20,
        child: const Text("跃迁数据刷新失败，可能是链接已失效，请尝试进入游戏内重新获取。"),
        actions: <Widget>[
          FilledButton(child: const Text("好的"), onPressed: () async {
            ref.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            ref.read(globalDialogRiverpod).clean();
          })
        ]
      ).show();
    }
  }

  // 从用户输入的链接获取跃迁数据
  void _refreshGachaLogFromLink() async {
    _userGachaLogLink = "";

    void showErr(String? message) {
      ref.read(globalDialogRiverpod).set("出现错误", titleSize: 20,
        child: Text(message ?? ""),
        actions: <Widget>[
          FilledButton(child: const Text("重新输入链接"), onPressed: () async {
            ref.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            ref.read(globalDialogRiverpod).clean();
            await Future.delayed(const Duration(milliseconds: 10));
            _refreshGachaLogFromLink();
          })
        ]
      ).show();
    }
    
    ref.read(globalDialogRiverpod).set("输入链接",
      titleSize: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextBox(
            minLines: 1,
            maxLines: 10,
            placeholder: "请输入跃迁记录 Url",
            onChanged: (value) {
              _userGachaLogLink = value;
              setState(() {});
            }
          )
        ],
      ),
      actions: <Widget>[
        FilledButton(child: const Text("确定"), onPressed: () async {
          ref.read(globalDialogRiverpod).hidden();
          Map<String, dynamic> udata = await SRCatWarpUpdateLib.init(
            GachaGetType.url,
            userInptLink: _userGachaLogLink,
            fullRefreshGachaLog: _fullRefreshGachaLog == "true" ? true : false
          );
          if (udata["hasError"] == true) {
            showErr(udata["errorMsg"]);
          } else {
            await Future.delayed(const Duration(seconds: 1));
            Application.router.push("/tools/warp?uid=${udata["refreshUID"]}");
          }
        }),
        Button(child: const Text("取消"), onPressed: () async {
          _userGachaLogLink = "";
          ref.read(globalDialogRiverpod).hidden();
          await Future.delayed(const Duration(milliseconds: 200));
          ref.read(globalDialogRiverpod).clean();
        })
      ]
    ).show();
  }

  /// SToken 刷新数据
  /*void _refreshGachaLogBySToken() async {
    List<Map<String, dynamic>> list = ref.read(globalUserManagerRiverpod).userList;
    String nowSelect = ref.read(globalUserManagerRiverpod).nowSelectUser;
    int nowRoleUid = ref.read(globalUserManagerRiverpod).nowRoleUid;
    Map<String, dynamic> nowInfo = {};
    Map<String, dynamic> nowRoleInfo = {};

    if (list.isEmpty) {
      ref.read(globalDialogRiverpod).set("提示", titleSize: 20,
        child: const Text("请登录后再使用 SToken 刷新"),
        actions: <Widget>[
          FilledButton(child: const Text("好的"), onPressed: () async {
            ref.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            ref.read(globalDialogRiverpod).clean();
          })
        ]
      ).show();
      return;
    }

    if (nowSelect == "" || nowRoleUid == 0) {
      ref.read(globalDialogRiverpod).set("提示", titleSize: 20,
        child: const Text("请选择账号与游戏角色"),
        actions: <Widget>[
          FilledButton(child: const Text("好的"), onPressed: () async {
            ref.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            ref.read(globalDialogRiverpod).clean();
          })
        ]
      ).show();
      return;
    }

    for (Map<String, dynamic> user in list) {
      if (user["id"] == nowSelect) {
        nowInfo = user;
        break;
      }
    }

    for (Map<String, dynamic> role in nowInfo["role"]) {
      if (role["game_uid"] != null && int.parse(role["game_uid"].toString()) == nowRoleUid) {
        nowRoleInfo = role;
        break;
      }
    }

    if (nowInfo.isEmpty) {
      ref.read(globalDialogRiverpod).set("提示", titleSize: 20,
        child: const Text("账号/角色信息不存在，请重新选择"),
        actions: <Widget>[
          FilledButton(child: const Text("好的"), onPressed: () async {
            ref.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            ref.read(globalDialogRiverpod).clean();
          })
        ]
      ).show();
      return;
    }

    //ref.read(globalDialogRiverpod).set("提示", titleSize: 20,
    //  child: const Text("获取数据中..."),
    //  actions: null,
    //  cacheActions: false
    //).show();
    
    Map<String, String>? authKey = await HoYoLabAuthKeyLib.generateAuthKey(
      stoken: nowInfo["stoken"],
      mid: nowInfo["mid"],
      uid: nowInfo["uid"],
      deviceId: nowInfo["id"],
      gameUid: nowRoleUid
    );
    //print(authKey.toString().replaceAll("+", "%2B").replaceAll("/", "%2F").replaceAll("=", "%3D"));
    
    /*if (authKey == null) {
      ref.read(globalDialogRiverpod).set("错误", titleSize: 20,
        child: const Text("authKey 获取失败，可能是 SToken 失效，请尝试重新登录。"),
        actions: <Widget>[
          FilledButton(child: const Text("好的"), onPressed: () async {
            ref.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            ref.read(globalDialogRiverpod).clean();
          })
        ]
      ).show();
      return;
    }

    int uid = await SRCatWarpUpdateLib.init(GachaGetType.stoken, stokenData: {
      ...authKey,
      "timestamp": SRCatUtils.getUnixTime(),
      "region": nowRoleInfo["region"],
      "game_biz": nowRoleInfo["game_biz"],
      "os_system": "Windows",
      "device_model": "BakaSRCat"
    });
    _warpUsers = await SRCatWarpDatabaseLib.allWarpUser();
    _loadStatus = true;
    if (_warpUsers.isNotEmpty && uid != 0) {
      await Future.delayed(const Duration(seconds: 1));
      Application.router.push("/tools/warp?uid=$uid");
    } else {
      ref.read(globalDialogRiverpod).set("提示", titleSize: 20,
        child: const Text("跃迁数据刷新失败，可能是 SToken 失效，请尝试重新登录。"),
        actions: <Widget>[
          FilledButton(child: const Text("好的"), onPressed: () async {
            ref.read(globalDialogRiverpod).hidden();
            await Future.delayed(const Duration(milliseconds: 200));
            ref.read(globalDialogRiverpod).clean();
          })
        ]
      ).show();
    }*/
  }*/
}
