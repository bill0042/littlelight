import 'package:flutter/material.dart';
import 'package:little_light/screens/triumphs/triumph_category.screen.dart';

class TriumphCategoryRouteArguments {
  final int presentationNodeHash;
  TriumphCategoryRouteArguments(this.presentationNodeHash);
}

class TriumphCategoryRoute extends MaterialPageRoute<void> {
  static String routeName = "triumphs/category";
  TriumphCategoryRoute(int presentationNodeHash)
      : super(
            settings: RouteSettings(
                name: routeName,
                arguments: TriumphCategoryRouteArguments(presentationNodeHash)),
            builder: (BuildContext context) => TriumphCategoryScreen());
}
