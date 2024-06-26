import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/app_config/app_config.consumer.dart';
import 'package:little_light/services/app_config/app_config.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:provider/provider.dart';

import 'https_override/https_overrides.dart';
import 'littlelight/littlelight_api.service.dart';
import 'manifest/manifest.service.dart';

final getItCoreInstance = GetIt.asNewInstance();

Future<void> setupCoreServices() async {
  await getItCoreInstance.reset();
  await setupAnalyticsService();
  setupHttpsOverrides();
}

Future<void> setupServices() async {
  await GetIt.I.reset();
  await setupStorageService();
  await setupAppConfig();
  await setupAuthService();
  await setupLanguageService();
  await setupManifest();
  await setupLittleLightDataService();
  await setupWishlistsService();
  await setupBungieApiService();
  await setupNotificationService();
  await setupSelectionService();
  await setupDestinySettingsService();
}

initServices(BuildContext context) async {
  final appConfig = getInjectedAppConfig();
  final globalStorage = getInjectedGlobalStorage();
  final auth = getInjectedAuthService();
  final language = getInjectedLanguageService();
  final manifest = getInjectedManifestService();
  await appConfig.setup();
  await globalStorage.setup();
  auth.setup();
  await language.init(context);
  await LittleLightApiService().reset();
  await manifest.setup();
}

initPostLoadingServices(BuildContext context) async {
  final settings = context.read<UserSettingsBloc>();
  await settings.init();
  final destinySettings = getInjectedDestinySettingsService();
  await destinySettings.init();
  final inventory = context.read<InventoryBloc>();
  await inventory.init();
  final analytics = getInjectedAnalyticsService();
  analytics.updateCurrentUser();
}
