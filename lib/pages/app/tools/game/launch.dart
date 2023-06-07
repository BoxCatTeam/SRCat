/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 02:33:24
/// LastEditTime: 2023-06-07 22:10:18
/// FilePath: /lib/pages/app/tools/game/launch.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import 'package:srcat/riverpod/global/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/riverpod/pages/tools/game/launch.dart';

import 'package:srcat/utils/game/launch.dart';
import 'package:srcat/utils/game/registry.dart';

import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/icon/main.dart';
import 'package:srcat/components/global/scroll/normal.dart';
import 'package:srcat/components/pages/app/tools/game/launch/accounts_selector.dart';

import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fluent_system_icons;
import 'package:srcat/utils/main.dart';
import 'package:srcat/utils/storage/main.dart';
import 'package:srcat/libs/srcat/game/accounts.dart';
import 'package:window_manager/window_manager.dart';

/// Game Launch Page
class GameLaunchToolPage extends ConsumerStatefulWidget {
  const GameLaunchToolPage({Key? key}) : super(key: key);

  @override
  ConsumerState<GameLaunchToolPage> createState() => _GameLaunchToolPageState();
}

class _GameLaunchToolPageState extends ConsumerState<GameLaunchToolPage> {
  bool _canStart = true;
  int? _selectedIndex;
  bool _hasAccounts = false;
  List<Map<String, dynamic>> _accountsList = [];
  final _stateKey = GlobalKey<NavigatorState>();

  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    try {
      _initSetting();
    } catch (e) {
      if (kDebugMode) print("游戏启动器初始化设置发生错误：$e");
    }

    SRCatGameAccountsLib.getAll().then((List<Map<String, dynamic>> value) async {
      if (value.isEmpty) {
        _hasAccounts = false;
      } else {
        _accountsList = value;
        _hasAccounts = true;
      }

      _loaded = true;
      setState(() {});
    });

