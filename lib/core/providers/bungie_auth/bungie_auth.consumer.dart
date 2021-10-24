import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bungie_auth.provider.dart';

mixin BungieAuthConsumer {
  BungieAuth auth(WidgetRef ref) => ref.read(bungieAuthProvider);
}

mixin BungieAuthConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  BungieAuth get auth => ref.read(bungieAuthProvider);
}
