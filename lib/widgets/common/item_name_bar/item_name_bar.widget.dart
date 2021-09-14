import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/item_notes/item_notes.provider.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';

class ItemNameBarWidget extends BaseDestinyStatelessItemWidget {
  final double fontSize;
  final EdgeInsets padding;
  final bool multiline;
  final FontWeight fontWeight;
  final Widget trailing;
  ItemNameBarWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    Key key,
    String characterId,
    this.fontSize = 14,
    this.padding = const EdgeInsets.all(8),
    this.multiline = false,
    this.fontWeight = FontWeight.w500,
    this.trailing,
  }) : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(left: padding.left, right: padding.right),
      height: fontSize + padding.top * 2,
      alignment: Alignment.centerLeft,
      decoration: nameBarBoxDecoration(),
      child: Material(color: Colors.transparent, child: nameBarContent(ref)),
    );
  }

  BoxDecoration nameBarBoxDecoration() {
    ItemState state = item?.state ?? ItemState.None;
    if (!state.contains(ItemState.Masterwork)) {
      return BoxDecoration(
          color: DestinyData.getTierColor(definition.inventory.tierType));
    }
    return BoxDecoration(
        color: DestinyData.getTierColor(definition.inventory.tierType),
        image: DecorationImage(
            repeat: ImageRepeat.repeatX,
            alignment: Alignment.topCenter,
            image: getMasterWorkTopOverlay()));
  }

  ExactAssetImage getMasterWorkTopOverlay() {
    if (definition.inventory.tierType == TierType.Exotic) {
      return ExactAssetImage("assets/imgs/masterwork-top-exotic.png");
    }
    return ExactAssetImage("assets/imgs/masterwork-top.png");
  }

  Widget nameBarContent(WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: nameBarTextField(ref),
        ),
        trailing ?? Container()
      ],
    );
  }

  Widget nameBarTextField(WidgetRef ref) {
    var customName = ref
        .read(itemNotesProvider)
        .getNotesForItem(item?.itemHash, item?.itemInstanceId)
        ?.customName
        ?.toUpperCase();
    if ((customName?.length ?? 0) == 0) {
      customName = null;
    }
    return Text(customName ?? definition.displayProperties.name.toUpperCase(),
        overflow: TextOverflow.fade,
        maxLines: multiline ? 2 : 1,
        softWrap: multiline,
        style: TextStyle(
          fontSize: fontSize,
          color: DestinyData.getTierTextColor(definition.inventory.tierType),
          fontWeight: fontWeight,
        ));
  }
}
