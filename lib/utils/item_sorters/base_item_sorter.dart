import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/core/providers/manifest/manifest.provider.dart';
import 'package:little_light/core/providers/profile/profile.provider.dart';
import 'package:little_light/utils/item_with_owner.dart';

abstract class BaseItemSorter {
  Profile get profile => globalProfileProvider;
  int direction;
  BaseItemSorter(this.direction);

  DestinyItemInstanceComponent instance(ItemWithOwner item) =>
      profile.getInstanceInfo(item?.item?.itemInstanceId);
  DestinyInventoryItemDefinition def(ItemWithOwner item) =>
      globalManifestProvider.getDefinitionFromCache<
          DestinyInventoryItemDefinition>(item?.item?.itemHash);

  int sort(ItemWithOwner a, ItemWithOwner b);
}
