import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_owner_filter_options.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/filter_button.widget.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';
import 'base_drawer_filter.widget.dart';

class ItemOwnerFilterWidget extends BaseDrawerFilterWidget<ItemOwnerFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Location".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, ItemOwnerFilterOptions data) {
    final availableValues = data.availableValues;
    final characters = context.watch<ProfileBloc>().characters;
    final characterList =
        characters
            ?.where((c) => c.characterId != null)
            .map((c) {
              final ItemOwnerValue itemOwner = (ownerType: ItemOwnerType.Character, ownerValue: c.characterId);
              return (character: c, itemOwner: itemOwner);
            })
            .where((e) => availableValues.contains(e.itemOwner)) ??
        [];
    final include = data.include;
    final exclude = data.exclude;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          children: characterList.map(
            (entry) {
              final char = entry.character;
              final itemOwner = entry.itemOwner;
              return FilterButtonWidget(
                Row(
                  children: [
                    Container(
                      width: 36,
                      child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                        char.character.emblemHash,
                        urlExtractor: (def) => def.secondaryOverlay,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 8),
                    ManifestText<DestinyClassDefinition>(
                      char.character.classHash,
                      textExtractor: (def) => def.genderedClassNamesByGenderHash?["${char.character.genderHash}"],
                      uppercase: true,
                    ),
                  ],
                ),
                background: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  char.character.emblemHash,
                  urlExtractor: (def) => def.secondarySpecial,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerLeft,
                ),
                selected: include.contains(itemOwner),
                excluded: exclude.contains(itemOwner),
                onTap: () => updateDiscreteOption(context, data, itemOwner, false),
                onLongPress: () => updateDiscreteOption(context, data, itemOwner, true),
              );
            },
          ).toList(),
        ),
        Row(
          children: [
            if (data.availableValues.contains(ItemOwnerVault))
              Expanded(
                child: FilterButtonWidget(
                  buildNonCharacterFilterButtonContent(
                    context,
                    Image.asset("assets/imgs/vault-secondary-overlay.png"),
                    Text("Vault".translate(context).toUpperCase()),
                  ),
                  background: Image.asset(
                    "assets/imgs/vault-secondary-special.jpg",
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                  selected: include.contains(ItemOwnerVault),
                  excluded: exclude.contains(ItemOwnerVault),
                  onTap: () => updateDiscreteOption(context, data, ItemOwnerVault, false),
                  onLongPress: () => updateDiscreteOption(context, data, ItemOwnerVault, true),
                ),
              ),
            if (data.availableValues.contains(ItemOwnerProfile))
              Expanded(
                child: FilterButtonWidget(
                  buildNonCharacterFilterButtonContent(
                    context,
                    ManifestImageWidget<DestinyInventoryItemDefinition>(
                      profileCharacterEmblemHash,
                      urlExtractor: (def) => def.secondaryOverlay,
                      fit: BoxFit.contain,
                    ),
                    Text("Profile".translate(context).toUpperCase()),
                  ),
                  background: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    profileCharacterEmblemHash,
                    urlExtractor: (def) => def.secondarySpecial,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                  selected: include.contains(ItemOwnerProfile),
                  excluded: exclude.contains(ItemOwnerProfile),
                  onTap: () => updateDiscreteOption(context, data, ItemOwnerProfile, false),
                  onLongPress: () => updateDiscreteOption(context, data, ItemOwnerProfile, true),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildNonCharacterFilterButtonContent(BuildContext context, Widget icon, Widget label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(child: icon, width: 36, height: 36),
        SizedBox(width: 8),
        Expanded(child: label),
      ],
    );
  }
}
