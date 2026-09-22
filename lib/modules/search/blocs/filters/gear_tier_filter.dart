import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/gear_tier_filter_options.dart';
import 'base_item_filter.dart';

class GearTierFilter extends BaseItemFilter<GearTierFilterOptions> {
  GearTierFilter() : super(GearTierFilterOptions());

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceId = item.instanceId;
    if (instanceId == null) return false;
    final gearTier = item.gearTier ?? 0;
    return gearTier >= data.value.min && gearTier <= data.value.max;
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final available = data.availableValues;
    for (final item in items) {
      if (item.instanceId == null) continue;
      final gearTier = item.gearTier ?? 0;
      if (gearTier < available.min) available.min = gearTier;
      if (gearTier > available.max) available.max = gearTier;
    }

    final current = data.value;
    if (current.min < available.min || current.min > available.max)
      current.min = current.min.clamp(available.min, available.max);
    if (current.max < available.min || current.max > available.max)
      current.max = current.max.clamp(available.min, available.max);
  }

  @override
  void clearAvailable() {
    data.availableValues = GearTierConstraints();
  }
}