    if (ref.read(gameLaunchPageRiverpod).processId != null) {
      _canStart = false;
    } else {
      _canStart = true;
    }
  }

  void _initSetting() {
    if (SRCatStorageUtils.read("hsr_game_popupwindow") == null) {
      SRCatStorageUtils.write("hsr_game_popupwindow", false);
    }

    if (SRCatStorageUtils.read("hsr_game_fps_unlocked") == null) {
      SRCatStorageUtils.write("hsr_game_fps_unlocked", false);
    }

    if (SRCatStorageUtils.read("hsr_game_fps") == null) {
      SRCatStorageUtils.write("hsr_game_fps", 60);
    }

    if (SRCatStorageUtils.read("hsr_game_fullscreen") == null) {
      SRCatStorageUtils.write("hsr_game_fullscreen", true);
    }

    List<int>? windowSize = SRCatGameRegistry.getWindowSize();

    if (SRCatStorageUtils.read("hsr_game_width") == null) {
      SRCatStorageUtils.write("hsr_game_width", (windowSize != null && windowSize[0] != 0 ? windowSize[0] : 1920));
    }

    if (SRCatStorageUtils.read("hsr_game_height") == null) {
      SRCatStorageUtils.write("hsr_game_height", (windowSize != null && windowSize[1] != 0 ? windowSize[1] : 1080));
    }
  }

  Widget _startGame() {
    return SRCatCard(
      title: "启动游戏",
      description: "根据您下方的设置进行游戏",
      iconWeight: FontWeight.w500,
      icon: fluent_system_icons.FluentIcons.games_24_regular,
      rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 12),
      onTap: _canStart ? () async {
        bool fpsResult = false;
        String errText = "";
        if (SRCatStorageUtils.read("hsr_game_fps_unlocked") != null && SRCatStorageUtils.read("hsr_game_fps_unlocked") == true) {
          fpsResult = SRCatGameRegistry.setFPS(SRCatStorageUtils.read("hsr_game_fps") as int);
        } else {
          fpsResult = SRCatGameRegistry.setFPS(60);
        }

        if (fpsResult == false && (SRCatStorageUtils.read("hsr_game_fps_unlocked") != null && SRCatStorageUtils.read("hsr_game_fps_unlocked") == true)) {
          errText += "设置帧率失败，请在游戏内修改图形设置后再试";
        }

        bool setWindow = SRCatGameRegistry.setWindow(
          isFullScreen: SRCatStorageUtils.read("hsr_game_fullscreen") != null && SRCatStorageUtils.read("hsr_game_fullscreen") is bool ?
            SRCatStorageUtils.read("hsr_game_fullscreen")
            : null,
          width: SRCatStorageUtils.read("hsr_game_width") != null && SRCatStorageUtils.read("hsr_game_width") is int ?
            SRCatStorageUtils.read("hsr_game_width")
            : null,
          height: SRCatStorageUtils.read("hsr_game_height") != null && SRCatStorageUtils.read("hsr_game_height") is int ?
            SRCatStorageUtils.read("hsr_game_height")
            : null,
        );

        if (setWindow == false && (SRCatStorageUtils.read("hsr_game_fullscreen") != null && SRCatStorageUtils.read("hsr_game_fullscreen") == true)) {
          errText += "${(errText != "") ? "\n" : ""}设置游戏外观失败，请在游戏内修改图形设置后再试";
        }

        if (errText != "") {
           _displayBar(title: "提示", text: errText, severity: InfoBarSeverity.warning);
        }

        /// 替换注册表账号信息
        if (_selectedIndex != null) {
          SRCatGameRegistry.write(_accountsList[_selectedIndex!]["sdkey"]);
          await Future.delayed(const Duration(milliseconds: 50));
        }

        SRCatGameLaunch.start(
          enablePopupWindow: SRCatStorageUtils.read("hsr_game_popupwindow") != null
            && SRCatStorageUtils.read("hsr_game_popupwindow") is bool
            && SRCatStorageUtils.read("hsr_game_popupwindow") == true
            ? true : false,
          pid: (pid) {
            if (pid != 0) {
              ref.read(gameLaunchPageRiverpod).setProcessId(pid);
              _canStart = false;
              setState(() {});
            }
          },
          exitCode: (exitCode) async {
            int code = await exitCode;
            if (code == 1) {
              ref.read(globalDialogRiverpod).set("提示",
                titleSize: 20,
                child: const Text("启动游戏需要管理员权限，请允许来自 Star Rail 的管理员权限申请。"),
                actions: <Widget>[
                  const Button(onPressed: null, child: Text("这里不可以点")),
                  FilledButton(onPressed: () async {
                    ref.read(globalDialogRiverpod).hidden();
                    await Future.delayed(const Duration(milliseconds: 200));
                    ref.read(globalDialogRiverpod).clean();
                  }, child: const Text("好的")),
                ]
              ).show();
            }
            _canStart = true;
            ref.read(gameLaunchPageRiverpod).setProcessId(null);
            setState(() {});
            await windowManager.show();
            await windowManager.focus();
          }
        );
      } : null,
    );
  }

  Widget _accounts() {
    
    
    Widget checkAccount = SRCatCard(
      title: "账号检测",
      description: "在游戏内切换账号或网络发生变化时，需重新手动检测账号",
      iconWeight: FontWeight.w500,
      icon: FluentIcons.switch_user,
      margin: EdgeInsets.only(bottom: _hasAccounts ? 3 : 0),
      rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 12),
      onTap: () async {
        /// 从注册表中拿取 SDK Key
        String? key = await SRCatGameRegistry.read();

        /// 判断是否为空
        if (key != null) {
          /// 将 Key 转换为 UUID
          String keyUuid = SRCatUtils.getUUIDv5(key);
          /// 账号是否已在数据库内
          bool hasAccount = false;

          if (_accountsList.isNotEmpty) {
            for (var index = 0; index < _accountsList.length; index++) {
              if (_accountsList[index]["id"] == keyUuid) {
                _selectedIndex = index;
                hasAccount = true;
                break;
              }
            }
          }

          if (!hasAccount) {
            /// 不存在则往数据库内添加
            ref.read(globalDialogRiverpod).set("添加账号", titleSize: 20,
              child: TextBox(
                placeholder: "为新的账号设置一个名称",
                onChanged: (value) {
                  ref.read(gameLaunchPageRiverpod).setNewAccNickname(value);
                }
              ),
              actions: <Widget>[
                FilledButton(onPressed: () => _saveNewAcc(key), child: const Text("保存")),
                Button(onPressed: () async {
                  ref.read(globalDialogRiverpod).hidden();
                  await Future.delayed(const Duration(milliseconds: 300));
                  ref.read(globalDialogRiverpod).clean();
                }, child: const Text("取消"))
              ]
            ).show();
          } else {
            //_displayBar(title: "提示", text: "账号已存在", severity: InfoBarSeverity.warning);
            setState(() {});
          }
        }
      },
    );

    Widget selector = GameLaunchAccountsSelector(
      selectedIndex: _selectedIndex,
      onChanged: (value) {
        _selectedIndex = value;
        setState(() {});
      },
      deleteAction: (index) async {
        await SRCatGameAccountsLib.delete(uuid: _accountsList[index]["id"]);
        _accountsList = await SRCatGameAccountsLib.getAll();
        if (_selectedIndex != null) {
          if (index > _selectedIndex!) {
            _selectedIndex = (index - 1 >= 0) ? index - 1 : 0;
          } else if (index < _selectedIndex!) {
            _selectedIndex = _selectedIndex;
          } else if (index == _selectedIndex!) {
            _selectedIndex = null ;
          }
        }
        if (_accountsList.isEmpty) {
          _hasAccounts = false;
        }
        setState(() {});
      },
      renameAction: (index) {
        ref.read(globalDialogRiverpod).set("重命名账号",
          child: TextBox(
            placeholder: "重新为当前账号命名",
            onChanged: (value) {
              ref.read(gameLaunchPageRiverpod).setAccNewNickname(value);
            }
          ),
          actions: <Widget>[
            FilledButton(onPressed: () => _reNewNickname(_accountsList[index]["id"]), child: const Text("保存")),
            Button(onPressed: () async {
              ref.read(gameLaunchPageRiverpod).setAccNewNickname(null);
              ref.read(globalDialogRiverpod).hidden();
              await Future.delayed(const Duration(milliseconds: 300));
              ref.read(globalDialogRiverpod).clean();
            }, child: const Text("取消"))
          ]
        ).show();
      },
      items: _accountsList.map((value) => GameLaunchAccountsSelectorItem(
        uid: int.parse((value["uid"] ?? 0).toString()),
        uuid: value["id"],
        nickname: value["name"],
        sdkey: value["sdkey"],
      )).toList(),
    );

    return Column(
      children: <Widget>[checkAccount, _hasAccounts ? selector : Container()],
    );
  }

  Widget _fpsBox() {
    Widget infoBar = const InfoBar(
      title: Text("如果在游戏内点开设置将会使帧率设置降回 60FPS")
    );

    Widget card = SRCatCard(
      title: "帧率解锁",
      description: "直接修改注册表中的帧率设置，以此突破 60 帧限制（需要关闭垂直同步）",
      icon: FluentIcons.unlock,
      rightChild: Row(
        children: <Widget>[
          SizedBox(
            width: 140,
            child: NumberBox(
              min: 30,
              max: 1024,
              clearButton: false,
              value: int.parse((SRCatStorageUtils.read("hsr_game_fps") is int ? SRCatStorageUtils.read("hsr_game_fps") : 60).toString()),
              mode: SpinButtonPlacementMode.none,
              onChanged: (SRCatStorageUtils.read("hsr_game_fps_unlocked") == true) ? (int? value) {
                if (value != null && value <= 0) {
                  SRCatStorageUtils.write("hsr_game_fps", 60);
                } else if (value != null) {
                  SRCatStorageUtils.write("hsr_game_fps", value.toInt());
                } else {
                  SRCatStorageUtils.write("hsr_game_fps", 60);
                }
                setState(() {});
              } : null
            )
          ),
          const SizedBox(width: 20),
          ToggleSwitch(
            checked: SRCatStorageUtils.read("hsr_game_fps_unlocked") ?? false,
            onChanged: (value) async {
              await SRCatStorageUtils.write("hsr_game_fps_unlocked", value);
              setState(() {});
            }
          )
        ]
      )
    );

    return Column(
      key: _stateKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: double.infinity, child: infoBar),
        const SizedBox(height: 5),
        card
      ],
    );
  }

  Widget _windowBox() {
    Widget infoBar = const InfoBar(
      title: Text("目前仅游戏内包含的分辨率才会生效")
    );
    
    Widget fullScreen = SRCatCard(
      title: "全屏",
      icon: FluentIcons.full_screen,
      description: "以全屏方式运行游戏",
      margin: const EdgeInsets.only(bottom: 3),
      rightChild: ToggleSwitch(
        checked: SRCatStorageUtils.read("hsr_game_fullscreen") ?? true,
        onChanged: (value) async {
          await SRCatStorageUtils.write("hsr_game_fullscreen", value);
          setState(() {});
        }
      )
    );

    Widget popupWindow = SRCatCard(
      title: "无边框",
      icon: fluent_system_icons.FluentIcons.window_48_regular,
      description: "以无边框模式启动，不带框架",
      margin: const EdgeInsets.only(bottom: 3),
      rightChild: ToggleSwitch(
        checked: SRCatStorageUtils.read("hsr_game_popupwindow") ?? true,
        onChanged: (value) async {
          await SRCatStorageUtils.write("hsr_game_popupwindow", value);
          setState(() {});
        }
      )
    );

    Widget width = SRCatCard(
      title: "宽度",
      description: "自定义游戏窗口的宽度",
      icon: fluent_system_icons.FluentIcons.arrow_autofit_width_20_regular,
      margin: const EdgeInsets.only(bottom: 3),
      rightChild: SizedBox(
        width: 140,
        child: NumberBox(
          value: int.parse(SRCatStorageUtils.read("hsr_game_width").toString()),
          mode: SpinButtonPlacementMode.none,
          onChanged: (value) {
            if (value != null && value <= 0) {
              SRCatStorageUtils.write("hsr_game_width", 1920);
            } else if (value != null) {
              SRCatStorageUtils.write("hsr_game_width", value);
            } else {
              SRCatStorageUtils.write("hsr_game_width", 1920);
            }
            setState(() {});
          }
        )
      )
    );

    Widget height = SRCatCard(
      title: "高度",
      description: "自定义游戏窗口的高度",
      icon: fluent_system_icons.FluentIcons.arrow_autofit_height_20_regular,
      rightChild: SizedBox(
        width: 140,
        child: NumberBox(
          value: int.parse(SRCatStorageUtils.read("hsr_game_height").toString()),
          mode: SpinButtonPlacementMode.none,
          onChanged: (value) {
            if (value != null && value <= 0) {
              SRCatStorageUtils.write("hsr_game_height", 1080);
            } else if (value != null) {
              SRCatStorageUtils.write("hsr_game_height", value);
            } else {
              SRCatStorageUtils.write("hsr_game_height", 1080);
            }
            setState(() {});
          }
        )
      )
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: double.infinity, child: infoBar),
        const SizedBox(height: 5),
        fullScreen, popupWindow, width, height
      ],
    );
  }

  Widget _loadBox() {
    return const Center(
      child: ProgressRing(strokeWidth: 5)
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loaded ? SRCatNormalScroll(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _startGame(),
            const SizedBox(height: 15),
            _accounts(),
            const SizedBox(height: 15),
            _fpsBox(),
            const SizedBox(height: 15),
            _windowBox(),
            const SizedBox(height: 10),
          ]
        )
      )
    ) : _loadBox();
  }

  void _displayBar({
    required String title,
    required String text,
    InfoBarSeverity severity = InfoBarSeverity.error
  }) {
    displayInfoBar(_stateKey.currentContext!, builder: (context, close) {
      return InfoBar(
        title: Text(title),
        content: Text(text),
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close
        ),
        severity: severity,
      );
    });
  }

  void _saveNewAcc(String key) async {
    String? newAccNickname = ref.watch(gameLaunchPageRiverpod).newAccNickname;

    if (newAccNickname != null && newAccNickname != "") {
      await SRCatGameAccountsLib.insert(sdkey: key, nickname: newAccNickname);
      _displayBar(title: "好耶", text: "账号添加成功", severity: InfoBarSeverity.success);
      _accountsList = await SRCatGameAccountsLib.getAll();
      _hasAccounts = true;
      setState(() {});

      ref.read(globalDialogRiverpod).hidden();
      ref.read(gameLaunchPageRiverpod).setNewAccNickname(null);
      await Future.delayed(const Duration(milliseconds: 200));
      ref.read(globalDialogRiverpod).clean();
    } else {
      _displayBar(title: "错误", text: "名称不能为空");
    }
  }

  void _reNewNickname(String uuid) async {
    String? reAccNickname = ref.read(gameLaunchPageRiverpod).reAccNickname;

    if (reAccNickname != null && reAccNickname != "") {
      await SRCatGameAccountsLib.update(uuid: uuid, nickname: reAccNickname);
      _displayBar(title: "成功", text: "账号名称已修改", severity: InfoBarSeverity.success);
      _accountsList = await SRCatGameAccountsLib.getAll();
      setState(() {});

      ref.read(globalDialogRiverpod).hidden();
      ref.read(gameLaunchPageRiverpod).setAccNewNickname(null);
      await Future.delayed(const Duration(milliseconds: 200));
      ref.read(globalDialogRiverpod).clean();
    } else {
      _displayBar(title: "提示", text: "新名称不能为空");
    }
  }
}
