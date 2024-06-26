import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';

class WishlistsData {
  static BoxDecoration getBoxDecoration(BuildContext context, WishlistTag tag) {
    switch (tag) {
      case WishlistTag.GodPVE:
      case WishlistTag.GodPVP:
        return BoxDecoration(
            border: Border.all(color: context.theme.achievementLayers, width: 1),
            gradient: RadialGradient(radius: 1, colors: [getBgColor(context, tag), context.theme.achievementLayers]));

      case WishlistTag.Controller:
        return BoxDecoration(
            border: Border.all(color: context.theme.secondarySurfaceLayers.layer0, width: 1),
            color: context.theme.primaryLayers.layer0);

      case WishlistTag.Mouse:
        return BoxDecoration(
            border: Border.all(color: context.theme.primaryLayers.layer0, width: 1),
            color: context.theme.secondarySurfaceLayers.layer0);
      default:
        return BoxDecoration(color: getBgColor(context, tag));
    }
  }

  static Color getBgColor(BuildContext context, WishlistTag tag) {
    switch (tag) {
      case WishlistTag.GodPVE:
      case WishlistTag.PVE:
        return Colors.blue.shade800;
      case WishlistTag.GodPVP:
      case WishlistTag.PVP:
        return Colors.red.shade800;
      case WishlistTag.Bungie:
        return Colors.black;

      case WishlistTag.Controller:
        return context.theme.secondarySurfaceLayers.layer0;

      case WishlistTag.Mouse:
        return context.theme.primaryLayers.layer0;

      case WishlistTag.Trash:
        return Colors.lightGreen.shade500;

      default:
        return Colors.transparent;
    }
  }

  static Widget getLabel(WishlistTag tag, BuildContext context) {
    switch (tag) {
      case WishlistTag.GodPVE:
        return Text("PvE godroll".translate(context));
      case WishlistTag.PVE:
        return Text("PvE".translate(context));
      case WishlistTag.GodPVP:
        return Text("PvP godroll".translate(context));
      case WishlistTag.PVP:
        return Text("PvP".translate(context));
      case WishlistTag.Bungie:
        return Text("Curated".translate(context));

      case WishlistTag.Trash:
        return Text("Trash".translate(context));
      default:
        return Container();
    }
  }

  static Widget getIcon(BuildContext context, WishlistTag tag, double size) {
    switch (tag) {
      case WishlistTag.GodPVE:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(LittleLightIcons.vanguard,
                size: size * .8, color: LittleLightThemeData().onSurfaceLayers));
      case WishlistTag.PVE:
        return Container(
            alignment: Alignment.center, child: CenterIconWorkaround(LittleLightIcons.vanguard, size: size * .8));
      case WishlistTag.GodPVP:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(LittleLightIcons.crucible,
                size: size * .9, color: LittleLightThemeData().onSurfaceLayers));
      case WishlistTag.PVP:
        return Container(
            alignment: Alignment.center, child: CenterIconWorkaround(LittleLightIcons.crucible, size: size * .9));
      case WishlistTag.Bungie:
        return Container(
            alignment: Alignment.center, child: CenterIconWorkaround(LittleLightIcons.bungie, size: size * .9));

      case WishlistTag.Trash:
        return Container(
            padding: EdgeInsets.all(size * .1),
            child: Image.asset(
              "assets/imgs/trash-roll-icon.png",
            ));

      case WishlistTag.Controller:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(
              FontAwesomeIcons.gamepad,
              size: size * .6,
              color: context.theme.secondarySurfaceLayers.layer0,
            ));

      case WishlistTag.Mouse:
        return Container(
            alignment: Alignment.center,
            child: CenterIconWorkaround(
              FontAwesomeIcons.computerMouse,
              size: size * .7,
              color: context.theme.primaryLayers.layer0,
            ));

      default:
        return Container();
    }
  }
}
