import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/modules/settings/pages/settings/settings.bloc.dart';
import 'package:little_light/modules/settings/widgets/item_order_parameter.widget.dart';
import 'package:little_light/modules/settings/widgets/settings_option.widget.dart';
import 'package:little_light/modules/settings/widgets/switch_option.widget.dart';
import 'package:little_light/modules/settings/widgets/wishlist_file_item.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

class SettingsView extends StatelessWidget {
  final SettingsBloc _bloc;
  final SettingsBloc _state;
  const SettingsView(this._bloc, this._state, {Key? key}) : super(key: key);

  // List<ItemSortParameter> itemOrdering;
  // List<ItemSortParameter> pursuitOrdering;
  // Set<String> priorityTags;
  // List<WishlistFile> wishlists;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings".translate(context)),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              SwitchOptionWidget(
                "Tap to select".translate(context).toUpperCase(),
                "Tapping on items will select them for quick transfer and equip instead of opening details. Hold for details."
                    .translate(context),
                value: _state.tapToSelect,
                onChanged: (value) => _bloc.tapToSelect = value,
              ),
              if (_state.canKeepAwake)
                SwitchOptionWidget(
                  "Keep Awake".translate(context).toUpperCase(),
                  "Keep device awake while the app is open.".translate(context),
                  value: _state.keepAwake,
                  onChanged: (value) => _bloc.keepAwake = value,
                ),
              SwitchOptionWidget(
                "Auto open Keyboard".translate(context).toUpperCase(),
                "Open keyboard automatically in quick search.".translate(context),
                value: _state.autoOpenKeyboard,
                onChanged: (value) => _bloc.autoOpenKeyboard = value,
              ),
              SwitchOptionWidget(
                "Enable auto transfers".translate(context).toUpperCase(),
                "If enabled, Little Light will try to move items out of the way to make room for new transfers."
                    .translate(context),
                value: _state.enabledAutoTransfers,
                onChanged: (value) => _bloc.enabledAutoTransfers = value,
              ),
              SettingsOptionWidget(
                "Default free slots".translate(context).toUpperCase(),
                Column(children: [
                  Slider(
                    min: 0,
                    max: 9,
                    value: _state.defaultFreeSlots.toDouble(),
                    onChanged: (value) => _bloc.defaultFreeSlots = value.floor(),
                    onChangeEnd: (value) => _bloc.saveDefaultFreeSlots(),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                      "This is the default count of slots that should be empty after you equip or transfer a loadout, not considering the pieces in the loadout itself."
                          .translate(context))
                ]),
                trailing: Text("${_state.defaultFreeSlots}"),
              ),
              SettingsOptionWidget(
                "Wishlists".translate(context).toUpperCase(),
                Column(children: [
                  Text(
                      "You can add community curated wishlists (or your custom ones) on Little Light to check your rolls."
                          .translate(context)),
                ]),
                trailing: ElevatedButton(
                  child: Text("Add Wishlist".translate(context)),
                  onPressed: () => _bloc.addWishlist(),
                  style: ButtonStyle(visualDensity: VisualDensity.compact),
                ),
              ),
              buildWishlistsList(context),
              SettingsOptionWidget(
                "Order characters by".translate(context).toUpperCase(),
                buildCharacterOrdering(context),
              ),
              SettingsOptionWidget(
                "Order items by".translate(context).toUpperCase(),
                buildItemOrderList(context),
              ),
              SettingsOptionWidget(
                "Order pursuits by".translate(context).toUpperCase(),
                buildPursuitOrderList(context),
              ),
              SettingsOptionWidget(
                "Priority Tags".translate(context).toUpperCase(),
                buildPriorityTags(context),
              ),
              Container(height: 32),
            ])));
  }

  Widget buildWishlistsList(BuildContext context) {
    final wishlists = _bloc.wishlists;
    if (wishlists == null) return Container(height: 80, child: LoadingAnimWidget());
    return Container(
        padding: EdgeInsets.all(4).copyWith(top: 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: wishlists
                .map((w) => WishlistFileItem(
                      file: w,
                      onRemove: () => _bloc.removeWishlist(w),
                      isAdded: true,
                    ))
                .toList()));
  }

  Widget buildCharacterOrdering(BuildContext context) {
    return Container(
        child: IntrinsicHeight(
            child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildCharacterOrderItem(
          context,
          "Last played".translate(context),
          CharacterSortParameterType.LastPlayed,
        ),
        Container(
          width: 4,
        ),
        buildCharacterOrderItem(
          context,
          "First created".translate(context),
          CharacterSortParameterType.FirstCreated,
        ),
        Container(
          width: 4,
        ),
        buildCharacterOrderItem(
          context,
          "Last created".translate(context),
          CharacterSortParameterType.LastCreated,
        ),
      ],
    )));
  }

  Widget buildCharacterOrderItem(BuildContext context, String label, CharacterSortParameterType type) {
    var selected = type == _state.characterOrderingType;
    return Expanded(
      child: Material(
        borderRadius: BorderRadius.circular(4),
        color: selected ? context.theme.primaryLayers : context.theme.surfaceLayers.layer1,
        child: InkWell(
          child: Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              label,
              style: context.textTheme.button,
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            _bloc.characterOrderingType = type;
          },
        ),
      ),
    );
  }

  Widget buildItemOrderList(BuildContext context) {
    final itemOrdering = _state.itemOrdering;
    if (itemOrdering == null) return Container();
    return ReorderableList(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final parameter = itemOrdering[index];
        return ItemOrderParameterWidget(
          parameter,
          index,
          key: Key("param $index ${parameter.type}"),
          onChangeDirection: (direction) => _bloc.updateItemOrderingDirection(parameter, direction),
          onToggle: (active) => _bloc.updateItemOrderingActive(parameter, active),
        );
      },
      itemCount: itemOrdering.length,
      onReorder: (o, n) => _bloc.reorderItemOrdering(o, n),
    );
  }

  Widget buildPursuitOrderList(BuildContext context) {
    final pursuitOrdering = _state.pursuitOrdering;
    if (pursuitOrdering == null) return Container();
    return ReorderableList(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final parameter = pursuitOrdering[index];
        return ItemOrderParameterWidget(
          parameter,
          index,
          key: Key("param $index ${parameter.type}"),
          onChangeDirection: (direction) => _bloc.updatePursuitOrderingDirection(parameter, direction),
          onToggle: (active) => _bloc.updatePursuitOrderingActive(parameter, active),
        );
      },
      itemCount: pursuitOrdering.length,
      onReorder: (o, n) => _bloc.reorderPursuitOrdering(o, n),
    );
  }

  Widget buildPriorityTags(BuildContext context) {
    final tags = _state.priorityTags ?? [];
    return Container(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: tags
                .map(
                  (t) => TagPillWidget.fromTag(t, onRemove: () => _bloc.removePriorityTag(t)),
                )
                .toList() +
            [
              TagPillWidget(
                icon: FontAwesomeIcons.circlePlus,
                tagName: "Add Tag".translate(context),
                background: context.theme.primaryLayers.layer0,
                foreground: context.theme.onSurfaceLayers.layer0,
                onTap: () => _bloc.addPriorityTag(),
              ),
            ],
      ),
    );

    ///TODO: redo this
    // child: Wrap(
    //   crossAxisAlignment: WrapCrossAlignment.start,
    //   runSpacing: 4,
    //   spacing: 4,
    //   children: tags
    //       .map((t) => ItemTagWidget.fromNoteTag(
    //             context,
    //             t,
    //             onClick: () {
    //               userSettings.removePriorityTag(t);
    //               setState(() {});
    //             },
    //           ))
    //       .followedBy([
    //     ItemTagWidget.fromNoteTag(context, ItemNotesTag(icon: null, name: "Add Tag", backgroundColorHex: "#03A9f4"),
    //         padding: 4,
    //         trailing: const CenterIconWorkaround(FontAwesomeIcons.plusCircle, size: 18),
    //         onClick: () => openAddTagDialog(context)),
    //   ]).toList(),
    // ));
  }
}
