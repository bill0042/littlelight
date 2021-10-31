import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api.provider.dart';

mixin BungieApiConsumer<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  BungieApi get bungieApi => ref.read(bungieApiProvider);
}
