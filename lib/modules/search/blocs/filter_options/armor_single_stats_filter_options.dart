import 'base_filter_values_options.dart';
import 'armor_stats_filter_options.dart';

typedef ArmorStatsConstraintsMap = Map<int, ArmorStatsConstraints>;

class ArmorSingleStatsFilterOptions extends BaseFilterOptions<ArmorStatsConstraintsMap> {
  ArmorSingleStatsFilterOptions([ArmorStatsConstraintsMap? value])
    : super(value ?? ArmorStatsConstraintsMap(), availableValues: ArmorStatsConstraintsMap());

  @override
  bool get available {
    return availableValues.isNotEmpty;
  }
}
