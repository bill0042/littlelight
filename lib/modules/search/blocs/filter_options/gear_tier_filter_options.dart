import 'base_filter_values_options.dart';

class GearTierConstraints {
  int max;
  int min;
  GearTierConstraints({this.min = 99, this.max = -99});
}

class GearTierFilterOptions extends BaseFilterOptions<GearTierConstraints> {
  GearTierFilterOptions([GearTierConstraints? value])
    : super(value ?? GearTierConstraints(min: -99, max: 99), availableValues: GearTierConstraints());

  @override
  bool get available => availableValues.max > availableValues.min;
}
