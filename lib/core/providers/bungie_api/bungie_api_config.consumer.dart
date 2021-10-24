import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bungie_api_config.provider.dart';

mixin BungieApiConfigConsumer {
  BungieApiConfig apiConfig(WidgetRef ref) => ref.read(bungieApiConfigProvider);
}

mixin BungieApiConfigConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  BungieApiConfig get apiConfig => ref.read(bungieApiConfigProvider);
}
