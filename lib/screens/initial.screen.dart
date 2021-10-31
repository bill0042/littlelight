import 'dart:io';

import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/core/providers/bungie_api/exceptions/bungie_api.exception.dart';
import 'package:little_light/core/providers/bungie_auth/bungie_auth.consumer.dart';
import 'package:little_light/core/providers/destiny_settings/destiny_settings.consumer.dart';
import 'package:little_light/core/providers/env/env.consumer.dart';
import 'package:little_light/core/providers/littlelight_api/littlelight_api.consumer.dart';
import 'package:little_light/core/providers/loadouts/loadouts.consumer.dart';
import 'package:little_light/core/providers/manifest/manifest.consumer.dart';
import 'package:little_light/core/providers/objective_tracking/objective_tracking.consumer.dart';
import 'package:little_light/core/providers/user_settings/user_settings.consumer.dart';
import 'package:little_light/core/providers/wishlists/wishlists.consumer.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/screens/main.screen.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/exceptions/exception_dialog.dart';
import 'package:little_light/widgets/initial_page/download_manifest.widget.dart';
import 'package:little_light/widgets/initial_page/login_widget.dart';
import 'package:little_light/widgets/initial_page/select_language.widget.dart';
import 'package:little_light/widgets/initial_page/select_platform.widget.dart';
import 'package:little_light/widgets/layouts/floating_content_layout.dart';

class InitialScreen extends ConsumerStatefulWidget {
  final ProfileService profile = ProfileService();
  final String authCode;

  InitialScreen({Key key, this.authCode}) : super(key: key);

  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends FloatingContentState<InitialScreen>
    with
        EnvConsumerState,
        WishlistsConsumerState,
        UserSettingsConsumerState,
        LoadoutsConsumerState,
        ObjectiveTrackingConsumerState,
        LittleLightApiConsumerState,
        BungieApiConsumer,
        BungieAuthConsumerState,
        ManifestConsumerState,
        DestinySettingsConsumerState {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark));

    initLoading();
  }

  initLoading() async {
    await dotEnv.load(fileName: 'assets/_env');
    await StorageService.init();
    auth.reset();
    await littleLightApi.reset();
    await loadoutsService.reset();
    await objectiveTracking.reset();
    await manifest.reset();
    if (authCode != null) {
      authCode(widget.authCode);
      return;
    }
    checkLanguage();
  }

  Future checkLanguage() async {
    String selectedLanguage = StorageService.getLanguage();
    bool hasSelectedLanguage = selectedLanguage != null;
    if (hasSelectedLanguage) {
      checkManifest();
    } else {
      showSelectLanguage();
    }
  }

  showSelectLanguage() async {
    List<String> availableLanguages = await manifest.getAvailableLanguages();
    SelectLanguageWidget childWidget = SelectLanguageWidget(
      availableLanguages: availableLanguages,
      onChange: (language) {
        changeTitleLanguage(language);
      },
      onSelect: (language) {
        this.checkManifest();
      },
    );
    this.changeContent(childWidget, childWidget.title);
  }

  checkManifest() async {
    try {
      bool needsUpdate = await manifest.needsUpdate();
      if (needsUpdate) {
        showDownloadManifest();
      } else {
        checkLogin();
      }
    } catch (e) {
      print(e);
      this.changeContent(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                child: TranslatedTextWidget(
                    "Can't connect to Bungie servers. Please check your internet connection and try again."),
              ),
              ElevatedButton(
                onPressed: () {
                  changeContent(null, "");
                  checkManifest();
                },
                child: TranslatedTextWidget("Try Again"),
              ),
              ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).errorColor),
                child: TranslatedTextWidget("Exit"),
              )
            ],
          ),
          "Error");
    }
  }

  showDownloadManifest() async {
    String language = StorageService.getLanguage();
    DownloadManifestWidget screen = DownloadManifestWidget(
      selectedLanguage: language,
      onFinish: () {
        checkLogin();
      },
    );
    this.changeContent(screen, screen.title);
  }

  checkLogin() async {
    BungieNetToken token;
    try {
      token = await auth.getToken();
    } on BungieApiException catch (e) {
      bool needsLogin = [
            PlatformErrorCodes.DestinyAccountNotFound,
            PlatformErrorCodes.WebAuthRequired,
            PlatformErrorCodes.AccessTokenHasExpired,
            PlatformErrorCodes.AuthorizationRecordExpired,
          ].contains(e.errorCode) ||
          ["invalid_grant", "authorizationrecordexpired"]
              .contains(e.errorStatus?.toLowerCase());
      if (needsLogin) {
        showLogin(false);
        return;
      }
      throw e;
    }

    if (token != null) {
      checkMembership();
      return;
    }

    var authCode = await auth.checkAuthorizationCode();
    if (authCode != null) {
      this.authCode(authCode);
      return;
    }

    if (token == null) {
      showLogin();
    } else {
      checkMembership();
    }
  }

  showLogin([bool forceReauth = true]) {
    LoginWidget loginWidget = LoginWidget(
      onSkip: () {
        goForward();
      },
      onLogin: (code) {
        authCode(code);
      },
      forceReauth: forceReauth,
    );
    this.changeContent(loginWidget, loginWidget.title);
  }

  authCode(String code) async {
    this.changeContent(null, "");
    try {
      await auth.requestToken(code);
      checkMembership();
    } catch (e, stackTrace) {
      showDialog(
          context: context,
          builder: (context) => ExceptionDialog(
                context,
                e,
                onDismiss: (label) {
                  if (label == "Login") {
                    showLogin();
                  }
                },
              ));
      ExceptionHandler(onRestart: () {
        this.showLogin(false);
      }).handleException(e, stackTrace);
    }
  }

  checkMembership() async {
    GroupUserInfoCard membership = await auth.getMembership();
    if (membership == null) {
      return showSelectMembership();
    }
    ExceptionHandler.setReportingUserInfo(membership.membershipId,
        membership.displayName, membership.membershipType);
    return loadProfile();
  }

  showSelectMembership() async {
    this.changeContent(null, null);
    UserMembershipData membershipData = await bungieApi.getMemberships();

    if (membershipData?.destinyMemberships?.length == 1) {
      await this.auth.saveMembership(
          membershipData, membershipData?.destinyMemberships[0].membershipId);
      await loadProfile();
      return;
    }

    SelectPlatformWidget widget = SelectPlatformWidget(
        membershipData: membershipData,
        onSelect: (String membershipId) async {
          if (membershipId == null) {
            this.showLogin();
            return;
          }
          await this.auth.saveMembership(membershipData, membershipId);
          await loadProfile();
        });
    this.changeContent(widget, widget.title);
  }

  loadProfile() async {
    this.changeContent(null, null);
    await widget.profile.loadFromCache();
    this.goForward();
  }

  goForward() async {
    await userSettings.init();
    try {
      await destinySettings.init();
    } catch (e) {}
    await wishlistsService.init();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
  }
}
