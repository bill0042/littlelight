import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:little_light/exceptions/exception_handler.dart';

import 'core/app/littlelight.app.dart';

int restartCounter = 0;
void main() async {
  // debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  ExceptionHandler handler = ExceptionHandler(onRestart: () {
    restartCounter++;
    print('restart');
    main();
  });

  runZonedGuarded<Future<void>>(() async {
    runApp(LittleLight(key: Key("little_light_$restartCounter")));
  }, (error, stackTrace) {
    handler.handleException(error, stackTrace);
  });
}
