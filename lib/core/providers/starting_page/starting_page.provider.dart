import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/analytics/analytics.provider.dart';
import 'package:little_light/core/providers/bungie_auth/bungie_auth.provider.dart';
import 'package:little_light/core/providers/starting_page/starting_page_options.dart';
import 'package:little_light/core/providers/storage/storage.provider.dart';
import 'package:little_light/core/providers/storage/storage_keys.dart';
import 'package:little_light/utils/platform_capabilities.dart';

final startingPageProvider =
    Provider<StartingPage>((ref) => StartingPage._(ref));

class StartingPage {
  ProviderRef _ref;

  BungieAuth get auth => _ref.read(bungieAuthProvider);
  GlobalStorage get storage => _ref.read(globalStorageProvider);
  FirebaseAnalytics get analytics => _ref.read(analyticsProvider);

  StartingPage._(this._ref);

  Future<StartingPageOptions> getLatestScreen() async {
    String latest = storage.getString(StorageKeys.latestScreen);

    if (auth.isLogged) {
      final page = StartingPageOptions.values
          .firstWhere((e) => e.isEqual(latest), orElse: () => null);

      if (page != null) {
        return page;
      }
      return StartingPageOptions.Equipment;
    }
    final page =
        publicPages.firstWhere((e) => e.isEqual(latest), orElse: () => null);
    if (page != null) {
      return page;
    }
    return publicPages.first;
  }

  saveLatestScreen(StartingPageOptions screen) async {
    if (PlatformCapabilities.firebaseAnalyticsAvailable) {
      analytics.setCurrentScreen(
          screenName: screen.asString(), screenClassOverride: screen.asString());
    }

    storage.setString(StorageKeys.latestScreen, screen.asString());
  }
}
