/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 02:52:09
/// LastEditTime: 2023-05-16 03:42:52
/// FilePath: /lib/utils/game/launch.dart
/// ===========================================================================

import 'dart:io';
import 'package:srcat/utils/storage/main.dart';

typedef GetPID = Function(int pid);
typedef GetExitCode = Function(Future<int> exitCode);

class SRCatGameLaunch {
  /// 启动游戏
  static Future<void> start({
    required GetPID pid,
    required GetExitCode exitCode,
    bool enablePopupWindow = false
  }) async {
    List<String> arguments = [];

    if (enablePopupWindow) {
      arguments.add("-popupwindow");
    }

    final process = await Process.start(
      (await SRCatStorageUtils.read("hsr_path")) as String,
      arguments,
      runInShell: true,
    );
    
    /// 传出进程 PID
    pid(process.pid);
    /// 传出退出进程 PID
    exitCode(process.exitCode);
  }
}
