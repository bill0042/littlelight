import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/armor_stats_filter_options.dart';
import 'package:little_light/modules/search/blocs/filter_options/armor_single_stats_filter_options.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'base_item_filter.dart';
import 'package:bungie_api/src/models/destiny_stat.dart';

class ArmorSingleStatsFilter extends BaseItemFilter<ArmorSingleStatsFilterOptions> {
  ArmorSingleStatsFilter() : super(ArmorSingleStatsFilterOptions());

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceId = item.instanceId;
    if (instanceId == null) return false;
    final stats = item.stats?.values;
    if (stats == null) return false;

    final constraintsMap = data.value;
    return stats.every((e) {
      if (e.statHash == null || e.value == null) return true;
      final statConstraints = constraintsMap[e.statHash] ?? ArmorStatsConstraints();
      return e.value! >= statConstraints.min && e.value! <= statConstraints.max;
    });
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final availableValues = data.availableValues;
    for (final item in items) {
      if (item.instanceId == null || !InventoryBucket.armorBucketHashes.contains(item.bucketHash)) continue;
      final stats = item.stats?.values;
      if (stats == null) continue;
      for (final stat in stats) {
        if (stat case DestinyStat(:final statHash?, :final value?)) {
          final constraints = availableValues.putIfAbsent(statHash, () => ArmorStatsConstraints());
          if (value < constraints.min) constraints.min = value;
          if (value > constraints.max) constraints.max = value;
        }
      }
    }

    for (final MapEntry(key: statHash, value: available) in availableValues.entries) {
      final value = data.value[statHash];
      if (value == null)
        data.value[statHash] = ArmorStatsConstraints(min: available.min, max: available.max);
      else {
        if (value.min < available.min || value.min > available.max)
          value.min = value.min.clamp(available.min, available.max);
        if (value.max < available.min || value.max > available.max)
          value.max = value.max.clamp(available.min, available.max);
      }
    }
  }

  @override
  void clearAvailable() {
    data.availableValues = ArmorStatsConstraintsMap();
  }
}
