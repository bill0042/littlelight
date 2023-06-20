import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';

import 'base_filter_values_options.dart';

class ItemBucketTypeFilterOptions extends BaseFilterOptions<Set<EquipmentBucketGroup>> {
  ItemBucketTypeFilterOptions(Set<EquipmentBucketGroup> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => availableValues.length > 1;

  @override
  set value(Set<EquipmentBucketGroup> value) {
    super.value = value;
    enabled = true;
  }
}
