import 'package:bungie_api/destiny2.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/socket_category_hashes.dart';

Future<List<int>?> getArtifactModsSocketCategories(ManifestService manifest, DestinyInventoryItemDefinition definition) async {
  final hashes = definition.sockets?.socketCategories?.map((e) => e.socketCategoryHash).toList();
  if (hashes == null) return null;
  final hardCodedHashes = hashes.where((element) => SocketCategoryHashes.mods.contains(element)).nonNulls.toList();
  if (hardCodedHashes.isNotEmpty) return hardCodedHashes;
  final defs = await manifest.getDefinitions<DestinySocketCategoryDefinition>(hashes);
  final defsList = defs.values.where((def) => def.categoryStyle == DestinySocketCategoryStyle.Consumable).toList();
  defsList.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
  final consumableHashes = defsList.map((def) => def.hash).nonNulls.toList();
  return consumableHashes;
}
