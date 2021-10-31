import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/littlelight_api/littlelight_api.provider.dart';

mixin LittleLightApiConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  LittleLightApi get littleLightApi => ref.read(littleLightApiProvider);
}

mixin LittleLightApiConsumerWidget on ConsumerWidget {
  LittleLightApi itemNotes(WidgetRef ref) => ref.read(littleLightApiProvider);
}
