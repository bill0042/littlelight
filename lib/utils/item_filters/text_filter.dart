// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';
import 'package:provider/provider.dart';

import 'base_item_filter.dart';

class TextFilter extends BaseItemFilter<String> with WishlistsConsumer, ProfileConsumer {
  final BuildContext context;
  List<Loadout> loadouts;
  TextFilter(this.context, {initialText = "", enabled = true}) : super(null, initialText, enabled: enabled);

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    loadouts = context.read<LoadoutsBloc>().loadouts;
    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if ((value?.length ?? 0) < 1) return true;
    var _terms =
        value.split(RegExp("[,.|]")).map((s) => removeDiacritics(s.toLowerCase().trim())).toList(growable: false);
    var _def = definitions[item?.item?.itemHash];
    var name = removeDiacritics(_def?.displayProperties?.name?.toLowerCase()?.trim() ?? "");
    var itemType = removeDiacritics(_def?.itemTypeDisplayName?.toLowerCase()?.trim() ?? "");
    var sockets = profile.getItemSockets(item?.item?.itemInstanceId);
    var reusablePlugs = profile.getItemReusablePlugs(item?.item?.itemInstanceId);
    var plugHashes = <int>{};
    plugHashes.addAll(sockets?.map((s) => s.plugHash)?.toSet() ?? <int>{});
    plugHashes.addAll(reusablePlugs?.values
            ?.fold<List<int>>([], (l, r) => l.followedBy(r.map((e) => e.plugItemHash)).toList())?.toSet() ??
        <int>{});
    final wishlistBuildNotes =
        wishlistsService.getWishlistBuildNotes(itemHash: item.itemHash, reusablePlugs: reusablePlugs);
    final wishlistTags = wishlistsService.getWishlistBuildTags(itemHash: item.itemHash, reusablePlugs: reusablePlugs);

    var loadoutNames = loadouts
        .where(
          (l) => l.containsItem(item.instanceId),
        )
        .map((l) => l.name ?? "");

    final itemNotes = context.watch<ItemNotesBloc>();
    var customName = itemNotes.customNameFor(item?.item?.itemHash, item?.item?.itemInstanceId)?.toLowerCase() ?? "";

    return _terms.every((t) {
      var words = t.split(" ");
      if (words.every((w) => name.contains(w))) return true;
      if (words.every((w) => customName.contains(w))) return true;
      if (words.every((w) => itemType.contains(w))) return true;
      if (words.every((w) => loadoutNames.any((l) => removeDiacritics(l.toLowerCase()).contains(w)))) return true;
      if (plugHashes.any((h) {
        var plugDef = definitions[h];
        var name = removeDiacritics(plugDef?.displayProperties?.name?.toLowerCase()?.trim() ?? "");
        if (words.every((w) => name.contains(w))) return true;
        return false;
      })) return true;
      if (wishlistTags?.any((t) => words.every((w) => t.toString().toLowerCase().contains(w))) ?? false) return true;
      if (wishlistBuildNotes?.any((n) => words.every((w) => n.toLowerCase().contains(w))) ?? false) return true;
      return false;
    });
  }
}
