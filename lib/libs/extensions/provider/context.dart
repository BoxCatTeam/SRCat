/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 10:15:24
/// LastEditTime: 2023-05-09 10:15:33
/// FilePath: /lib/libs/extensions/provider/context.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension Context on BuildContext {
  // Custom call a provider for reading method only
  // It will be helpful for us for calling the read function
  // without Consumer,ConsumerWidget or ConsumerStatefulWidget
  // Incase if you face any issue using this then please wrap your widget
  // with consumer and then call your provider

  T read<T>(ProviderBase<T> provider) {
     return ProviderScope.containerOf(this, listen: false).read(provider);
  }
}
