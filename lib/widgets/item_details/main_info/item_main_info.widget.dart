// @dart=2.9

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/primary_stat.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/wishlist_badges.widget.dart';

class ItemMainInfoWidget extends BaseDestinyStatefulItemWidget {
  ItemMainInfoWidget(
      DestinyItemComponent item, DestinyInventoryItemDefinition definition, DestinyItemInstanceComponent instanceInfo,
      {Key key, String characterId})
      : super(item: item, definition: definition, instanceInfo: instanceInfo, key: key, characterId: characterId);

  @override
  State<StatefulWidget> createState() {
    return ItemMainInfoWidgetState();
  }
}

class ItemMainInfoWidgetState extends BaseDestinyItemState<ItemMainInfoWidget> with WishlistsConsumer, ProfileConsumer {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(getEnhancedDefinitionName(definition)),
              Padding(padding: EdgeInsets.only(top: 8), child: primaryStat(context))
            ],
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          (definition?.displayProperties?.description?.length ?? 0) > 0
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    definition.displayProperties.description,
                  ))
              : Container(),
          // buildMaxPowerInfo(context),
          buildEmblemInfo(context),
          buildWishListInfo(context),
          // buildLockInfo(context),
        ]));
  }

  String getEnhancedDefinitionName(DestinyInventoryItemDefinition definition) {
    String itemTypeDisplayName = definition?.itemTypeDisplayName ?? "";

    final questCategoryHash = 16;
    if (definition?.itemCategoryHashes?.contains(questCategoryHash) ?? false) {
      List<int> stepHashes = definition.setData.itemList.map((i) => i.itemHash)?.toList() ?? [];
      int currentIndex = stepHashes.indexOf(item.itemHash);
      int allSteps = stepHashes.length;
      return itemTypeDisplayName + " (${currentIndex + 1}/$allSteps)";
    }

    return itemTypeDisplayName;
  }

  Widget buildEmblemInfo(BuildContext context) {
    if (definition?.itemType != DestinyItemType.Emblem) return Container();
    return Container(
        alignment: Alignment.center,
        child: QueuedNetworkImage(
          imageUrl: BungieApiService.url(definition.secondaryIcon),
        ));
  }

  Widget buildWishListInfo(BuildContext context) {
    final reusable = profile.getItemReusablePlugs(item?.itemInstanceId);
    final tags = wishlistsService.getWishlistBuildTags(itemHash: item?.itemHash, reusablePlugs: reusable);
    if (tags == null || tags.length == 0) return Container();
    if (tags.contains(WishlistTag.GodPVE) && tags.contains(WishlistTag.GodPVP)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgesWidget(tags: [WishlistTag.GodPVE, WishlistTag.GodPVP].toSet()),
            Container(
              width: 8,
            ),
            Expanded(child: Text("This item is considered a godroll for both PvE and PvP.".translate(context)))
          ]));
    }
    var rows = <Widget>[];
    if (tags.contains(WishlistTag.GodPVE)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgesWidget(tags: [WishlistTag.GodPVE].toSet()),
        Container(
          width: 8,
        ),
        Expanded(child: Text("This item is considered a PvE godroll.".translate(context)))
      ])));
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgesWidget(tags: [WishlistTag.GodPVP].toSet()),
        Container(
          width: 8,
        ),
        Expanded(child: Text("This item is considered a PvP godroll.".translate(context)))
      ])));
    }
    if (tags.contains(WishlistTag.PVE) && tags.contains(WishlistTag.PVP) && rows.length == 0) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgesWidget(tags: [WishlistTag.PVE, WishlistTag.PVP].toSet()),
            Container(
              width: 8,
            ),
            Expanded(child: Text("This item is considered a good roll for both PvE and PvP.".translate(context)))
          ]));
    }
    if (tags.contains(WishlistTag.PVE) && !tags.contains(WishlistTag.GodPVE)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgesWidget(tags: [WishlistTag.PVE].toSet()),
        Container(
          width: 8,
        ),
        Expanded(child: Text("This item is considered a good roll for PVE.".translate(context)))
      ])));
    }
    if (tags.contains(WishlistTag.PVP) && !tags.contains(WishlistTag.GodPVP)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgesWidget(tags: [WishlistTag.PVP].toSet()),
        Container(
          width: 8,
        ),
        Expanded(child: Text("This item is considered a good roll for PVP.".translate(context)))
      ])));
    }
    if (tags.contains(WishlistTag.Bungie)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgesWidget(tags: [WishlistTag.Bungie].toSet()),
        Container(
          width: 8,
        ),
        Expanded(child: Text("This item is a Bungie curated roll.".translate(context)))
      ])));
    }
    if (rows.length > 0) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Column(
            children: rows,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ));
    }
    if (tags.contains(WishlistTag.Trash)) {
      return Container(
          padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
          child: Row(children: [
            WishlistBadgesWidget(tags: [WishlistTag.Trash].toSet()),
            Container(
              width: 8,
            ),
            Expanded(child: Text("This item is considered a trash roll.".translate(context)))
          ]));
    }
    return Container();
  }

  Widget primaryStat(context) {
    return PrimaryStatWidget(
      item: item,
      definition: definition,
      instanceInfo: instanceInfo,
      suppressLabel: true,
      fontSize: 36,
    );
  }
}
