// @dart=2.9

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/services/inventory/inventory.package.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/option_sheets/loadout_select_sheet.widget.dart';
import 'package:provider/provider.dart';

//TODO: deprecate this in favor of new equipment info widget
class VaultInfoWidget extends CharacterInfoWidget {
  const VaultInfoWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VaultInfoWidgetState();
  }
}

class VaultInfoWidgetState extends CharacterInfoWidgetState<VaultInfoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  loadDefinitions() {}

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      mainCharacterInfo(context, character),
      Positioned.fill(
        child: ghostIcon(context),
      ),
      currencyInfo(context),
      characterStatsInfo(context, null),
      Positioned.fill(
          child: MaterialButton(
              child: Container(),
              onPressed: () {
                showOptionsSheet(context);
              }))
    ]);
  }

  @override
  Widget mainCharacterInfo(BuildContext context, DestinyCharacterComponent character) {
    return Positioned(
        top: 0,
        left: 8,
        bottom: 16,
        child: Container(
          alignment: Alignment.centerLeft,
          child: ManifestText<DestinyVendorDefinition>(1037843411,
              uppercase: true, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        ));
  }

  @override
  Widget characterStatsInfo(BuildContext context, DestinyCharacterComponent character) {
    // int itemCount = profile
    //     .getAllItems()
    //     .where((i) => i.item.bucketHash == InventoryBucket.general)
    //     .length;
    // return Positioned(
    //   right: 8,
    //   top: 0,
    //   bottom: 16,
    //   child: Container(
    //       alignment: Alignment.centerRight,
    //       child: ManifestText<DestinyInventoryBucketDefinition>(InventoryBucket.general,
    //           textExtractor: (def) => "$itemCount/${def.itemCount}",
    //           key: Key("$itemCount"),
    //           style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20))),
    // );
  }

  @override
  showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return const VaultOptionsSheet();
        });
  }
}

class VaultOptionsSheet extends StatefulWidget {
  const VaultOptionsSheet({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VaultOptionsSheetState();
  }
}

class VaultOptionsSheetState extends State<VaultOptionsSheet> with ProfileConsumer, InventoryConsumer {
  InventoryBloc inventoryBloc(BuildContext context) => context.read<InventoryBloc>();
  final TextStyle buttonStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

  List<ItemWithOwner> itemsInPostmaster;

  @override
  void initState() {
    super.initState();
    getItemsInPostmaster();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [buildTransferLoadout(), Container(height: 4), buildPullFromPostmaster()]));
  }

  Widget buildTransferLoadout() {
    final loadouts = context.watch<LoadoutsBloc>().loadouts;
    if ((loadouts?.length ?? 0) <= 0) return Container();
    return buildActionButton(
      TranslatedTextWidget(
        "Transfer Loadout",
        style: buttonStyle,
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      onTap: () {
        Navigator.of(context).pop();
        showModalBottomSheet(
            context: context,
            builder: (context) =>
                LoadoutSelectSheet(loadouts: loadouts, onSelect: (loadout) => inventory.transferLoadout(loadout)));
      },
    );
  }

  Widget buildPullFromPostmaster() {
    if ((itemsInPostmaster?.length ?? 0) <= 0) return Container();
    return buildActionButton(
      TranslatedTextWidget(
        "Pull everything from postmaster",
        style: buttonStyle,
        uppercase: true,
        textAlign: TextAlign.center,
      ),
      onTap: () {
        Navigator.of(context).pop();
        transferEverythingFromPostmaster();
      },
    );
  }

  Widget buildActionButton(Widget content, {Function onTap}) {
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.center,
      children: <Widget>[
        Positioned.fill(
            child: Material(
          color: Theme.of(context).colorScheme.secondary,
        )),
        Container(padding: const EdgeInsets.all(8), child: content),
        Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                )))
      ],
    );
  }

  transferEverythingFromPostmaster() async {
    var characters = profile.characters;
    for (var char in characters) {
      // var all = profile.getCharacterInventory(char.characterId);
      // var inPostmaster = all.where((i) => i.bucketHash == InventoryBucket.lostItems).toList();
      // await inventoryBloc(context).transferMultiple(inPostmaster, char.characterId);
    }
  }

  Widget buildLoadoutListModal(BuildContext context) {
    final loadouts = context.watch<LoadoutsBloc>().loadouts;
    if (loadouts == null) return Container();
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: loadouts
                  .map(
                    (loadout) => Container(
                        color: LittleLightTheme.of(context).primaryLayers,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Stack(children: [
                          Positioned.fill(
                              child: loadout.emblemHash != null
                                  ? ManifestImageWidget<DestinyInventoryItemDefinition>(
                                      loadout.emblemHash,
                                      fit: BoxFit.cover,
                                      urlExtractor: (def) {
                                        return def?.secondarySpecial;
                                      },
                                    )
                                  : Container()),
                          Container(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                loadout.name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Positioned.fill(
                              child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                inventory.transferLoadout(loadout);
                              },
                            ),
                          ))
                        ])),
                  )
                  .toList(),
            )));
  }

  bool isLoadoutComplete(LoadoutItemIndex index) {
    return false;
  }

  void getItemsInPostmaster() {
    // var all = profile.getAllItems();
    // var inPostmaster = all.where((i) => i.item.bucketHash == InventoryBucket.lostItems).toList();
    // itemsInPostmaster = inPostmaster;
  }
}
