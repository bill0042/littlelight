import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/inventory/inventory.consumer.dart';
import 'package:little_light/core/providers/inventory/transfer_destination.dart';
import 'package:little_light/core/providers/user_settings/user_settings.consumer.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/core/providers/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/equip_on_character.button.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/option_sheets/free_slots_slider.widget.dart';

class LoadoutDestinationsWidget extends ConsumerStatefulWidget {
  final Loadout loadout;
  LoadoutDestinationsWidget(this.loadout, {Key key}) : super(key: key);

  @override
  createState() {
    return LoadoutDestinationsWidgetState();
  }
}

class LoadoutDestinationsWidgetState
    extends ConsumerState<LoadoutDestinationsWidget>
    with
        UserSettingsConsumerState,
        InventoryConsumerState,
        ProfileConsumerState {
  int freeSlots = 0;

  @override
  void initState() {
    super.initState();

    freeSlots = userSettings.defaultFreeSlots;
  }

  @override
  Widget build(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Container(
        color: Colors.blueGrey.shade800,
        padding: EdgeInsets.only(
            left: max(screenPadding.left, 4),
            right: max(screenPadding.right, 4)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FreeSlotsSliderWidget(
            initialValue: freeSlots,
            onChanged: (free) {
              freeSlots = free;
            },
          ),
          Wrap(
            direction: Axis.horizontal,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    transferDestinations.length > 0
                        ? Expanded(
                            flex: 3,
                            child: buildEquippingBlock(context, "Transfer to:",
                                transferDestinations, Alignment.centerLeft))
                        : null,
                  ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: buildEquippingBlock(context, "Equip on:",
                          equipDestinations, Alignment.centerRight))
                ].toList(),
              ),
            ],
          )
        ]));
  }

  Widget buildEquippingBlock(BuildContext context, String title,
      List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
    return Column(
        crossAxisAlignment: align == Alignment.centerRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          buildLabel(context, title, align),
          buttons(context, destinations, align)
        ]);
  }

  Widget buildLabel(BuildContext context, String title,
      [Alignment align = Alignment.centerRight]) {
    return Container(
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

  Widget buttons(BuildContext context, List<TransferDestination> destinations,
      [Alignment align = Alignment.centerRight]) {
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
                      transferTap(destination, context);
                    }))
                .toList()));
  }

  transferTap(TransferDestination destination, BuildContext context) async {
    switch (destination.action) {
      case InventoryAction.Equip:
        {
          inventory.transferLoadout(widget.loadout, destination.characterId,
              true, destination?.characterId != null ? freeSlots : 0);
          Navigator.pop(context);
          break;
        }
      case InventoryAction.Transfer:
        {
          inventory.transferLoadout(widget.loadout, destination.characterId,
              false, destination?.characterId != null ? freeSlots : 0);
          Navigator.pop(context);
          break;
        }

      default:
        break;
    }
  }

  List<TransferDestination> get equipDestinations {
    return profile
        .getCharacters(userSettings.characterOrdering)
        .map((char) => TransferDestination(ItemDestination.Character,
            characterId: char.characterId, action: InventoryAction.Equip))
        .toList();
  }

  List<TransferDestination> get transferDestinations {
    List<TransferDestination> list = profile
        .getCharacters(userSettings.characterOrdering)
        .map((char) => TransferDestination(ItemDestination.Character,
            characterId: char.characterId))
        .toList();

    list.add(TransferDestination(ItemDestination.Vault));
    return list;
  }
}
