import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/pages/home/destiny_loadouts.bloc.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_list_item.widget.dart';
import 'package:little_light/modules/search/blocs/filter_options/destiny_loadout_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';
import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class DestinyLoadoutFilterWidget extends BaseDrawerFilterWidget<DestinyLoadoutFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Destiny Loadout".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, DestinyLoadoutFilterOptions data) {
    final loadoutsBloc = context.watch<DestinyLoadoutsBloc>();
    final availableValues = data.availableValues;
    final include = data.include;
    final exclude = data.exclude;
    final characters = loadoutsBloc.characters ?? [];
    final characterLoadouts = characters
        .map((c) {
          final loadouts =
              loadoutsBloc
                  .getLoadoutsFromCharacter(c)
                  ?.where((l) => availableValues.contains((characterId: l.characterId, loadoutIndex: l.index)))
                  .toList() ??
              [];
          return (character: c, loadouts: loadouts);
        })
        .where((e) => e.loadouts.isNotEmpty);
    final hasNone = availableValues.contains(null);
    return Column(
      children:
          characterLoadouts.expand((e) {
            return [
              buildCharacterHeader(context, e.character),
              ...e.loadouts.map((loadout) {
                final key = (characterId: loadout.characterId, loadoutIndex: loadout.index);
                return FilterButtonWidget(
                  DestinyLoadoutListItemWidget(loadout),
                  //buildLoadout(context, loadout),
                  selected: include.contains(key),
                  excluded: exclude.contains(key),
                  onTap: () => updateDiscreteOption(context, data, key, false),
                  onLongPress: () => updateDiscreteOption(context, data, key, true),
                  padding: 0,
                );
              }),
            ].toList();
          }).toList() +
          [
            if (hasNone)
              FilterButtonWidget(
                Text(
                  "None".translate(context).toUpperCase(),
                ),
                selected: include.contains(null),
                excluded: exclude.contains(null),
                onTap: () => updateDiscreteOption(context, data, null, false),
                onLongPress: () => updateDiscreteOption(context, data, null, true),
              ),
          ],
    );
  }

  Widget buildCharacterHeader(BuildContext context, DestinyCharacterInfo character) {
    final classDef = context.definition<DestinyClassDefinition>(character.character.classHash);
    final raceDef = context.definition<DestinyRaceDefinition>(character.character.raceHash);
    final className = character.getGenderedClassName(classDef);
    final raceName = character.getGenderedRaceName(raceDef);
    return SizedBox(
      height: 54,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
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
            Row(
              spacing: 4,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    character.character.emblemHash,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(className, style: context.textTheme.itemNameHighDensity),
                    Text(raceName, style: context.textTheme.caption),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoadout(BuildContext context, DestinyLoadoutInfo loadout) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            context.theme.surfaceLayers.layer0.withValues(alpha: .7),
            context.theme.surfaceLayers.layer0.withAlpha(0),
          ],
        ),
      ),
      //decoration: BoxDecoration(
      //  border: Border.all(color: context.theme.onSurfaceLayers.layer3, width: 1),
      //  borderRadius: BorderRadius.circular(4),
      //),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          child: Stack(
            children: [
              Positioned.fill(child: buildBackground(context, loadout)),
              Container(
                padding: EdgeInsets.all(4),
                child: buildLoadoutTitle(context, loadout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBackground(BuildContext context, DestinyLoadoutInfo loadout) {
    final colorDef = context.definition<DestinyLoadoutColorDefinition>(loadout.loadout.colorHash);
    if (colorDef == null) {
      return Container(color: context.theme.surfaceLayers.layer2);
    }
    return QueuedNetworkImage.fromBungie(colorDef.colorImagePath, fit: BoxFit.cover);
  }

  Widget buildLoadoutTitle(BuildContext context, DestinyLoadoutInfo loadout) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text((loadout.index + 1).toString(), style: context.textTheme.itemNameHighDensity),
          SizedBox(width: 8),
          Expanded(child: buildLoadoutName(context, loadout)),
          buildLoadoutIcon(context, loadout),
        ],
      ),
    );
  }

  Widget buildLoadoutName(BuildContext context, DestinyLoadoutInfo loadout) {
    final name = context.definition<DestinyLoadoutNameDefinition>(loadout.loadout.nameHash)?.name;
    if (name == null) {
      return Text("New Loadout".translate(context).toUpperCase(), style: context.textTheme.itemNameHighDensity);
    }
    return Text(name.toUpperCase(), style: context.textTheme.itemNameHighDensity);
  }

  Widget buildLoadoutIcon(BuildContext context, DestinyLoadoutInfo loadout) {
    final iconDef = context.definition<DestinyLoadoutIconDefinition>(loadout.loadout.iconHash);
    if (iconDef == null) {
      return Container(width: 24, height: 24, child: const FaIcon(FontAwesomeIcons.squarePlus, size: 18));
    }
    return Container(width: 24, height: 24, child: QueuedNetworkImage.fromBungie(iconDef.iconImagePath));
  }
}
