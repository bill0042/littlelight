import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/user_settings/user_settings.provider.dart';

mixin UserSettingsConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  UserSettingsService get userSettings => ref.read(userSettingsProvider);
}

mixin UserSettingsConsumerWidget on ConsumerWidget {
  UserSettingsService userSettings(WidgetRef ref) =>
      ref.read(userSettingsProvider);
}
