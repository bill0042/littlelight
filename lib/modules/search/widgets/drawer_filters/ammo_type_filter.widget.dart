import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import '../../blocs/filter_options/ammo_type_filter_options.dart';
import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class AmmoTypeFilterWidget extends BaseDrawerFilterWidget<AmmoTypeFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Ammo Type".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, AmmoTypeFilterOptions data) {
    final availableValues = data.availableValues;
    if (availableValues.length <= 1) return Container();
    final validValues = [
      DestinyAmmunitionType.Primary,
      DestinyAmmunitionType.Special,
      DestinyAmmunitionType.Heavy,
    ].where((e) => availableValues.contains(e));
    final hasNone = availableValues.contains(DestinyAmmunitionType.None);
    final include = data.include;
    final exclude = data.exclude;
    return Column(
      children: [
        Row(
          children: validValues
              .map(
                (type) => Expanded(
                  child: FilterButtonWidget(
                    buildIcon(context, type),
                    selected: include.contains(type),
                    excluded: exclude.contains(type),
                    onTap: () => updateDiscreteOption(context, data, type, false),
                    onLongPress: () => updateDiscreteOption(context, data, type, true),
                  ),
                ),
              )
              .toList(),
        ),
        if (hasNone)
          FilterButtonWidget(
            Text("None".translate(context).toUpperCase()),
            selected: include.contains(DestinyAmmunitionType.None),
            excluded: exclude.contains(DestinyAmmunitionType.None),
            onTap: () => updateDiscreteOption(context, data, DestinyAmmunitionType.None, false),
            onLongPress: () => updateDiscreteOption(context, data, DestinyAmmunitionType.None, true),
          ),
      ],
    );
  }

  Widget buildIcon(BuildContext context, DestinyAmmunitionType type) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Icon(
        type.icon,
        color: type.color,
      ),
    );
  }
}
