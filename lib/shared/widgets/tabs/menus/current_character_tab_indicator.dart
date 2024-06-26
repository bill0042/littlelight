import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

const _minimumWidth = 64.0;
const _maximumWidth = 184.0;

const _containerPadding = 4.0;

class CurrentCharacterTabIndicator extends StatelessWidget {
  final List<DestinyCharacterInfo?> characters;
  final CustomTabController controller;
  const CurrentCharacterTabIndicator(this.characters, this.controller);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final size = Size(constraints.maxWidth.clamp(_minimumWidth, _maximumWidth), constraints.maxHeight);
        return Container(
            padding: EdgeInsets.all(_containerPadding),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  child: AnimatedBuilder(
                    animation: controller.animation,
                    builder: (context, child) => Stack(children: [
                      Positioned(
                        right: 0,
                        top: -controller.animation.value * (size.height - _containerPadding * 2),
                        child: child ?? Container(),
                      ),
                    ]),
                    child: buildCharacters(
                        context, Size(size.width - _containerPadding * 2, size.height - _containerPadding * 2)),
                  ),
                )));
      });

  Widget buildCharacters(BuildContext context, Size size) {
    return Column(
        children: characters.map((c) {
      if (c != null) {
        return buildCharacter(context, c, size);
      }
      return buildVault(context, size);
    }).toList());
  }

  Widget buildCharacter(BuildContext context, DestinyCharacterInfo character, Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              character.character.emblemHash,
              urlExtractor: (def) => def.secondarySpecial,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 16),
                    child: ManifestText<DestinyClassDefinition>(
                      character.character.classHash,
                      style: context.textTheme.button,
                      textAlign: TextAlign.right,
                      softWrap: false,
                    ),
                  ),
                ),
                Container(width: 8),
                Container(
                  height: kToolbarHeight,
                  padding: EdgeInsets.all(4),
                  child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    character.character.emblemHash,
                    urlExtractor: (def) => def.secondaryOverlay,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVault(BuildContext context, Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            "assets/imgs/vault-secondary-special.jpg",
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          )),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      "Vault".translate(context),
                      style: context.textTheme.button,
                      textAlign: TextAlign.right,
                      softWrap: false,
                    ),
                  ),
                ),
                Container(width: 8),
                Container(
                    height: kToolbarHeight,
                    padding: EdgeInsets.all(4),
                    child: Image.asset(
                      "assets/imgs/vault-secondary-overlay.png",
                      fit: BoxFit.cover,
                      alignment: Alignment.centerLeft,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
