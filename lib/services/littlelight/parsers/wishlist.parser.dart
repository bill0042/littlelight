import 'package:flutter/foundation.dart';
import 'package:little_light/models/wish_list.dart';

typedef OnAddToWishlist(
    {String name,
    int hash,
    List<List<int>> perks,
    Set<WishlistTag> specialties,
    Set<String> notes,
    String originalWishlist});

abstract class WishlistParser {
  OnAddToWishlist onAddToWishlist;

  WishlistParser({@required this.onAddToWishlist});

  Future<void> parse(String text);
}
