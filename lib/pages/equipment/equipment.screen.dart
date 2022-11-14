// @dart=2.9

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/blocs/profile/profile_component_groups.dart';
import 'package:little_light/pages/item_search/search.screen.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/utils/item_filters/pseudo_item_type_filter.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/animated_character_background.widget.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/flutter/passive_tab_bar_view.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/large_screen_equipment_list.widget.dart';
import 'package:little_light/widgets/inventory_tabs/large_screen_vault_list.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_item_type_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab_header.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';

class EquipmentScreen extends StatefulWidget {
  final List<int> itemTypes = [DestinyItemCategory.Weapon, DestinyItemCategory.Armor, DestinyItemCategory.Inventory];

  @override
  EquipmentScreenState createState() => EquipmentScreenState();
}

const _page = LittleLightPersistentPage.Equipment;

class EquipmentScreenState extends State<EquipmentScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        UserSettingsConsumer,
        AnalyticsConsumer,
        ProfileConsumer {
  int currentGroup = DestinyItemCategory.Weapon;

  TabController _charTabController;
  TabController get charTabController {
    final totalCharacterTabs = (characters?.length ?? 0) + 1;
    final current = _charTabController;
    if (current != null && current?.length == totalCharacterTabs) return current;
    _charTabController = TabController(length: totalCharacterTabs, vsync: this, initialIndex: current?.index ?? 0);
    return _charTabController;
  }

  TabController _typeTabController;
  TabController get typeTabController {
    final current = _typeTabController;
    final length = widget.itemTypes.length;
    if (current != null && current?.length == length) return current;
    _typeTabController = TabController(
      initialIndex: current?.index ?? 0,
      length: length,
      vsync: this,
    );
    return _typeTabController;
  }

  @override
  void initState() {
    super.initState();
    profile.updateComponents = ProfileComponentGroups.basicProfile;
    userSettings.startingPage = _page;
    analytics.registerPageOpen(_page);

    profile.addListener(update);
  }

  void update() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    profile.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var query = MediaQueryHelper(context);
    if (query.isLandscape || query.tabletOrBigger) {
      return buildTablet(context);
    }

    return buildPhone(context);
  }

  Widget buildTablet(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          Positioned(top: 0, left: 0, right: 0, bottom: 0, child: buildTabletCharacterTabView(context)),
          Positioned(
            top: screenPadding.top,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              enableFeedback: false,
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight - 52,
              right: 8,
              child: buildCharacterMenu(context)),
          InventoryNotificationWidget(
              notificationMargin: EdgeInsets.only(right: 44), barHeight: 0, key: Key('inventory_notification_widget')),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(18)),
              width: 36,
              height: 36,
              child: RefreshButtonWidget(),
            ),
          ),
          Positioned(bottom: screenPadding.bottom, left: 0, right: 0, child: SelectedItemsWidget()),
        ],
      ),
    );
  }

  Widget buildPhone(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    var topOffset = screenPadding.top + kToolbarHeight;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          Column(
            children: [
              SizedBox(height: topOffset),
              Expanded(
                child: Stack(
                  children: [
                    buildItemTypeTabBarView(context),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: NotificationsWidget(),
                      ),
                    )
                  ],
                  fit: StackFit.expand,
                ),
              ),
              ItemTypeMenuWidget(widget.itemTypes, controller: typeTabController),
              SelectedItemsWidget(),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topOffset + 16,
            child: buildCharacterHeaderTabView(context),
          ),
          Positioned(
            top: screenPadding.top,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              enableFeedback: false,
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight - 52,
              right: 8,
              child: buildCharacterMenu(context)),
          // NotificationsWidget(),
        ],
      ),
    );
  }

  Widget buildCharacterHeaderTabView(BuildContext context) {
    final headers = characters
            ?.map((character) => TabHeaderWidget(
                  character,
                  key: Key("${character.character?.emblemHash}_${character?.characterId}"),
                ))
            ?.toList() ??
        <Widget>[];
    headers?.add(VaultTabHeaderWidget());

    return TabBarView(controller: charTabController, children: headers);
  }

  Widget buildTabletCharacterTabView(BuildContext context) {
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    var topOffset = screenPadding.top + kToolbarHeight;
    var pages = characters
        ?.map((character) => Stack(children: [
              Positioned.fill(
                  child: LargeScreenEquipmentListWidget(
                key: Key("character_tab${character.characterId}"),
                character: character.character,
              )),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: topOffset + 16,
                  child: TabHeaderWidget(
                    character,
                    key: Key("${character.character.emblemHash}"),
                  ))
            ]))
        ?.toList();
    pages?.add(Stack(children: [
      Positioned.fill(
          child: LargeScreenVaultListWidget(
        key: Key("vault_tab"),
      )),
      Positioned(top: 0, left: 0, right: 0, height: topOffset + 16, child: VaultTabHeaderWidget())
    ]));
    return TabBarView(controller: charTabController, children: pages ?? []);
  }

  Widget buildBackground(BuildContext context) {
    if (characters == null) return Container();
    return AnimatedCharacterBackgroundWidget(
      tabController: charTabController,
    );
  }

  Widget buildItemTypeTabBarView(BuildContext context) {
    if (characters == null) return Container();
    return TabBarView(controller: typeTabController, children: buildItemTypeTabs(context));
  }

  List<Widget> buildItemTypeTabs(BuildContext context) {
    return widget.itemTypes.map((type) => buildCharacterTabBarView(context, type)).toList();
  }

  Widget buildCharacterTabBarView(BuildContext context, int group) {
    if (characters == null) return Container();
    return PassiveTabBarView(
        physics: NeverScrollableScrollPhysics(), controller: charTabController, children: buildCharacterTabs(group));
  }

  List<Widget> buildCharacterTabs(int group) {
    List<Widget> characterTabs = characters?.map((character) {
      return CharacterTabWidget(
        character.character,
        group,
        key: Key("character_tab_${character.characterId}"),
        padding: EdgeInsets.all(4),
      );
    })?.toList();
    characterTabs?.add(VaultTabWidget(group));
    return characterTabs ?? [];
  }

  List<DestinyCharacterInfo> get characters {
    return profile.characters;
  }

  buildCharacterMenu(BuildContext context) {
    if (characters == null) return Container();
    return Row(children: [
      IconButton(
          enableFeedback: false,
          icon: Icon(FontAwesomeIcons.search, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Iterable<PseudoItemType> available = [
              PseudoItemType.Weapons,
              PseudoItemType.Armor,
              PseudoItemType.Cosmetics,
              PseudoItemType.Consumables
            ];
            Iterable<PseudoItemType> selected = [
              PseudoItemType.Weapons,
              PseudoItemType.Armor,
              PseudoItemType.Cosmetics,
              PseudoItemType.Consumables
            ];
            if (typeTabController?.index == 0) {
              selected = [PseudoItemType.Weapons];
            }
            if (typeTabController?.index == 1) {
              selected = [PseudoItemType.Armor];
            }
            if (typeTabController?.index == 2) {
              selected = [PseudoItemType.Cosmetics, PseudoItemType.Consumables];
            }
            var query = MediaQueryHelper(context);
            if (query.isLandscape) {
              selected = [PseudoItemType.Weapons, PseudoItemType.Armor, PseudoItemType.Cosmetics];
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  controller: SearchController.withDefaultFilters(
                    context,
                    firstRunFilters: [PseudoItemTypeFilter(available, available)],
                    preFilters: [
                      PseudoItemTypeFilter(available, selected),
                    ],
                  ),
                ),
              ),
            );
          }),
      TabsCharacterMenuWidget(characters, controller: charTabController)
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
