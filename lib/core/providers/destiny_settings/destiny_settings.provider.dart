import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:bungie_api/models/destiny_season_definition.dart';
import 'package:bungie_api/models/destiny_season_pass_definition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api.provider.dart';
import 'package:little_light/core/providers/manifest/manifest.provider.dart';
import 'package:little_light/core/providers/storage/storage.provider.dart';
import 'package:little_light/core/providers/storage/storage_keys.dart';

final destinySettingsProvider = Provider<DestinySettings>((ref) => DestinySettings._(ref));

class DestinySettings {
  ProviderRef _ref;

  Manifest get manifest => _ref.read(manifestProvider);
  GlobalStorage get globalStorage => _ref.read(globalStorageProvider);

  DateTime lastUpdated;

  DestinySettings._(this._ref);
  final _api = globalBungieApiProvider;

  CoreSettingsConfiguration _currentSettings;
  DestinySeasonPassDefinition _currentSeasonPassDef;

  static const int SeasonLevel = 3256821400;
  static const int SeasonOverlevel = 2140885848;

  init() async {
    var json =
        await globalStorage.getJson(StorageKeys.bungieCommonSettings);
    var settings = CoreSettingsConfiguration.fromJson(json ?? {});
    var seasonHash = settings?.destiny2CoreSettings?.currentSeasonHash;
    var seasonDef =
        await manifest.getDefinition<DestinySeasonDefinition>(seasonHash);
    var seasonEnd = seasonDef != null
        ? DateTime.parse(seasonDef?.endDate)
        : DateTime.fromMillisecondsSinceEpoch(0);
    var now = DateTime.now();
    if (now.isAfter(seasonEnd)) {
      print("loaded settings from web");
      settings = await _api.getCommonSettings();
      seasonHash = settings?.destiny2CoreSettings?.currentSeasonHash;
      seasonDef =
          await manifest.getDefinition<DestinySeasonDefinition>(seasonHash);
      await globalStorage
          .setJson(StorageKeys.bungieCommonSettings, settings.toJson());
    }
    _currentSettings = settings;
    _currentSeasonPassDef = await manifest
        .getDefinition<DestinySeasonPassDefinition>(seasonDef.seasonPassHash);
  }

  int get seasonalRankProgressionHash {
    return _currentSeasonPassDef?.rewardProgressionHash ?? 3256821400;
  }

  int get seasonalPrestigeRankProgressionHash {
    return _currentSeasonPassDef?.prestigeProgressionHash ?? 2140885848;
  }

  int get collectionsRootNode {
    return _currentSettings?.destiny2CoreSettings?.collectionRootNode ??
        3790247699;
  }

  int get badgesRootNode {
    return _currentSettings?.destiny2CoreSettings?.badgesRootNode ?? 498211331;
  }

  int get triumphsRootNode {
    return _currentSettings?.destiny2CoreSettings?.recordsRootNode ??
        1024788583;
  }

  int get loreRootNode {
    return _currentSettings?.destiny2CoreSettings?.loreRootNodeHash ??
        1993337477;
  }

  int get medalsRootNode {
    return _currentSettings?.destiny2CoreSettings?.medalsRootNodeHash ??
        3901403713;
  }

  int get statsRootNode {
    return _currentSettings?.destiny2CoreSettings?.metricsRootNode ??
        1024788583;
  }

  int get sealsRootNode {
    return _currentSettings?.destiny2CoreSettings?.medalsRootNode ?? 1652422747;
  }
}
