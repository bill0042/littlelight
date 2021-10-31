import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/notification/notifications.provider.dart';

mixin NotificationsConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  NotificationsManager get notifications => ref.read(notificationsProvider);
}

mixin NotificationsConsumerWidget on ConsumerWidget {
  NotificationsManager notifications(WidgetRef ref) => ref.read(notificationsProvider);
}
