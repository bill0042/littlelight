import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_talent_node_category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/shimmer-helper.dart';
import 'package:little_light/widgets/item_list/items/inventory_item.widget.dart';
import 'package:tinycolor/tinycolor.dart';

class SubclassInventoryItemWidget extends InventoryItemWidget {
  SubclassInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, definition, instanceInfo);

  @override
  State<StatefulWidget> createState() {
    return SubclassInventoryItemWidgetState();
  }
}

class SubclassInventoryItemWidgetState extends InventoryItemWidgetState {
  DestinyItemTalentGridComponent talentGrid;
  DestinyTalentGridDefinition talentGridDef;


  @override
    void initState() {
      talentGrid = widget.profile.getTalentGrid(widget.item.itemInstanceId);
      super.initState();
    }

  @override
  loadDefinitions() async{
    talentGridDef = await widget.manifest.getTalentGridDefinition(talentGrid.talentGridHash);
    return super.loadDefinitions();
  }

  @override
  Widget itemIcon(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        width: iconSize + padding * 2,
        height: iconSize + padding * 2,
        child: itemIconImage(context));
  }

  @override
  Widget nameBar(BuildContext context) {
    if(talentGridDef == null || talentGrid == null){
      return Container();
    }
    Color damageTypeColor =
        DestinyData.getDamageTypeColor(definition.talentGrid.hudDamageType);
    Iterable<int> activatedNodes = talentGrid.nodes
        .where((node) => node.isActivated)
        .map((node) => node.nodeIndex);
    Iterable<DestinyTalentNodeCategory> selectedSkills =
        talentGridDef.nodeCategories.where((category) {
      var overlapping = category.nodeHashes
          .where((nodeHash) => activatedNodes.contains(nodeHash));
      return overlapping.length > 0;
    }).toList();
    DestinyTalentNodeCategory subclassPath =
        selectedSkills.firstWhere((nodeDef) => nodeDef.isLoreDriven);
    BoxDecoration decoration = BoxDecoration(
        gradient: LinearGradient(colors: <Color>[
      TinyColor(damageTypeColor).saturate(30).darken(30).color,
      Colors.transparent
    ]));
    return Positioned(
      left: iconSize / 2 + padding,
      right: 0,
      top: 0,
      bottom: 0,
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: AlignmentDirectional.centerStart,
              padding: EdgeInsets.symmetric(
                  horizontal: iconSize / 2 + padding * 2, vertical: padding),
              decoration: decoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(definition.displayProperties.name.toUpperCase(),
                      style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold)),
                  Text(subclassPath.displayProperties.name,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                          fontSize: 12))
                ],
              ),
            ),
          ]),
    );
  }

  @override
  background(BuildContext context) {
    var damageTypeColor = DestinyData.getDamageTypeColor(
        widget.definition.talentGrid.hudDamageType);
    BoxDecoration decoration = BoxDecoration(
        gradient:
            RadialGradient(radius: 3, center: Alignment(.7, 0), colors: <Color>[
      TinyColor(damageTypeColor).lighten(15).saturate(50).color,
      damageTypeColor,
      TinyColor(damageTypeColor).darken(40).saturate(50).color,
    ]));
    return Positioned.fill(
        child: Container(
            decoration: decoration,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              CachedNetworkImage(
                width: 140,
                imageUrl:
                    "${BungieApiService.baseUrl}${widget.definition.secondaryIcon}",
                fit: BoxFit.fitWidth,
                alignment: AlignmentDirectional.topEnd,
              )
            ])));
  }

  Widget categoryName(BuildContext context) {
    return null;
  }

  @override
  Widget itemIconPlaceholder(BuildContext context) {
    return ShimmerHelper.getDefaultShimmer(context,
        child: Icon(DestinyData.getClassIcon(widget.definition.classType),
            size: iconSize * .75));
  }
}
