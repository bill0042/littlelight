
import 'package:bungie_api/models/destiny_item_component.dart';

enum NotificationType {
  localUpdate,
  requestedTransfer,
  requestedVaulting,
  requestedEquip,
  requestedUpdate,
  receivedUpdate,
  itemStateUpdate,
  transferError,
  equipError,
  updateError
}

class NotificationEvent {
  final NotificationType type;
  final DestinyItemComponent item;
  final String characterId;
  NotificationEvent(this.type, {this.item, this.characterId});
}