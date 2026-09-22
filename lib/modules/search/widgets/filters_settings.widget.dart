import 'package:flutter/material.dart';
import 'package:little_light/modules/settings/widgets/switch_option.widget.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:provider/provider.dart';

class FiltersSettingsWidget extends StatelessWidget {
  final EdgeInsets? padding;

  const FiltersSettingsWidget({Key? key, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userSettings = context.watch<UserSettingsBloc>();
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.all(4),
            child: HeaderWidget(child: Text("Filter Settings".translate(context).toUpperCase())),
          ),
          SwitchOptionWidget(
            "tap to exclude".translate(context).toUpperCase(),
            "Use tap instead of long press to exclude items.".translate(context),
            value: userSettings.filterTapToExclude,
            onChanged: (value) => userSettings.filterTapToExclude = value,
          ),
          Container(
            margin: EdgeInsets.all(4),
            child: HeaderWidget(child: Text("Text Filter Search Items".translate(context).toUpperCase())),
          ),
          MenuBox(
            //backgroundColor: getBackgroundColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                buildTextFilterItem(
                  context,
                  "Wishlist Notes",
                  userSettings.textFilterWishlistNotes,
                  (value) => userSettings.textFilterWishlistNotes = value,
                ),
                buildTextFilterItem(
                  context,
                  "Loadout Name",
                  userSettings.textFilterLoadoutName,
                  (value) => userSettings.textFilterLoadoutName = value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFilterItem(BuildContext context, String name, bool value, void Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer1,
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: Text(name.translate(context).toUpperCase(), style: context.textTheme.button)),
          LLSwitch.callback(value, onChanged),
        ],
      ),
    );
  }
}
