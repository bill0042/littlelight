import 'package:flutter/material.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/widgets/common/character.button.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class EquipOnCharacterButton extends CharacterButton {
  final ItemDestination type;

  const EquipOnCharacterButton(
      {Key key,
      this.type,
      String characterId,
      Function onTap,
      double iconSize = kToolbarHeight,
      double fontSize = 9,
      double borderSize = 1})
      : super(
            key: key,
            borderSize: borderSize,
            characterId: characterId,
            fontSize: fontSize,
            iconSize: iconSize);

  Widget characterIcon(BuildContext context) {
    switch (type) {
      case ItemDestination.Vault:
        return Image.asset('assets/imgs/vault-icon.jpg');

      case ItemDestination.Inventory:
        return Image.asset('assets/imgs/inventory-icon.jpg');

      default:
        return super.characterIcon(context);
    }
  }

  Widget characterClassName(BuildContext context) {
    switch (type) {
      case ItemDestination.Character:
        return super.characterClassName(context);
        break;

      case ItemDestination.Inventory:
        return Positioned(
          bottom: 1,
          left: 1,
          right: 1,
          child: Container(
              padding: EdgeInsets.all(2),
              color: Colors.black.withOpacity(.7),
              child: TranslatedTextWidget("Inventory",
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  uppercase: true,
                  style: TextStyle(
                      fontSize: fontSize, fontWeight: FontWeight.bold))),
        );

      case ItemDestination.Vault:
        return Positioned(
          bottom: 1,
          left: 1,
          right: 1,
          child: Container(
              padding: EdgeInsets.all(2),
              color: Colors.black.withOpacity(.7),
              child: TranslatedTextWidget("Vault",
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  uppercase: true,
                  style: TextStyle(
                      fontSize: fontSize, fontWeight: FontWeight.bold))),
        );
      default:
        return Container();
    }
  }
}
