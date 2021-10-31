import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'destiny_settings.provider.dart';

mixin DestinySettingsConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  DestinySettings get destinySettings => ref.read(destinySettingsProvider);
}

mixin DestinySettingsConsumerWidget on ConsumerWidget {
  DestinySettings destinySettings(WidgetRef ref) => ref.read(destinySettingsProvider);
}
