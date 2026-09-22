import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/modules/search/blocs/filter_options/destiny_loadout_filter_options.dart';
import 'package:provider/provider.dart';
import 'base_item_filter.dart';

class DestinyLoadoutFilter extends BaseItemFilter<DestinyLoadoutFilterOptions> {
  final Map<String, Set<DestinyLoadoutKey>> _loadoutsByItem = {};
  final ProfileBloc _profileBloc;
  DestinyLoadoutFilter(BuildContext context)
    : _profileBloc = context.read<ProfileBloc>(),
      super(DestinyLoadoutFilterOptions({}));

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    if (data.isEmpty) {
      return items;
    }
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final instanceId = item.instanceId;
    if (instanceId == null) return false;
    final itemLoadouts = _loadoutsByItem[instanceId];
    if (itemLoadouts == null || itemLoadouts.isEmpty) {
      if (data.isSelected(null)) {
        return true;
      }
      return false;
    }
    return data.anySelected(itemLoadouts);
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> items) async {
    final characters = _profileBloc.characters;
    if (characters == null) return;
    _loadoutsByItem.clear();
    for (final character in characters) {
      final characterId = character.characterId;
      if (characterId == null) continue;
      final loadouts = character.loadouts;
      if (loadouts == null) continue;
      for (final (index, loadout) in loadouts.indexed) {
        final DestinyLoadoutKey loadoutKey = (characterId: characterId, loadoutIndex: index);
        loadout.items
            ?.map((item) => item.itemInstanceId)
            .nonNulls
            .where((id) => id != "0")
            .forEach((id) => _loadoutsByItem.putIfAbsent(id, () => <DestinyLoadoutKey>{}).add(loadoutKey));
      }
    }
    final loadoutIds = <DestinyLoadoutKey?>{};
    for (final item in items) {
      final instanceId = item.instanceId;
      if (instanceId == null) continue;
      final foundIds = _loadoutsByItem[instanceId];
      if (foundIds != null && foundIds.isNotEmpty)
        loadoutIds.addAll(foundIds);
      else
        loadoutIds.add(null);
    }
    data.availableValues.clear();
    data.availableValues.addAll(loadoutIds);
  }

  @override
  void clearAvailable() {
    data.availableValues.clear();
  }
}
