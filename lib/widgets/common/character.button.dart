import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class CharacterButton extends StatelessWidget {
  final String characterId;
  final Function onTap;
  final double iconSize;
  final double fontSize;
  final double borderSize;

  const CharacterButton(
      {Key key,
      this.characterId,
      this.onTap,
      this.iconSize = kToolbarHeight,
      this.fontSize = 9,
      this.borderSize = 1})
      : super(key: key);

  bool get lastPlayed {
    var characters = ProfileService().getCharacters();
    String lastPlayedCharId = characters.first.characterId;
    DateTime lastPlayedDate =
        DateTime.tryParse(characters.first.dateLastPlayed) ??
            DateTime.fromMicrosecondsSinceEpoch(0);
    characters.forEach((char) {
      var date = DateTime.tryParse(char.dateLastPlayed) ??
          DateTime.fromMicrosecondsSinceEpoch(0);
      if (date.isAfter(lastPlayedDate)) {
        lastPlayedDate = date;
        lastPlayedCharId = char.characterId;
      }
    });
    return lastPlayedCharId == characterId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: borderSize, color: Colors.grey.shade400)),
                foregroundDecoration: lastPlayed
                    ? CornerBadgeDecoration(
                        badgeSize: 15,
                        position: CornerPosition.TopLeft,
                        colors: [Colors.yellow])
                    : null,
                child: Stack(fit: StackFit.expand, children: [
                  characterIcon(context),
                  characterClassName(context),
                  Material(
                    type: MaterialType.button,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onTap();
                      },
                    ),
                  ),
                ]))));
  }

  Widget characterIcon(BuildContext context) {
    DestinyCharacterComponent character =
        ProfileService().getCharacter(characterId);
    return ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.emblemHash);
  }

  Widget characterClassName(BuildContext context) {
    DestinyCharacterComponent character =
        ProfileService().getCharacter(characterId);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
          padding: EdgeInsets.all(2),
          color: Colors.black.withOpacity(.7),
          child: ManifestText<DestinyClassDefinition>(character.classHash,
              textExtractor: (def) {
            return def.genderedClassNamesByGenderHash[
                    "${character.genderHash}"] ??
                "";
          },
              overflow: TextOverflow.fade,
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.center,
              uppercase: true,
              style:
                  TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold))),
    );
  }
}
