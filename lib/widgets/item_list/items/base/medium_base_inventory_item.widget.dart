import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/item_mods.widget.dart';

class MediumBaseInventoryItemWidget extends BaseInventoryItemWidget {
  MediumBaseInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      @required String uniqueId,
      @required String characterId})
      : super(item, itemDefinition, instanceInfo,
            key: key, characterId: characterId, uniqueId: uniqueId);

  Widget positionedNameBar(BuildContext context, WidgetRef ref) {
    return Positioned(left: 0, right: 0, child: itemHeroNamebar(context, ref));
  }

  Widget nameBar(BuildContext context, WidgetRef ref) {
    return Consumer(
        builder: (context, ref, _) => ItemNameBarWidget(
              item,
              definition,
              instanceInfo,
              trailing: namebarTrailingWidget(context, ref),
              padding: EdgeInsets.all(padding),
              fontSize: titleFontSize,
              fontWeight: FontWeight.w500,
            ));
  }

  Widget categoryName(BuildContext context, WidgetRef ref) {
    return null;
  }

  Widget positionedIcon(BuildContext context, WidgetRef ref) {
    return Positioned(
        top: padding * 3 + titleFontSize,
        left: padding,
        width: iconSize,
        height: iconSize,
        child: itemIconHero(context, ref));
  }

  @override
  double get iconBorderWidth {
    return 1;
  }

  double get iconSize {
    return 48;
  }

  double get padding {
    return 4;
  }

  double get titleFontSize {
    return 10;
  }

  @override
  double get tagIconSize {
    return 12;
  }

  Widget perksWidget(BuildContext context, WidgetRef ref) {
    return Container();
  }

  @override
  Widget modsWidget(BuildContext context, WidgetRef ref) {
    if (item?.itemInstanceId == null) return Container();
    return Positioned(
        bottom: 4,
        right: 4,
        child: ItemModsWidget(
            definition: definition,
            itemSockets: profile(ref).getItemSockets(item?.itemInstanceId),
            iconSize: 22));
  }
}
