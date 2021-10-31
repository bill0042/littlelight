import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/inventory/inventory.consumer.dart';
import 'package:little_light/core/providers/inventory/transfer_destination.dart';
import 'package:little_light/core/providers/user_settings/user_settings.provider.dart';
import 'package:little_light/core/providers/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:little_light/widgets/common/equip_on_character.button.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ManagementBlockWidget extends BaseDestinyStatelessItemWidget
    with InventoryConsumerWidget {
  ManagementBlockWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item == null) {
      return Container();
    }
    return Container(
        child: Wrap(
      direction: Axis.horizontal,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            transferDestinations(ref).length > 0
                ? Expanded(
                    flex: 3,
                    child: buildEquippingBlock(context, ref,
                        title: "Transfer",
                        destinations: transferDestinations(ref),
                        align: Alignment.centerLeft))
                : null,
            pullDestinations.length > 0
                ? buildEquippingBlock(
                    context,
                    ref,
                    title: "Pull",
                    destinations: pullDestinations,
                  )
                : null
          ].where((value) => value != null).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            unequipDestinations.length > 0
                ? buildEquippingBlock(
                    context,
                    ref,
                    title: "Unequip",
                    destinations: unequipDestinations,
                    align: Alignment.centerLeft,
                  )
                : null,
            equipDestinations(ref).length > 0
                ? Expanded(
                    child: buildEquippingBlock(context, ref,
                        title: "Equip",
                        destinations: equipDestinations(ref),
                        align: unequipDestinations.length > 0
                            ? Alignment.centerRight
                            : Alignment.centerLeft))
                : null
          ].where((value) => value != null).toList(),
        ),
      ],
    ));
  }

  Widget buildEquippingBlock(
    BuildContext context,
    WidgetRef ref, {
    String title,
    List<TransferDestination> destinations,
    Alignment align = Alignment.centerRight,
  }) {
    return Column(
        crossAxisAlignment: align == Alignment.centerRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          buildLabel(context, title, align),
          buttons(context, ref, destinations: destinations, align: align)
        ]);
  }

  Widget buildLabel(BuildContext context, String title,
      [Alignment align = Alignment.centerRight]) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: HeaderWidget(
          child: Container(
              alignment: align,
              child: TranslatedTextWidget(
                title,
                uppercase: true,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ));
  }

  Widget buttons(
    BuildContext context,
    WidgetRef ref, {
    List<TransferDestination> destinations,
    Alignment align = Alignment.centerRight,
  }) {
    return Container(
        alignment: align,
        padding: EdgeInsets.all(8),
        child: Wrap(
            spacing: 8,
            children: destinations
                .map((destination) => EquipOnCharacterButton(
                    characterId: destination.characterId,
                    type: destination.type,
                    onTap: () {
                      transferTap(context, ref, destination: destination);
                    }))
                .toList()));
  }

  transferTap(
    BuildContext context,
    WidgetRef ref, {
    TransferDestination destination,
  }) async {
    switch (destination.action) {
      case InventoryAction.Equip:
        {
          inventory(ref).equip(item, characterId, destination.characterId);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Unequip:
        {
          inventory(ref).unequip(item, characterId);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Transfer:
        {
          inventory(ref).transfer(
              item, characterId, destination.type, destination.characterId);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Pull:
        {
          inventory(ref).transfer(
              item, characterId, destination.type, destination.characterId);
          Navigator.pop(context);
          break;
        }
    }
  }

  List<TransferDestination> equipDestinations(WidgetRef ref) {
    if (!definition.equippable) {
      return [];
    }
    return this
        .profile
        .getCharacters(ref.read(userSettingsProvider).characterOrdering)
        .where((char) =>
            !((instanceInfo?.isEquipped ?? false) &&
                char.characterId == characterId) &&
            !(definition.nonTransferrable && char.characterId != characterId) &&
            [DestinyClass.Unknown, char.classType]
                .contains(definition.classType))
        .map((char) => TransferDestination(ItemDestination.Character,
            characterId: char.characterId, action: InventoryAction.Equip))
        .toList();
  }

  List<TransferDestination> transferDestinations(WidgetRef ref) {
    if (definition.nonTransferrable) {
      return [];
    }

    if (ProfileService.profileBuckets
        .contains(definition.inventory.bucketTypeHash)) {
      if (item.bucketHash == InventoryBucket.general) {
        return [TransferDestination(ItemDestination.Inventory)];
      }
      return [TransferDestination(ItemDestination.Vault)];
    }

    List<TransferDestination> list = this
        .profile
        .getCharacters(ref.read(userSettingsProvider).characterOrdering)
        .where((char) => !(char.characterId == characterId))
        .map((char) => TransferDestination(ItemDestination.Character,
            characterId: char.characterId))
        .toList();

    if (item.bucketHash != InventoryBucket.general) {
      list.add(TransferDestination(ItemDestination.Vault));
    }
    return list;
  }

  List<TransferDestination> get pullDestinations {
    if (item.bucketHash == InventoryBucket.lostItems &&
        !definition.doesPostmasterPullHaveSideEffects) {
      ItemDestination type;
      if (ProfileService.profileBuckets
          .contains(definition.inventory.bucketTypeHash)) {
        type = ItemDestination.Inventory;
      } else {
        type = ItemDestination.Character;
      }
      return [
        TransferDestination(type,
            characterId: characterId, action: InventoryAction.Pull)
      ];
    }
    return [];
  }

  List<TransferDestination> get unequipDestinations {
    if (!definition.equippable) {
      return [];
    }
    bool isEquipped = instanceInfo?.isEquipped ?? false;
    if (isEquipped) {
      return [
        TransferDestination(ItemDestination.Character,
            characterId: characterId, action: InventoryAction.Unequip)
      ];
    }
    return [];
  }
}
