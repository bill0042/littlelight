import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/pages/initial/errors/authorization_failed.error.dart';
import 'package:little_light/pages/initial/errors/manifest_download.error.dart';
import 'package:little_light/pages/initial/errors/invalid_membership.error.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StartupErrorSubPage extends StatefulWidget {
  StartupErrorSubPage();

  @override
  StartupErrorSubPageState createState() => StartupErrorSubPageState();
}

class StartupErrorSubPageState extends SubpageBaseState<StartupErrorSubPage> with AuthConsumer {
  InitialPageStateNotifier get controller => context.read<InitialPageStateNotifier>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildTitle(BuildContext context) {
    if (controller.error is ManifestDownloadError) {
      return manifestDownloadErrorTitle;
    }
    if (controller.error is AuthorizationFailedError) {
      return authorizationErrorTitle;
    }
    return genericErrorTitle;
  }

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(children: [buildDescription(context), buildOptions(context)]));

  Widget buildDescription(BuildContext context) {
    if (controller.error is ManifestDownloadError) {
      return buildMultilineDescription([manifestDownloadErrorMessage, manifestDownloadErrorInstruction]);
    }
    if (controller.error is AuthorizationFailedError) {
      return buildMultilineDescription([authorizationErrorMessage, authorizationErrorInstructions]);
    }
    if (controller.error is InvalidMembershipError) {
      return buildMultilineDescription([invalidMembershipErrorMessage, invalidMembershipErrorInstruction]);
    }
    return buildMultilineDescription([unexpectedErrorMessage, clearAndRestartInstructions]);
  }

  Widget buildOptions(BuildContext context) {
    if (controller.error is ManifestDownloadError) {
      return buildMultiButtonOptions(
          [retryManifestDownloadOption, checkBungieNetTwitterOption, clearDataAndRestartOption]);
    }
    if (controller.error is AuthorizationFailedError) {
      return buildMultiButtonOptions(
          [openBungieLoginOption, checkBungieNetTwitterOption, checkLittleLightD2TwitterOption]);
    }
    if (controller.error is InvalidMembershipError) {
      return buildMultiButtonOptions([logoutOption]);
    }
    return buildMultiButtonOptions([restartOption, clearDataAndRestartOption]);
  }

  Widget buildMultilineDescription(List<Widget> lines) => Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: lines),
        padding: EdgeInsets.all(8),
      );

  Widget buildMultiButtonOptions(List<Widget> buttons) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons));

  /// Title options
  Widget get genericErrorTitle => Text("Unexpected error".translate(context));
  Widget get authorizationErrorTitle => Text("Authorization error".translate(context));
  Widget get manifestDownloadErrorTitle => Text("Error downloading Database".translate(context));

  /// Description parts
  Widget get unexpectedErrorMessage => TranslatedTextWidget(
        "There was an unexpected error starting Little Light.",
        textAlign: TextAlign.center,
      );
  Widget get clearAndRestartInstructions => TranslatedTextWidget(
        "Please try to restart the app, and if that doesn't solve the issue, clear data and restart.",
        textAlign: TextAlign.center,
      );

  Widget get authorizationErrorMessage => TranslatedTextWidget(
        "There was an error while authorizing your account with Bungie's servers.",
        textAlign: TextAlign.center,
      );

  Widget get authorizationErrorInstructions => TranslatedTextWidget(
        "Please try to login again. If this keeps happening, check if there's any ongoing maintenance on Bungie's server through @BungieHelp or @LittleLightD2 twitter.",
        textAlign: TextAlign.center,
      );

  Widget get manifestDownloadErrorMessage => TranslatedTextWidget(
        "There was an error while downloading Destiny 2 database from Bungie's servers.",
        textAlign: TextAlign.center,
      );

  Widget get manifestDownloadErrorInstruction => TranslatedTextWidget(
        "Please check your internet connection and try again. If this keeps happening, check if Bungie's servers aren't on maintenance via @BungieHelp.",
        textAlign: TextAlign.center,
      );

  Widget get invalidMembershipErrorMessage => TranslatedTextWidget(
        "Couldn't find playable Destiny 2 characters on your account.",
        textAlign: TextAlign.center,
      );

  Widget get invalidMembershipErrorInstruction => TranslatedTextWidget(
        "Please make sure you're using the same account you use to play Destiny 2 and the correct platform.",
        textAlign: TextAlign.center,
      );

  /// Button options

  Widget get restartOption => ElevatedButton(
        onPressed: controller.restartApp,
        child: Text("Restart Little Light".translate(context)),
      );

  Widget get clearDataAndRestartOption => ElevatedButton(
        onPressed: controller.clearDataAndRestart,
        child: Text("Clear data and restart".translate(context)),
        style: ElevatedButton.styleFrom(primary: Theme.of(context).errorColor),
      );

  Widget get openBungieLoginOption => ElevatedButton(
        onPressed: () => auth.openBungieLogin(false),
        child: Text("Authorize with Bungie.net".translate(context)),
      );

  Widget get logoutOption => ElevatedButton(
        onPressed: () {
          auth.removeAccount(auth.currentAccountID!);
          Phoenix.rebirth(context);
        },
        child: Text("Logout".translate(context)),
      );

  Widget get checkBungieNetTwitterOption => ElevatedButton(
      onPressed: () => launch("https://twitter.com/BungieHelp"),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(FontAwesomeIcons.twitter), Container(width: 8), Text("Check @BungieHelp".translate(context))],
      ));

  Widget get checkLittleLightD2TwitterOption => ElevatedButton(
      onPressed: () => launch("https://twitter.com/LittleLightD2"),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FontAwesomeIcons.twitter),
          Container(width: 8),
          Text("Check @LittleLightD2".translate(context))
        ],
      ));

  Widget get retryManifestDownloadOption => ElevatedButton(
        onPressed: controller.retryManifestDownload,
        child: Text("Retry download".translate(context)),
      );
}
