import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/collections/pages/home/collections_home.page.dart';
import 'package:little_light/modules/dev_tools/pages/main/dev_tools_main.page.dart';
import 'package:little_light/modules/equipment/pages/equipment/equipment.page.dart';
import 'package:little_light/modules/loadouts/pages/home/loadouts_home.page.dart';
import 'package:little_light/modules/progress/pages/objectives/objectives.page.dart';
import 'package:little_light/modules/progress/pages/progress/progress.page.dart';
import 'package:little_light/modules/settings/pages/about/about.screen.dart';
import 'package:little_light/modules/triumphs/pages/home/triumphs_home.page.dart';
import 'package:little_light/modules/duplicated_items/pages/duplicated_items/duplicated_items.page.dart';
import 'package:little_light/pages/languages/languages.page_route.dart';
import 'package:little_light/modules/vendors/pages/home/vendors_home.page.dart';
import 'package:little_light/pages/main.screen.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/side_menu/profile_info.widget.dart';
import 'package:little_light/widgets/side_menu/side_menu_settings.widget.dart';

typedef OnPageChange = void Function(Widget screen);

class SideMenuWidget extends StatefulWidget {
  final OnPageChange? onPageChange;

  const SideMenuWidget({Key? key, this.onPageChange}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SideMenuWidgetState();
  }
}

class SideMenuWidgetState extends State<SideMenuWidget> with AuthConsumer {
  List<UserMembershipData>? memberships;

  @override
  void initState() {
    super.initState();
    fetchMemberships();
  }

  fetchMemberships() async {
    final accountIDs = auth.accountIDs;
    if (accountIDs == null) return;
    final _accounts = await Future.wait(accountIDs.map((a) => auth.getMembershipDataForAccount(a)));
    if (!mounted) return;
    setState(() {
      memberships = _accounts.whereType<UserMembershipData>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: context.theme.surfaceLayers.layer1,
        width: 280,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.max, children: [
          Expanded(
              child: ListView(
            padding: const EdgeInsets.all(0),
            children: <Widget>[
              profileInfo(context),
              menuItem(context, Text("Equipment".translate(context)), onTap: () {
                open(context, const EquipmentPage());
              }),
              menuItem(context, Text("Progress".translate(context)), onTap: () {
                open(context, ProgressPage());
              }),
              menuItem(context, Text("Objectives".translate(context)), onTap: () {
                open(context, ObjectivesPage());
              }),
              menuItem(context, Text("Loadouts".translate(context)), onTap: () {
                open(context, LoadoutsHomePage());
              }),
              menuItem(context, Text("Vendors".translate(context)), onTap: () {
                open(context, VendorsHomePage());
              }),
              menuItem(context, Text("Collections".translate(context)), onTap: () {
                open(context, CollectionsHomePage());
              }),
              menuItem(context, Text("Triumphs".translate(context)), onTap: () {
                open(context, TriumphsHomePage());
              }),
              menuItem(context, Text("Duplicated Items".translate(context)), onTap: () {
                open(context, DuplicatedItemsPage());
              }),
              menuItem(context, Text("About".translate(context)), onTap: () {
                open(context, AboutScreen());
              }),
              if (kDebugMode)
                menuItem(context, Text("Dev Tools".translate(context)), onTap: () {
                  open(context, DevToolsPage());
                }),
              Container(height: MediaQuery.of(context).viewPadding.bottom)
            ],
          )),
        ]));
  }

  Widget profileInfo(BuildContext context) {
    return const ProfileInfoWidget(menuContent: SideMenuSettingsWidget());
  }

  Widget membershipButton(BuildContext context, GeneralUser bungieNetUser, GroupUserInfoCard membership) {
    var plat = PlatformData.getPlatform(membership.membershipType ?? BungieMembershipType.ProtectedInvalidEnumValue);
    return Container(
        color: context.theme.secondarySurfaceLayers.layer1,
        padding: const EdgeInsets.all(8).copyWith(bottom: 0),
        child: Material(
            color: plat.color,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
                onTap: () {
                  auth.setCurrentMembershipID(membership.membershipId, bungieNetUser.membershipId);
                  Phoenix.rebirth(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerRight,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      membership.displayName ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(width: 4),
                    Icon(plat.icon)
                  ]),
                ))));
  }

  Widget menuItem(BuildContext context, Widget label, {VoidCallback? onTap}) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onTap,
            child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(color: context.theme.surfaceLayers.layer2))),
                child: label)));
  }

  void open(BuildContext context, Widget screen) {
    MainScreenScaffoldGlobalKey.currentState?.closeDrawer();
    widget.onPageChange?.call(screen);
  }

  void pushRoute(BuildContext context, MaterialPageRoute route) {
    MainScreenScaffoldGlobalKey.currentState?.closeDrawer();
    Navigator.of(context).push(route);
  }

  void addAccount(BuildContext context) async {
    auth.openBungieLogin(true);
  }

  void changeLanguage(BuildContext context) {
    pushRoute(context, LanguagesPageRoute());
  }
}
