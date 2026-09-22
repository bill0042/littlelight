import 'base_filter_values_options.dart';

class LoadoutFilterOptions extends BaseDiscreteFilterOptions<String?> {
  LoadoutFilterOptions(Set<String?> availableValues)
    : super(
        availableValues.toSet(),
        availableValues: availableValues,
      );
}
