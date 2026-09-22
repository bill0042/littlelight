import 'package:flutter/material.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_list_item.widget.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:provider/provider.dart';

typedef OnSelectLoadout = void Function(DestinyLoadoutInfo);

class DetailsItemDestinyLoadoutsWidget extends StatelessWidget {
  final List<DestinyLoadoutInfo>? loadouts;
  final OnSelectLoadout? onSelectLoadout;
  const DetailsItemDestinyLoadoutsWidget({
    Key? key,
    this.onSelectLoadout,
    this.loadouts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: PersistentCollapsibleContainer(
        title: Text("Destiny Loadouts".translate(context).toUpperCase()),
        persistenceID: 'details item destiny loadouts',
        content: buildContent(context),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...buildLoadouts(context),
        ],
      ),
    );
  }

  List<Widget> buildLoadouts(BuildContext context) {
    final loadouts = this.loadouts;
    if (loadouts == null) return [];
    final profileBloc = context.read<ProfileBloc>();
    final characters = profileBloc.characters;
    if (characters == null) return [];
    return characters.expand((c) => buildCharacter(context, c)).toList();
  }

  List<Widget> buildCharacter(BuildContext context, DestinyCharacterInfo character) {
      final loadouts = this.loadouts?.where((l) => l.characterId == character.characterId);
      if (loadouts == null || loadouts.isEmpty) return <Widget>[];
      return [
        buildCharacterHeader(context, character),
        ...loadouts
            .map(
              (l) => DestinyLoadoutListItemWidget(
                l,
                onTap: () => onSelectLoadout?.call(l),
              ),
            )
            .toList(),
      ];
  }

  Widget buildCharacterHeader(BuildContext context, DestinyCharacterInfo character) {
    final classDef = context.definition<DestinyClassDefinition>(character.character.classHash);
    final raceDef = context.definition<DestinyRaceDefinition>(character.character.raceHash);
    final className = character.getGenderedClassName(classDef);
    final raceName = character.getGenderedRaceName(raceDef);
    return SizedBox(
      height: 42,
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
}
