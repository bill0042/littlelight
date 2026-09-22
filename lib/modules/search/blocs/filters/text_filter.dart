import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/text_filter_options.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';
import 'base_item_filter.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';

extension on List<String> {
  bool searchMatches(String str) {
    if (this.length == 1 && this.first.length <= 3) {
      return str.startsWith(first);
    }
    return this.every((w) => str.contains(w));
  }
}

class TextFilter extends BaseItemFilter<TextFilterOptions> with ManifestConsumer, WishlistsConsumer {
  List<Loadout>? loadouts;
  ItemNotesBloc? itemNotesBloc;
  UserSettingsBloc? userSettings;
  LittleLightDataBloc? littleLightDataBloc;
  TextFilter({initialText = ""}) : super(TextFilterOptions());

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    loadouts = context.read<LoadoutsBloc>().loadouts;
    itemNotesBloc = context.read<ItemNotesBloc>();
    userSettings = context.read<UserSettingsBloc>();
    littleLightDataBloc = context.read<LittleLightDataBloc>();
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final searchString = data.value;
    if (searchString == null) return true;
    if (searchString.length == 0) return true;
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    if (hash == null) return false;
    final terms = searchString.split(RegExp("[,.|]")).map((s) => removeDiacritics(s.toLowerCase().trim()));
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (def == null) return false;
    if (hash == int.tryParse(searchString)) return true;
    if (instanceId == searchString) return true;
    final name = removeDiacritics(def.displayProperties?.name?.toLowerCase().trim() ?? "");
    final itemType = removeDiacritics(def.itemTypeDisplayName?.toLowerCase().trim() ?? "");

    final damageTypeDef = await manifest.getDefinition<DestinyDamageTypeDefinition>(def.defaultDamageTypeHash);
    final damageTypeName = removeDiacritics(damageTypeDef?.displayProperties?.name?.toLowerCase());

    final sockets = item.sockets;
    final reusablePlugs = item.reusablePlugs;
    final cosmeticSocketCategories = littleLightDataBloc?.gameData?.cosmeticSocketCategories ?? [];
    final nonCosmeticIndexes = def.sockets?.socketCategories
        ?.where((catDef) => !cosmeticSocketCategories.contains(catDef.socketCategoryHash))
        .map((catDef) => catDef.socketIndexes)
        .nonNulls
        .expand((indexes) => indexes);
    final plugHashes =
        nonCosmeticIndexes
            ?.expand((index) {
              final socket = sockets?[index];
              if (!(socket?.isEnabled ?? false) || !(socket?.isVisible ?? false)) return <int>[];
              return [socket?.plugHash, ...?reusablePlugs?[index.toString()]?.map((p) => p.plugItemHash)];
            })
            .nonNulls
            .toSet() ??
        {};
    final plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    final plugNames = plugDefinitions.values
        .map((def) => def.displayProperties?.name ?? "")
        .where((name) => name.isNotEmpty)
        .map((name) => removeDiacritics(name.toLowerCase().trim()));

    final wishlistBuildNotes = (userSettings?.textFilterWishlistNotes ?? true)
        ? wishlistsService
              .getWishlistBuildNotes(itemHash: hash, reusablePlugs: reusablePlugs)
              .map(
                (e) => e.toLowerCase(),
              )
        : Iterable<String>.empty();

    final wishlistTags = wishlistsService.getWishlistBuildTags(itemHash: hash, reusablePlugs: reusablePlugs);
    final wishlistTagNames = wishlistTags.map((t) => t.name.toLowerCase());

    final loadoutNames = (userSettings?.textFilterLoadoutName ?? true)
        ? loadouts
              ?.where((l) => instanceId != null ? l.containsItem(instanceId) : false) //
              .map((l) => l.name.toLowerCase().replaceDiacritics())
        : null;

    final customName = itemNotesBloc?.customNameFor(hash, instanceId)?.toLowerCase();

    return terms.every((t) {
      var words = t.split(" ");
      final matchesName = words.searchMatches(name);
      if (matchesName) return true;

      final matchesCustomName = words.searchMatches(customName ?? "");
      if (matchesCustomName) return true;

      final matchesItemTypes = words.searchMatches(itemType);
      if (matchesItemTypes) return true;

      final matchesDamageType = words.searchMatches(damageTypeName);
      if (matchesDamageType) return true;

      final matchesLoadoutNames = loadoutNames?.any((l) => words.searchMatches(l)) ?? false;
      if (matchesLoadoutNames) return true;

      final matchesPlugs = plugNames.any((plugName) => words.searchMatches(plugName));
      if (matchesPlugs) return true;

      final matchesWishlistsTags = wishlistTagNames.any((t) => words.searchMatches(t));
      if (matchesWishlistsTags) return true;

      final matchesWishlistNotes = wishlistBuildNotes.any((n) => words.searchMatches(n));
      if (matchesWishlistNotes) return true;

      return false;
    });
  }

  @override
  Future<void> addValues(List<DestinyItemInfo> item) async => null;

  @override
  void clearAvailable() => null;
}
