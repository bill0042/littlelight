import 'package:flutter/foundation.dart';
import 'package:little_light/models/wish_list.dart';

typedef OnAddToWishlist = Function(
    {String name,
    int hash,
    List<List<int>> perks,
    Set<WishlistTag> specialties,
    Set<String> notes,
    String originalWishlist});

abstract class WishlistParser {
  OnAddToWishlist onAddToWishlist;

  @mustCallSuper
  WishlistParser({@required this.onAddToWishlist});

  Future<void> parse(String text);
}