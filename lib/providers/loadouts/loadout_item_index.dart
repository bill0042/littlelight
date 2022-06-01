import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/item_sorters/power_level_sorter.dart';
import 'package:little_light/utils/item_with_owner.dart';

class LoadoutItemIndex with ProfileConsumer, ManifestConsumer {
  static const List<int> genericBucketHashes = [
    InventoryBucket.kineticWeapons,
    InventoryBucket.energyWeapons,
    InventoryBucket.powerWeapons,
    InventoryBucket.ghost,
    InventoryBucket.vehicle,
    InventoryBucket.ships,
  ];
  static const List<int> classBucketHashes = [
    InventoryBucket.subclass,
    InventoryBucket.helmet,
    InventoryBucket.gauntlets,
    InventoryBucket.chestArmor,
    InventoryBucket.legArmor,
    InventoryBucket.classArmor
  ];
  Map<int, DestinyItemComponent?> generic = {};
  Map<int, Map<DestinyClass, DestinyItemComponent?>> classSpecific = {};
  Map<int, List<DestinyItemComponent>> unequipped = {};
  int unequippedCount = 0;
  Loadout loadout;

  static Future<LoadoutItemIndex> buildfromLoadout(Loadout loadout) async {
    final loadoutIndex = LoadoutItemIndex._(loadout);
    await loadoutIndex._buildIndex();
    return loadoutIndex;
  }

  Future<void> _buildIndex() async {
    final items = loadout.equipped + loadout.unequipped;
    final itemIds = items.map((e) => e.itemInstanceId).whereType<String>().toList();
    final itemHashes = items.map((e) => e.itemHash).whereType<int>().toSet();

    List<DestinyItemComponent> loadoutItems = profile.getItemsByInstanceId(itemIds);
    List<String> existingIds = loadoutItems.map((i) => i.itemInstanceId).whereType<String>().toList();
    List<String> missingIds = itemIds.whereNot((id) => existingIds.contains(id)).toList();

    if (missingIds.isNotEmpty) {
      _replaceMissingItems(missingIds, itemIds);
      loadoutItems = profile.getItemsByInstanceId(itemIds);
    }

    final defs = await manifest.getDefinitions<DestinyInventoryItemDefinition>(itemHashes);
    for (final item in loadoutItems) {
      final def = defs[item.itemHash];
      final isEquipped = loadout.equipped.any((e) => e.itemInstanceId == item.itemInstanceId);
      if (def == null) continue;
      _addItemToLoadoutIndex(item, def, isEquipped);
    }
  }

  void _replaceMissingItems(List<String> missingItemIds, List<String> loadoutItemIds) {
    List<ItemWithOwner> availableItems = profile.getAllItems().whereNot((id) => loadoutItemIds.contains(id)).toList();
    for (final id in missingItemIds) {
      loadoutItemIds.remove(id);
      LoadoutItem? equipped = loadout.equipped.firstWhereOrNull((i) => i.itemInstanceId == id);
      LoadoutItem? unequipped = loadout.unequipped.firstWhereOrNull((i) => i.itemInstanceId == id);
      int? itemHash = equipped?.itemHash ?? unequipped?.itemHash;
      if (itemHash == null) continue;
      final substituteItemId = _findSubstituteItemID(itemHash, availableItems);
      if (substituteItemId == null) continue;
      loadoutItemIds.add(substituteItemId);
      if (equipped != null) {
        loadout.equipped.remove(equipped);
        loadout.equipped.add(LoadoutItem(
          itemInstanceId: substituteItemId,
          itemHash: itemHash,
        ));
      }
      if (unequipped != null) {
        loadout.unequipped.remove(unequipped);
        loadout.unequipped.add(LoadoutItem(
          itemInstanceId: substituteItemId,
          itemHash: itemHash,
        ));
      }
    }
  }

  String? _findSubstituteItemID(int itemHash, List<ItemWithOwner> availableItems) {
    List<ItemWithOwner> candidates = availableItems.where((i) => i.item.itemHash == itemHash).toList();
    final powerSorter = PowerLevelSorter(-1);
    candidates.sort((a, b) => powerSorter.sort(a, b));
    String? substituteID = candidates.firstOrNull?.item.itemInstanceId;
    if (substituteID != null) {
      availableItems.removeWhere((element) => element.item.itemInstanceId == substituteID);
    }
    return substituteID;
  }

  LoadoutItemIndex._(this.loadout);

  void _addItemToLoadoutIndex(DestinyItemComponent item, DestinyInventoryItemDefinition def, bool equipped) {
    final isClassSpecificItem = [DestinyClass.Titan, DestinyClass.Hunter, DestinyClass.Warlock].contains(def.classType);
    final bucketTypeHash = def.inventory?.bucketTypeHash;
    if (bucketTypeHash == null) return;
    if (!equipped) {
      unequipped[bucketTypeHash] ??= [];
      unequipped[bucketTypeHash]?.add(item);
      return;
    }
    if (isClassSpecificItem) {
      final classType = def.classType;
      if (classType == null) return;
      classSpecific[bucketTypeHash] ??= Map();
      classSpecific[bucketTypeHash]?[classType] = item;
      return;
    }
    generic[bucketTypeHash] = item;
  }

  void _removeItemFromLoadoutIndex(DestinyItemComponent item, DestinyInventoryItemDefinition def, bool equipped) {
    final bucketTypeHash = def.inventory?.bucketTypeHash;
    if (bucketTypeHash == null) return;
    if (!equipped) {
      unequipped[bucketTypeHash]?.removeWhere((e) => item.itemInstanceId == e.itemInstanceId);
      return;
    }
    classSpecific[bucketTypeHash]?.removeWhere((key, value) => item.itemInstanceId == value?.itemInstanceId);
    if (generic[bucketTypeHash]?.itemInstanceId == item.itemInstanceId) {
      generic[bucketTypeHash] = null;
    }
  }

  void addEquippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    _addItemToLoadoutIndex(item, def, true);
    loadout.equipped.add(LoadoutItem(itemInstanceId: item.itemInstanceId, itemHash: item.itemHash));
  }

  void addUnequippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    _addItemToLoadoutIndex(item, def, false);
    loadout.unequipped.add(LoadoutItem(itemInstanceId: item.itemInstanceId, itemHash: item.itemHash));
  }

  removeEquippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    _removeItemFromLoadoutIndex(item, def, true);
    loadout.equipped.removeWhere((e) => e.itemInstanceId == item.itemInstanceId);
  }

  removeUnequippedItem(DestinyItemComponent item, DestinyInventoryItemDefinition def) {
    _removeItemFromLoadoutIndex(item, def, false);
    loadout.unequipped.removeWhere((e) => e.itemInstanceId == item.itemInstanceId);
  }

  bool haveEquippedItem(DestinyInventoryItemDefinition def) {
    return loadout.equipped.any((e) => e.itemHash == def.hash);
  }
}
