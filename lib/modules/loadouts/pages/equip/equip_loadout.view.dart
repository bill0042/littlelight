import 'dart:math';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_info.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.bloc.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_list_item.widget.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/shared/widgets/transfer_destinations/transfer_destinations.widget.dart';
import 'package:little_light/utils/color_utils.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';

class EquipLoadoutView extends StatelessWidget with ProfileConsumer {
  EquipLoadoutBloc _bloc(BuildContext context) => context.read<EquipLoadoutBloc>();
  EquipLoadoutBloc _state(BuildContext context) => context.watch<EquipLoadoutBloc>();

  Color getBackgroundColor(BuildContext context) {
    final emblemDefinition = context.definition<DestinyInventoryItemDefinition>(_state(context).emblemHash);
    final bgColor = emblemDefinition?.backgroundColor;
    final background = context.theme.surfaceLayers.layer1;
    if (bgColor == null) return background;
    return Color.lerp(bgColor.toMaterialColor(), background, .5) ?? background;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      appBar: buildAppBar(context),
      body: Container(
        alignment: Alignment.center,
        child: buildBody(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) => AppBar(
        title: Text(_state(context).loadoutName),
        flexibleSpace: buildAppBarBackground(context),
      );

  Widget buildAppBarBackground(BuildContext context) {
    final emblemDefinition = context.definition<DestinyInventoryItemDefinition>(_state(context).emblemHash);
    if (emblemDefinition == null) return Container();
    if (emblemDefinition.secondarySpecial?.isEmpty ?? true) return Container();
    return Container(
        constraints: const BoxConstraints.expand(),
        child: QueuedNetworkImage(
            imageUrl: BungieApiService.url(emblemDefinition.secondarySpecial),
            fit: BoxFit.cover,
            alignment: const Alignment(-.8, 0)));
  }

  Widget buildBody(BuildContext context) {
    final screenPadding = MediaQuery.of(context).padding;
    return Column(children: [
      Expanded(
        child: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8)
                .copyWith(top: 0, left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(minWidth: double.maxFinite),
              child: Container(
                constraints: const BoxConstraints(maxWidth: LoadoutListItemWidget.maxWidth),
                child: Column(children: [
                  buildEquippableItems(context),
                  Container(height: 16),
                  buildUnequippable(context),
                ]),
              ),
            ),
          ),
        ),
      ),
      buildFooter(context),
    ]);
  }

  Widget buildEquippableItems(BuildContext context) {
    final items = _state(context).equippableItems;
    final classes = [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock];
    if (items == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
            HeaderWidget(
              child: Text(
                "Items to Equip".translate(context).toUpperCase(),
              ),
            ),
            Container(
              height: 8,
            ),
            buildEquippableRow(context, DestinyClass.Unknown, items[DestinyClass.Unknown]),
          ] +
          classes
              .map((c) {
                final classItems = items[c];
                return buildEquippableRow(context, c, classItems);
              })
              .whereType<Widget>()
              .toList(),
    );
  }

  Widget buildUnequippable(BuildContext context) {
    final unequippable = _state(context).unequippableItems;
    if (unequippable == null || unequippable.isEmpty) return Container();
    return Column(children: [
      HeaderWidget(
        child: Text(
          "Items to Transfer".translate(context).toUpperCase(),
        ),
      ),
      Container(
        height: 8,
      ),
      GridView(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
        physics: const NeverScrollableScrollPhysics(),
        children: unequippable
            .map((e) => Container(
                  padding: const EdgeInsets.all(2),
                  child: buildItemIcon(context, e.inventoryItem),
                ))
            .toList(),
      ),
    ]);
  }

  Widget buildEquippableRow(BuildContext context, DestinyClass destinyClass, List<LoadoutItemInfo?>? items) {
    final rowItems = items ?? List<LoadoutItemInfo?>.filled(6, null);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
            Expanded(child: buildClassIcon(context, destinyClass)),
          ] +
          rowItems
              .map(
                (e) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    child: buildItemIcon(context, e?.inventoryItem),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget buildClassIcon(BuildContext context, DestinyClass destinyClass) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        alignment: Alignment.center,
        child: Icon(destinyClass.icon),
      ),
    );
  }

  Widget buildItemIcon(BuildContext context, DestinyItemInfo? item) {
    final itemHash = item?.itemHash;
    if (item == null || itemHash == null) {
      return AspectRatio(
        aspectRatio: 1,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(1835369552),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: InventoryItemIcon(item),
    );
  }

  buildFooter(BuildContext context) {
    final equip = _state(context).equipCharacters;
    final transfer = _state(context).transferCharacters;
    if (equip == null && transfer == null) return Container();
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(minWidth: double.maxFinite),
      color: context.theme.surfaceLayers.layer1,
      child: SafeArea(
        top: false,
        child: Container(
          child: TransferDestinationsWidget(
              equipDestinations: equip,
              transferDestinations: transfer,
              onAction: (action, character) {
                switch (action) {
                  case TransferActionType.Transfer:
                    _bloc(context).transferLoadout(character);
                    return;
                  case TransferActionType.Equip:
                    _bloc(context).equipLoadout(character);
                    return;
                }
              }),
        ),
      ),
    );
  }
}
