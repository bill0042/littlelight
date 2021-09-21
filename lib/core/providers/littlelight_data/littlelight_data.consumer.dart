import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'littlelight_data.provider.dart';

mixin LittleLightDataConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  LittleLightData get littlelightData => ref.read(littleLightDataProvider);
}
