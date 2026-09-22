import 'base_filter_values_options.dart';

enum ItemOwnerType {
  Character,
  LostItems,
  Vault,
  Profile,
}

typedef ItemOwnerValue = ({ItemOwnerType ownerType, String? ownerValue});

const ItemOwnerValue ItemOwnerVault = (ownerType: ItemOwnerType.Vault, ownerValue: null);
const ItemOwnerValue ItemOwnerProfile = (ownerType: ItemOwnerType.Profile, ownerValue: null);

class ItemOwnerFilterOptions extends BaseDiscreteFilterOptions<ItemOwnerValue> {
  ItemOwnerFilterOptions(Set<ItemOwnerValue> availableValues)
    : super(
        availableValues.toSet(),
        availableValues: availableValues,
      );
}
