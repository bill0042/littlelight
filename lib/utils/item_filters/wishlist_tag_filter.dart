import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/littlelight/old.wishlists.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class WishlistTagFilter extends BaseItemFilter<Set<WishlistTag>> {
  WishlistTagFilter() : super(Set(), Set());

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    availableValues.clear();
    List<WishlistTag> tags = items
        .expand((i) {
          final profile = ProfileService();
          final reusable =
              profile.getItemReusablePlugs(i?.item?.itemInstanceId);
          final sockets = profile.getItemSockets(i?.item?.itemInstanceId);
          final tags = OldWishlistsService()
              .getWishlistBuildTags(
                  itemHash: i?.item?.itemHash,
                  reusablePlugs: reusable,
                  sockets: sockets)
              ?.toList();
          if (tags == null) return <WishlistTag>[];
          if (tags.length == 0) return <WishlistTag>[null];
          return tags;
        })
        .toSet()
        .toList();
    tags.sort((a, b) => a?.index?.compareTo(b?.index ?? -1) ?? 0);
    this.availableValues = tags.toSet();
    this.available = availableValues.length > 1;
    value.retainAll(availableValues);
    if (value.length == 0) return items;
    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    final profile = ProfileService();
    final reusable = profile.getItemReusablePlugs(item?.item?.itemInstanceId);
    final sockets = profile.getItemSockets(item?.item?.itemInstanceId);
    final tags = OldWishlistsService()
        .getWishlistBuildTags(
            itemHash: item?.item?.itemHash,
            reusablePlugs: reusable,
            sockets: sockets)
        ?.toList();
    if (value?.any((element) => tags?.contains(element) ?? false) ?? false)
      return true;
    if (value.contains(null) && tags?.length == 0) return true;
    return false;
  }
}
