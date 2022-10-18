// @dart=2.9

import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/enums/item_perk_visibility.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_material_requirement_set_definition.dart';
import 'package:bungie_api/models/destiny_sandbox_perk_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_socket_details.widget.dart';
import 'package:little_light/widgets/item_sockets/plug_wishlist_tag_icons.mixin.dart';
import 'package:little_light/widgets/item_sockets/selectable_perk.widget.dart';
import 'package:little_light/widgets/item_stats/screenshot_socket_item_stats.widget.dart';

import 'item_socket.controller.dart';
import 'plug_grid_view.dart';

class ScreenshotSocketDetailsWidget extends BaseSocketDetailsWidget {
  final double pixelSize;
  ScreenshotSocketDetailsWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition parentDefinition,
      ItemSocketController controller,
      this.pixelSize})
      : super(item: item, definition: parentDefinition, controller: controller);

  @override
  _ScreenshotPerkDetailsWidgetState createState() => _ScreenshotPerkDetailsWidgetState();
}

class _ScreenshotPerkDetailsWidgetState extends BaseSocketDetailsWidgetState<ScreenshotSocketDetailsWidget>
    with PlugWishlistTagIconsMixin {
  @override
  void initState() {
    print(super.controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      buildOptions(context),
      Container(
        height: widget.pixelSize * 16,
      ),
      Container(
        height: widget.pixelSize * 5,
        color: Colors.grey.shade400,
      ),
      Container(
          padding: EdgeInsets.all(16 * widget.pixelSize),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                definition?.displayProperties?.name?.toUpperCase() ?? "",
                style: TextStyle(fontSize: 30 * widget.pixelSize, fontWeight: FontWeight.w500),
              ),
              if (definition?.itemTypeDisplayName != null)
                Text(definition?.itemTypeDisplayName ?? "",
                    style: TextStyle(
                        fontSize: 24 * widget.pixelSize, color: Colors.grey.shade500, fontWeight: FontWeight.w300))
            ],
          )),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * widget.pixelSize, vertical: 8 * widget.pixelSize),
          color: Colors.black.withOpacity(.7),
          child: buildContent(context)),
      buildResourceCost(context)
    ]);
  }

  Widget buildResourceCost(BuildContext context) {
    var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    if (requirementHash != null) {
      return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(
          requirementHash,
          (def) => Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.7),
                border: Border(top: BorderSide(color: Colors.grey.shade500, width: 1)),
              ),
              padding: EdgeInsets.all(16 * widget.pixelSize),
              child: Column(
                children: def.materials.where((m) => (m.count ?? 0) > 0).map((m) {
                  return Row(
                    children: <Widget>[
                      Container(
                          width: 24 * widget.pixelSize,
                          height: 24 * widget.pixelSize,
                          child: ManifestImageWidget<DestinyInventoryItemDefinition>(m.itemHash)),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 8 * widget.pixelSize),
                          child: ManifestText<DestinyInventoryItemDefinition>(
                            m.itemHash,
                            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 22 * widget.pixelSize),
                          ),
                        ),
                      ),
                      Text("${m.count}", style: TextStyle(fontWeight: FontWeight.w300, fontSize: widget.pixelSize * 22))
                    ],
                  );
                }).toList(),
              )),
          key: Key("material_requirements_$requirementHash"));
    }
    return Container();
  }

  Widget buildOptions(BuildContext context) {
    var index = controller.selectedSocketIndex;
    var cat = itemDefinition?.sockets?.socketCategories
        ?.firstWhere((s) => s?.socketIndexes?.contains(index), orElse: () => null);

    var isExoticPerk = DestinyData.socketCategoryIntrinsicPerkHashes.contains(cat?.socketCategoryHash);
    if (isExoticPerk) {
      return Container();
    }

    var isPerk = DestinyData.socketCategoryPerkHashes.contains(cat?.socketCategoryHash);

    if (isPerk && controller.reusablePlugs != null) {
      return Container();
    }
    if (isPerk) {
      return buildRandomPerks(context);
    }
    return buildReusableMods(context);
  }

  Widget buildReusableMods(BuildContext context) {
    var plugs = controller.socketPlugHashes(controller.selectedSocketIndex);
    if ((plugs?.length ?? 0) <= 1) return Container();
    final tabCount = (plugs.length / 10).ceil();
    final rowCount = (plugs.length / 5).ceil().clamp(0, 2);
    final rowHeight = 96 * widget.pixelSize;
    return DefaultTabController(
        length: tabCount,
        child: Container(
            height: rowHeight * rowCount + (rowCount > 1 ? 8 * widget.pixelSize : 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Builder(builder: (context) => pagingButton(context, -1)),
              Container(
                  width: 520 * widget.pixelSize,
                  child: PlugGridView.withItemsPerRow(
                    plugs,
                    maxRows: 2,
                    itemsPerRow: 5,
                    gridSpacing: 8 * widget.pixelSize,
                    itemBuilder: (h) => buildMod(context, controller.selectedSocketIndex, h),
                  )),
              Builder(builder: (context) => pagingButton(context, 1)),
            ])));
  }

  Widget pagingButton(BuildContext context, [int direction = 1]) {
    final controller = DefaultTabController.of(context);
    final length = controller.length;

    return AnimatedBuilder(
        animation: controller.animation,
        builder: (context, child) {
          final currentIndex = controller.index;
          final enabled = direction < 0 ? currentIndex > 0 : currentIndex < length - 1;
          return Container(
            constraints: BoxConstraints.expand(width: 32 * widget.pixelSize),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
            padding: EdgeInsets.all(0),
            alignment: Alignment.center,
            child: !enabled
                ? Container(color: Colors.grey.shade300.withOpacity(.2))
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () {
                          controller.animateTo(currentIndex + direction);
                        },
                        child: Container(
                            constraints: BoxConstraints.expand(),
                            child: Icon(direction > 0 ? FontAwesomeIcons.caretRight : FontAwesomeIcons.caretLeft,
                                size: 30 * widget.pixelSize)))),
          );
        });
  }

  Widget buildRandomPerks(BuildContext context) {
    var plugs = controller.possiblePlugHashes(controller.selectedSocketIndex);
    if (plugs?.isEmpty ?? false) {
      return Container(height: 80 * widget.pixelSize);
    }
    return Wrap(
      runSpacing: 6 * widget.pixelSize,
      spacing: 6 * widget.pixelSize,
      children: plugs.map((h) => buildPerk(context, controller.selectedSocketIndex, h)).toList(),
    );
  }

  Widget buildMod(BuildContext context, int socketIndex, int plugItemHash) {
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color borderColor = isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade300.withOpacity(.5);

    BorderSide borderSide = BorderSide(color: borderColor, width: 3 * widget.pixelSize);
    var def = controller.plugDefinitions[plugItemHash];
    var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    var energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    var canEquip = controller?.canEquip(socketIndex, plugItemHash);
    return Container(
        width: 96 * widget.pixelSize,
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: EdgeInsets.all(0),
        child: AspectRatio(
            aspectRatio: 1,
            child: MaterialButton(
              shape: ContinuousRectangleBorder(side: borderSide),
              padding: EdgeInsets.all(0),
              child: Stack(children: [
                ManifestImageWidget<DestinyInventoryItemDefinition>(plugItemHash),
                energyType == DestinyEnergyType.Any
                    ? Container()
                    : Positioned.fill(
                        child:
                            ManifestImageWidget<DestinyStatDefinition>(DestinyData.getEnergyTypeCostHash(energyType))),
                energyCost == 0
                    ? Container()
                    : Positioned(
                        top: 8 * widget.pixelSize,
                        right: 8 * widget.pixelSize,
                        child: Text(
                          "$energyCost",
                          style: TextStyle(fontSize: 20 * widget.pixelSize),
                        )),
                canEquip
                    ? Container()
                    : Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(.5),
                        ),
                      )
              ]),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }

  Widget buildPerk(BuildContext context, int socketIndex, int plugItemHash) {
    var plugDef = controller.plugDefinitions[plugItemHash];
    int equippedHash = controller.socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;

    bool isSelectedOnSocket = plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    bool isSelected = plugItemHash == controller.selectedPlugHash;

    final canRoll = widget.item == null && controller.canRollPerk(socketIndex, plugItemHash);

    return Container(
        width: 80 * widget.pixelSize,
        child: SelectablePerkWidget(
          selected: isSelected,
          selectedOnSocket: isSelectedOnSocket,
          itemDefinition: controller.definition,
          plugHash: plugItemHash,
          plugDefinition: plugDef,
          equipped: isEquipped,
          canRoll: canRoll,
          scale: widget.pixelSize,
          wishlistScale: widget.pixelSize * 1.8,
          key: Key("$plugItemHash $isSelected $isSelectedOnSocket"),
          onTap: () {
            controller.selectSocket(socketIndex, plugItemHash);
          },
        ));
  }

  buildContent(BuildContext context) {
    Iterable<Widget> items = [
      buildDescription(context),
      buildWishlistInfo(context, 24 * widget.pixelSize, 20 * widget.pixelSize),
      buildPerkNotAvailable(context),
      buildEnergyCost(context),
      buildSandBoxPerks(context),
      buildStats(context),
      buildApplyButton(context)
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: items.toList());
  }

  Widget buildDescription(BuildContext context) {
    if ((definition?.displayProperties?.description?.length ?? 0) == 0) return Container();
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8 * widget.pixelSize),
        child: Text(definition?.displayProperties?.description,
            style: TextStyle(fontSize: 24 * widget.pixelSize, fontWeight: FontWeight.w300)));
  }

  Widget buildPerkNotAvailable(BuildContext context) {
    final canRoll = controller.canRollPerk(controller.selectedSocketIndex, controller.selectedPlugHash);
    if (canRoll) return Container();
    return Container(
      decoration: BoxDecoration(
          color: LittleLightTheme.of(context).errorLayers, borderRadius: BorderRadius.circular(8 * widget.pixelSize)),
      margin: EdgeInsets.all(8 * widget.pixelSize),
      padding: EdgeInsets.all(16 * widget.pixelSize),
      child: TranslatedTextWidget("This perk isn't available on the current season anymore",
          style: TextStyle(fontSize: 24 * widget.pixelSize, fontWeight: FontWeight.w300)),
    );
  }

  Widget buildApplyButton(BuildContext context) {
    var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    final isApplied = controller.selectedPlugHash == controller.socketEquippedPlugHash(controller.selectedSocketIndex);
    final canApply = controller.canApplySocket(controller.selectedSocketIndex, controller.selectedPlugHash);
    final style = TextStyle(fontSize: 24 * widget.pixelSize, fontWeight: FontWeight.w300);
    if (isApplied || !canApply || item?.itemInstanceId == null) {
      return Container();
    }
    final isEnabled = !controller.isSocketBusy(controller.selectedSocketIndex);
    final applyButton = Container(
        padding: EdgeInsets.all(8 * widget.pixelSize),
        child: Material(
            color: isEnabled
                ? LittleLightTheme.of(context).primaryLayers
                : LittleLightTheme.of(context).primaryLayers.withOpacity(.5),
            key: Key("apply_button_${definition.hash}_$isEnabled"),
            child: InkWell(
                onTap: isEnabled
                    ? () {
                        controller.applySocket(controller.selectedSocketIndex, controller.selectedPlugHash);
                      }
                    : null,
                child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(16 * widget.pixelSize),
                    child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
                      definition.hash,
                      (def) => isEnabled
                          ? TranslatedTextWidget(
                              "Apply {modType}",
                              replace: {"modType": def.itemTypeDisplayName.toLowerCase()},
                              style: style,
                            )
                          : ShimmerHelper.getDefaultShimmer(context,
                              child: TranslatedTextWidget(
                                "Applying {modType}",
                                replace: {"modType": def.itemTypeDisplayName.toLowerCase()},
                                style: style,
                              )),
                    )))));
    if (requirementHash != null && requirementHash != 0) {
      return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(requirementHash, (def) {
        final materials = def?.materials?.where((element) => (element.count ?? 0) > 0);
        if (materials?.isNotEmpty ?? true) {
          return Container();
        }
        return applyButton;
      }, key: Key('apply_button_$requirementHash'));
    }
    return applyButton;
  }

  @override
  Widget buildEnergyCost(BuildContext context) {
    var cost = definition?.plug?.energyCost;
    if (cost != null) {
      final color = cost.energyType?.getColorLayer(context)?.layer2;
      var icon = cost.energyType == DestinyEnergyType.Any
          ? Container()
          : Icon(
              DestinyData.getEnergyTypeIcon(cost.energyType),
              color: color,
              size: 32 * widget.pixelSize,
            );
      var value = Container(
          padding: EdgeInsets.all(8 * widget.pixelSize),
          child: Text("${cost.energyCost}",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 50 * widget.pixelSize, color: color)));
      var description = TranslatedTextWidget(
        "Energy Cost",
        uppercase: true,
        style: TextStyle(fontWeight: FontWeight.w300, fontSize: widget.pixelSize * 26),
      );
      return Row(children: <Widget>[icon, value, description]);
    }
    return Container();
  }

  @override
  Widget buildStats(BuildContext context) {
    if (!shouldShowStats) return Container();
    return Column(children: [
      Divider(
        thickness: 1 * widget.pixelSize,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      ScreenShotSocketItemStatsWidget(
        plugDefinition: definition,
        definition: itemDefinition,
        item: item,
        pixelSize: widget.pixelSize,
        socketController: widget.controller,
      )
    ]);
  }

  Widget buildSandBoxPerks(BuildContext context) {
    if (sandboxPerkDefinitions == null) return Container();
    var perks = definition?.perks?.where((p) {
      if (p.perkVisibility != ItemPerkVisibility.Visible) return false;
      var def = sandboxPerkDefinitions[p.perkHash];
      if ((def?.isDisplayable ?? false) == false) return false;
      return true;
    });
    if ((perks?.length ?? 0) == 0) return Container();
    return Column(
      children: perks
          ?.map((p) => Container(
              padding: EdgeInsets.symmetric(
                vertical: 8 * widget.pixelSize,
              ),
              child: Row(
                key: Key("mod_perk_${p.perkHash}"),
                children: <Widget>[
                  Container(
                    height: 64 * widget.pixelSize,
                    width: 64 * widget.pixelSize,
                    child: ManifestImageWidget<DestinySandboxPerkDefinition>(p.perkHash),
                  ),
                  Container(
                    width: 16 * widget.pixelSize,
                  ),
                  Expanded(
                      child: ManifestText<DestinySandboxPerkDefinition>(
                    p.perkHash,
                    style: TextStyle(fontSize: 22 * widget.pixelSize, fontWeight: FontWeight.w300),
                    textExtractor: (def) => def.displayProperties?.description,
                  )),
                ],
              )))
          ?.toList(),
    );
  }
}
