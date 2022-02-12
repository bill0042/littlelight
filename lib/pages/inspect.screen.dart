// @dart=2.9

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';

class InspectScreen extends StatefulWidget {
  final String membershipId;
  final int membershipType;

  InspectScreen(this.membershipId, this.membershipType, {Key key}) : super(key: key);

  @override
  InspectScreenState createState() => InspectScreenState();
}

class InspectScreenState extends State<InspectScreen>
    with TickerProviderStateMixin, UserSettingsConsumer, ProfileConsumer {
  TabController charTabController;
  TabController typeTabController;

  get totalCharacterTabs => characters?.length != null ? characters.length : 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (characters == null) {
      return buildLoading(context);
    }
    charTabController = charTabController ??
        TabController(
          initialIndex: 0,
          length: totalCharacterTabs,
          vsync: this,
        );
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          buildCharacterTabController(context, charTabController),
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
          TabsCharacterMenuWidget(characters, controller: charTabController),
          InventoryNotificationWidget(key: Key('inventory_notification_widget')),
          Positioned(bottom: screenPadding.bottom, left: 0, right: 0, child: SelectedItemsWidget()),
        ],
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 80, 90, 100),
        Color.fromARGB(255, 100, 100, 115),
        Color.fromARGB(255, 32, 32, 73),
      ],
      begin: FractionalOffset(0, .5),
      end: FractionalOffset(.5, 0),
    )));
  }

  Widget buildCharacterTabController(BuildContext context, TabController controller) {
    return TabBarView(controller: controller, children: getTabs());
  }

  List<Widget> getTabs() {
    List<Widget> characterTabs = characters.map((character) {
      return Container();
    }).toList();
    return characterTabs;
  }

  List<DestinyCharacterComponent> get characters {
    return profile.getCharacters(userSettings.characterOrdering);
  }

  Widget buildLoading(BuildContext context) {
    return LoadingAnimWidget();
  }
}