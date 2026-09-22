import 'base_filter_values_options.dart';

typedef DestinyLoadoutKey = ({String characterId, int loadoutIndex}); // characterId, loadout index

class DestinyLoadoutFilterOptions extends BaseDiscreteFilterOptions<DestinyLoadoutKey?> {
  DestinyLoadoutFilterOptions(Set<DestinyLoadoutKey?> availableValues)
    : super(
        availableValues.toSet(),
        availableValues: availableValues,
      );
}
