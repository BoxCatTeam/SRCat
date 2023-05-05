/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-05 08:39:39
/// LastEditTime: 2023-05-05 22:44:36
/// FilePath: /lib/components/global/dialog/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/riverpod/global/dialog.dart';

class SCGlobalDialog extends ConsumerStatefulWidget {
  const SCGlobalDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<SCGlobalDialog> createState() => _SCGlobalDialogState();
}

class _SCGlobalDialogState extends ConsumerState<SCGlobalDialog> {
  /// 半透明背景
  Widget _background() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.3)
    );
  }
  
  @override
  Widget build(BuildContext context) {
    bool isShow = ref.watch(globalDialogRiverpod).isShow;
    String title = ref.watch(globalDialogRiverpod).title;
    Widget? child = ref.watch(globalDialogRiverpod).child;

    Widget dialog = ContentDialog(
      title: Text(title),
      content: child,
    );
    
    Widget stack = Stack(
      children: <Widget>[
        _background(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(child: dialog),
        )
      ],
    );

    Widget opacity = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isShow ? 1 : 0,
      child: stack,
    );

    return IgnorePointer(
      ignoring: isShow ? false : true,
      child: opacity,
    );
  }
}
