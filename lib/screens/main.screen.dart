import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_auth/bungie_auth.consumer.dart';
import 'package:little_light/core/providers/item_notes/item_notes.consumer.dart';
import 'package:little_light/core/providers/loadouts/loadouts.consumer.dart';
import 'package:little_light/core/providers/profile/profile.consumer.dart';
import 'package:little_light/core/providers/starting_page/starting_page.consumer.dart';
import 'package:little_light/core/providers/starting_page/starting_page_options.dart';
import 'package:little_light/core/providers/user_settings/user_settings.consumer.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/screens/equipment.screen.dart';
import 'package:little_light/screens/loadouts.screen.dart';
import 'package:little_light/screens/old_triumphs.screen.dart';
import 'package:little_light/screens/progress.screen.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/side_menu/side_menu.widget.dart';
import 'package:wakelock/wakelock.dart';

class MainScreen extends ConsumerStatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen>
    with
        WidgetsBindingObserver,
        UserSettingsConsumerState,
        LoadoutsConsumerState,
        ItemNotesConsumerState,
        BungieAuthConsumerState,
        ProfileConsumerState,
        StartingPageConsumerState {
  Widget currentScreen;

  @override
  void initState() {
    super.initState();
    initUpdaters();
    getInitScreen();
  }

  initUpdaters() {
    if (auth.isLogged) {
      auth.getMembershipData();
      loadoutsService.getLoadouts(forceFetch: true);
      itemNotesService.getNotes(forceFetch: true);
      profile.startAutomaticUpdater();
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await profile.fetchProfileData();
        profile.pauseAutomaticUpdater = false;
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        profile.pauseAutomaticUpdater = true;
        break;
    }
    print("state changed: $state");
  }

  getInitScreen() async {
    StartingPageOptions screen = await startingPage.getLatestScreen();
    switch (screen) {
      case StartingPageOptions.Equipment:
        currentScreen = EquipmentScreen();
        break;

      case StartingPageOptions.Progress:
        currentScreen = ProgressScreen();
        break;

      case StartingPageOptions.Collections:
        currentScreen = CollectionsScreen();
        break;

      case StartingPageOptions.Triumphs:
        currentScreen = OldTriumphsScreen();
        break;

      case StartingPageOptions.Loadouts:
        currentScreen = LoadoutsScreen();
        break;
      
      case StartingPageOptions.DuplicatedItems:
        break;
      case StartingPageOptions.Search:
        break;
    }

    setState(() {});
    bool keepAwake = userSettings.keepAwake;

    if (PlatformCapabilities.keepScreenOnAvailable) {
      Wakelock.toggle(enable:keepAwake);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentScreen == null) return Container();
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: Scaffold(
          drawer: Container(
            child: SideMenuWidget(
              onPageChange: (page) {
                this.currentScreen = page;
                setState(() {});
              },
            ),
          ),
          body: currentScreen,
          resizeToAvoidBottomInset: false,
          // resizeToAvoidBottomPadding: false,
        ));
  }

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: TranslatedTextWidget('Exit'),
            content: TranslatedTextWidget(
                'Do you really want to exit Little Light?'),
            actions: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: TranslatedTextWidget('No'),
              ),
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: TranslatedTextWidget('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
