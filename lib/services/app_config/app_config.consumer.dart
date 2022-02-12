//@dart=2.12

import 'package:get_it/get_it.dart';

import 'app_config.dart';

AppConfig getInjectedAppConfig() => GetIt.I<AppConfig>();

extension AppConfigProvider on AppConfigConsumer {
  AppConfig get appConfig => getInjectedAppConfig();
}

class AppConfigConsumer {}
