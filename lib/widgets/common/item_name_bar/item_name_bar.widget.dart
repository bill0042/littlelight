import 'package:bungie_api/enums/item_state.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateless_item.widget.dart';
import 'package:provider/provider.dart';

class ItemNameBarWidget extends BaseDestinyStatelessItemWidget {
  final double fontSize;
  final EdgeInsets padding;
  final bool multiline;
  final FontWeight fontWeight;
  final Widget? trailing;
  ItemNameBarWidget(
    DestinyItemComponent? item,
    DestinyInventoryItemDefinition? definition,
    DestinyItemInstanceComponent? instanceInfo, {
    Key? key,
    String? characterId,
    this.fontSize = 14,
    this.padding = const EdgeInsets.all(8),
    this.multiline = false,
    this.fontWeight = FontWeight.w500,
    this.trailing,
  }) : super(item: item, definition: definition, instanceInfo: instanceInfo, key: key, characterId: characterId);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: padding.left, right: padding.right),
      height: fontSize + padding.top * 2,
      alignment: Alignment.centerLeft,
      decoration: nameBarBoxDecoration(context),
      child: Material(color: Colors.transparent, child: nameBarContent(context)),
    );
  }

  BoxDecoration nameBarBoxDecoration(BuildContext context) {
    ItemState state = item?.state ?? ItemState.None;
    if (!state.contains(ItemState.Masterwork)) {
      return BoxDecoration(color: definition?.inventory?.tierType?.getColor(context));
    }
    return BoxDecoration(
        color: definition?.inventory?.tierType?.getColor(context),
        image: DecorationImage(
            repeat: ImageRepeat.repeatX, alignment: Alignment.topCenter, image: getMasterWorkTopOverlay()));
  }

  ExactAssetImage getMasterWorkTopOverlay() {
    if (definition?.inventory?.tierType == TierType.Exotic) {
      return const ExactAssetImage("assets/imgs/masterwork-top-exotic.png");
    }
    return const ExactAssetImage("assets/imgs/masterwork-top.png");
  }

  Widget nameBarContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: nameBarTextField(context),
        ),
        trailing ?? Container()
      ],
    );
  }

  Widget nameBarTextField(BuildContext context) {
    final itemNotes = context.watch<ItemNotesBloc>();
    var customName = itemNotes.customNameFor(item?.itemHash, item?.itemInstanceId)?.toUpperCase();
    if (customName?.isEmpty ?? false) {
      customName = null;
    }
    return Text(customName ?? definition?.displayProperties?.name?.toUpperCase() ?? "",
        overflow: TextOverflow.fade,
        maxLines: multiline ? 2 : 1,
        softWrap: multiline,
        style: TextStyle(
          fontSize: fontSize,
          color: definition?.inventory?.tierType?.getTextColor(context),
          fontWeight: fontWeight,
        ));
  }
}
