import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/global_container/global.container.dart';
import 'package:little_light/core/providers/notification/events/notification.event.dart';

final notificationsProvider = Provider<NotificationsManager>((ref) => NotificationsManager._());

get globalNotificationsProvider => globalContainer.read(notificationsProvider);

class NotificationsManager {
  Stream<NotificationEvent> _eventsStream;
  final StreamController<NotificationEvent> _streamController =
      StreamController.broadcast();

  NotificationsManager._();

  NotificationEvent latestNotification;

  Stream<NotificationEvent> get _broadcaster {
    if (_eventsStream != null) {
      return _eventsStream;
    }
    _eventsStream = _streamController.stream;
    return _eventsStream;
  }

  StreamSubscription<NotificationEvent> listen(
      void onData(NotificationEvent event),
      {Function onError,
      void onDone(),
      bool cancelOnError}) {
    return _broadcaster.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  push(NotificationEvent notification) {
    _streamController.add(notification);
    latestNotification = notification;
  }
}
