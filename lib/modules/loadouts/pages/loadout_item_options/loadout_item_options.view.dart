import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/widgets/details_item_mods.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_perks.widget.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options.bottomsheet.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';

import 'loadout_item_options.bloc.dart';

class LoadoutItemOptionsView extends StatelessWidget {
  final LoadoutItemOptionsBloc bloc;
  final LoadoutItemOptionsBloc state;
  final SocketControllerBloc socketState;

  const LoadoutItemOptionsView({
    Key? key,
    required this.bloc,
    required this.state,
    required this.socketState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.mediaQuery.padding.copyWith(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildItemInfo(context),
                    buildPlugs(context),
                  ],
                )),
          ),
          buildOptions(context),
        ],
      ),
    );
  }

  Widget buildItemInfo(BuildContext context) {
    final item = state.item.inventoryItem;
    if (item == null) return Container();
    return Container(
      margin: EdgeInsets.all(8).copyWith(top: 0),
      height: InventoryItemWidgetDensity.High.itemHeight,
      child: HighDensityInventoryItem(item),
    );
  }

  Widget buildPlugs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...buildReusablePerks(context),
        ...buildSupers(context),
        ...buildAbilities(context),
        ...buildMods(context),
      ],
    );
  }

  List<Widget> buildReusablePerks(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Reusable) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemPerksWidget(e)).toList();
  }

  List<Widget> buildSupers(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Supers) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemPerksWidget(e)).toList();
  }

  List<Widget> buildAbilities(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Abilities) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemModsWidget(e)).toList();
  }

  List<Widget> buildMods(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Consumable) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemModsWidget(e)).toList();
  }

  Widget buildOptions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildOption(
            context,
            text: "Details".translate(context),
            option: LoadoutItemOption.ViewDetails,
          ),
          Container(
            height: 4,
          ),
          buildOption(
            context,
            text: "Mods".translate(context),
            option: LoadoutItemOption.EditMods,
          ),
          Container(
            height: 4,
          ),
          buildOption(
            context,
            text: "Remove".translate(context),
            option: LoadoutItemOption.Remove,
            color: context.theme.errorLayers,
          ),
        ],
      ),
    );
  }

  Widget buildOption(
    BuildContext context, {
    required String text,
    required LoadoutItemOption option,
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: () => bloc.selectOption(option),
      child: Text(text),
      style: ElevatedButton.styleFrom(backgroundColor: color),
    );
  }
}
