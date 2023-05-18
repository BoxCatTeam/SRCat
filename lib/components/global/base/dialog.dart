/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 03:09:27
/// LastEditTime: 2023-05-18 08:10:13
/// FilePath: /lib/components/global/base/dialog.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/riverpod/global/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局弹窗组件
class SRCatGlobalDialog extends ConsumerStatefulWidget {
  const SRCatGlobalDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<SRCatGlobalDialog> createState() => _SRCatGlobalDialogState();
}

class _SRCatGlobalDialogState extends ConsumerState<SRCatGlobalDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(_controller);
  }
  
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
    double titleSize = ref.watch(globalDialogRiverpod).titleSize;
    Widget? child = ref.watch(globalDialogRiverpod).child;
    List<Widget>? actions = ref.watch(globalDialogRiverpod).actions;

    if (isShow) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    Widget dialog = ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      title: title == "" ? null : Text(title, style: TextStyle(fontSize: titleSize)),
      content: child,
      actions: actions
    );
    
    Widget stack = Stack(
      children: <Widget>[
        _background(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(child: ScaleTransition(
            scale: _animation,
            child: dialog
          )),
        )
      ],
    );

    Widget opacity = AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: isShow ? 1 : 0,
      child: stack,
    );

    return IgnorePointer(
      ignoring: isShow ? false : true,
      child: opacity,
    );
  }
}
