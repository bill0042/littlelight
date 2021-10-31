import 'package:bungie_api/models/destiny_item_component.dart';

import 'transfer_destination.dart';

enum TransferErrorCode {
  cantFindSubstitute,
  cantPullFromPostmaster,
  cantMoveToVault,
  cantMoveToCharacter,
  cantEquip,
  cantUnequip
}

class TransferError {
  final TransferErrorCode code;
  final DestinyItemComponent item;
  final ItemDestination destination;
  final String characterId;

  TransferError(this.code, [this.item, this.destination, this.characterId]);
}
