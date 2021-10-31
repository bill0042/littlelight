import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:little_light/core/providers/inventory/transfer_error.dart';
import 'package:little_light/core/providers/notification/events/notification.event.dart';

class TransferErrorEvent extends NotificationEvent {
  final TransferErrorCode code;
  TransferErrorEvent(NotificationType type,
      {DestinyItemComponent item, String characterId, this.code})
      : super(type, item: item, characterId: characterId);
}