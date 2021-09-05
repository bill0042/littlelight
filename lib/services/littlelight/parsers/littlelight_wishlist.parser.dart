import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:little_light/models/littlelight_wishlist.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/parsers/wishlist.parser.dart';

class LittleLightWishlistParser extends WishlistParser {
  LittleLightWishlistParser({@required OnAddToWishlist onAddToWishlist})
      : super(onAddToWishlist: onAddToWishlist);
  Future<LittleLightWishlist> parse(String text) async {
    var json = jsonDecode(text);
    var wishlist = LittleLightWishlist.fromJson(json);

    for (var item in wishlist.data) {
      var tags = parseTags(item.tags);
      onAddToWishlist(
          originalWishlist: item.originalWishlist ?? wishlist.name ?? "",
          name: item.name,
          hash: item.hash,
          perks: item.plugs,
          specialties: tags,
          notes: [item.description].toSet());
    }
    return wishlist;
  }

  Set<WishlistTag> parseTags(List<String> tags) {
    return tags
        .map((t) {
          switch (t.toLowerCase()) {
            case "godpve":
            case "god-pve":
              return WishlistTag.GodPVE;
            case "pve":
              return WishlistTag.PVE;
            case "godpvp":
            case "god-pvp":
              return WishlistTag.GodPVP;
            case "pvp":
              return WishlistTag.PVP;
            case "curated":
            case "bungie":
              return WishlistTag.Bungie;
            case "💩":
            case "🤢":
            case "🤢🤢🤢":
            case "trash":
              return WishlistTag.Trash;

            case "mouse":
            case "mnk":
              return WishlistTag.Mouse;

            case "controller":
              return WishlistTag.Controller;
          }
          return null;
        })
        .where((element) => element != null)
        .toSet();
  }
}
