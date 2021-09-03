import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotEnv;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

import 'core/app/littlelight.app.dart';

int restartCounter = 0;
void main() async {
  // debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  await dotEnv.load(fileName: 'assets/_env');

  ExceptionHandler handler = ExceptionHandler(onRestart: () {
    restartCounter++;
    print('restart');
    main();
  });

  runZonedGuarded<Future<void>>(() async {
    runApp(new LittleLight(key: Key("little_light_$restartCounter")));
  }, (error, stackTrace) {
    handler.handleException(error, stackTrace);
  });
}
