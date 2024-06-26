import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/search/blocs/filter_options/wishlist_tag_filter_options.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'base_item_filter.dart';

class WishlistTagFilter extends BaseItemFilter<WishlistTagFilterOptions> with WishlistsConsumer {
  final Map<String, Set<WishlistTag>> _itemTags = {};
  WishlistTagFilter() : super(WishlistTagFilterOptions({}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceId = item.instanceId;
    if (instanceId == null) return false;

    final tags = _itemTags[instanceId];
    if (tags == null || tags.isEmpty) return data.value.contains(null);
    return data.value.any((t) => tags.contains(t));
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final allTags = <WishlistTag?>{};
    for (final item in items) {
      final hash = item.itemHash;
      final reusablePlugs = item.reusablePlugs;
      final instanceId = item.instanceId;
      if (hash == null) continue;
      if (instanceId == null) continue;
      final tags = wishlistsService.getWishlistBuildTags(itemHash: hash, reusablePlugs: reusablePlugs);
      if (tags.isEmpty) {
        allTags.add(null);
        continue;
      }
      allTags.addAll(tags);
      final itemTags = _itemTags[instanceId] ??= {};
      itemTags.addAll(tags);
    }
    data.availableValues.addAll(allTags);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
