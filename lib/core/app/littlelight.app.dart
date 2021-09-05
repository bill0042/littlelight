import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class LittleLight extends StatelessWidget {
  final Key key;
  LittleLight({this.key});

  @override
  Widget build(BuildContext context) {
    QueuedNetworkImage.maxNrOfCacheObjects = 5000;
    QueuedNetworkImage.inBetweenCleans = new Duration(days: 30);

    List<NavigatorObserver> observers = [];
    if (PlatformCapabilities.firebaseAnalyticsAvailable) {
      FirebaseAnalytics analytics = FirebaseAnalytics();
      FirebaseAnalyticsObserver observer =
          FirebaseAnalyticsObserver(analytics: analytics);
      observers.add(observer);
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      key: key,
      title: 'Little Light',
      navigatorObservers: observers,
      theme: LittleLightTheme().theme,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: LittleLightScrollBehaviour(),
          child: child,
        );
      },
      home: new InitialScreen(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('fr'), // French
        const Locale('es'), // Spanish
        const Locale('de'), // German
        const Locale('it'), // Italian
        const Locale('ja'), // Japan
        const Locale('pt', 'BR'), // Brazillian Portuguese
        const Locale('es', 'MX'), // Mexican Spanish
        const Locale('ru'), // Russian
        const Locale('pl'), // Polish
        const Locale('ko'), // Korean
        const Locale('zh', 'CHT'), // Chinese
        const Locale('zh', 'CHS'), // Chinese
      ],
    );
  }
}

class LittleLightScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isIOS || Platform.isMacOS) {
      return child;
    }
    return GlowingOverscrollIndicator(
      child: child,
      axisDirection: axisDirection,
      color: Theme.of(context).accentColor,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Platform.isIOS) {
      return const BouncingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }
}
