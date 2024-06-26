import 'package:bungie_api/destiny2.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/crafted_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

import 'base_item_filter.dart';

class CraftedFilter extends BaseItemFilter<CraftedFilterOptions> with ManifestConsumer {
  CraftedFilter() : super(CraftedFilterOptions(<bool>{}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.value.isNotEmpty) {
      return super.filter(context, items);
    }
    return items;
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final isCrafted = item.state?.contains(ItemState.Crafted) ?? false;
    return data.value.contains(isCrafted);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final isCrafted = items.map((i) => i.state?.contains(ItemState.Crafted) ?? false);
    data.availableValues.addAll(isCrafted);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
