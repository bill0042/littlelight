import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/global_container/global.container.dart';
import 'package:little_light/core/providers/littlelight_api/littlelight_api.provider.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/storage/storage.service.dart';

final loadoutsProvider =
    Provider<LoadoutsService>((ref) => LoadoutsService._(ref));

get globalLoadoutsProvider => globalContainer.read(loadoutsProvider);

class LoadoutsService {
  ProviderRef<LoadoutsService> _ref;

  LoadoutsService._(this._ref);

  LittleLightApi get _littleLightApi => _ref.read(littleLightApiProvider);

  List<Loadout> _loadouts;

  reset() {
    _loadouts = null;
  }

  Future<List<Loadout>> getLoadouts({forceFetch = false}) async {
    if (_loadouts != null && !forceFetch) {
      await _sortLoadouts();
      return _loadouts;
    }
    await _loadLoadoutsFromCache();
    if (forceFetch) {
      await _fetchLoadouts();
    }
    await _sortLoadouts();
    return _loadouts;
  }

  Future<void> _sortLoadouts() async {
    var _order = await _getLoadoutsOrder();
    _loadouts.sort((la, lb) {
      var indexA = _order.indexOf(la.assignedId);
      var indexB = _order.indexOf(lb.assignedId);
      if (indexA != indexB) return indexB.compareTo(indexA);
      var nameA = la?.name?.toLowerCase() ?? "";
      var nameB = lb?.name?.toLowerCase() ?? "";
      return nameA.compareTo(nameB);
    });
  }

  Future<List<Loadout>> _loadLoadoutsFromCache() async {
    var storage = StorageService.membership();
    List<dynamic> json = await storage.getJson(StorageKeys.cachedLoadouts);
    if (json != null) {
      List<Loadout> loadouts = json.map((j) => Loadout.fromJson(j)).toList();
      this._loadouts = loadouts;
      return loadouts;
    }
    return null;
  }

  Future<List<Loadout>> _fetchLoadouts() async {
    List<Loadout> _fetchedLoadouts = await _littleLightApi.fetchLoadouts();
    if (_loadouts == null) {
      _loadouts = _fetchedLoadouts;
    } else if (_fetchedLoadouts != null) {
      _fetchedLoadouts.forEach((loadout) {
        int index =
            _loadouts.indexWhere((l) => l.assignedId == loadout.assignedId);
        if (index < 0) {
          _loadouts.add(loadout);
        } else {
          var _storedLoadout = _loadouts[index];
          if (_storedLoadout.updatedAt
              .toUtc()
              .isBefore(loadout.updatedAt.toUtc())) {
            _loadouts.replaceRange(index, index + 1, [loadout]);
          }
        }
      });
    }
    _saveLoadoutsToStorage();
    return _loadouts;
  }

  Future<int> saveLoadout(Loadout loadout) async {
    loadout.updatedAt = DateTime.now();
    bool exists = _loadouts.any((l) => l.assignedId == loadout.assignedId);
    if (exists) {
      int index =
          _loadouts.indexWhere((l) => l.assignedId == loadout.assignedId);
      _loadouts.replaceRange(index, index + 1, [loadout]);
    } else {
      _loadouts.add(loadout);
    }

    await _saveLoadoutsToStorage();
    return await _littleLightApi.saveLoadout(loadout);
  }

  Future<int> deleteLoadout(Loadout loadout) async {
    _loadouts.removeWhere((l) => l.assignedId == loadout.assignedId);
    await _saveLoadoutsToStorage();
    var response = await _littleLightApi.deleteLoadout(loadout);
    return response;
  }

  Future<void> _saveLoadoutsToStorage() async {
    var storage = StorageService.membership();
    Set<String> _ids = Set();
    List<Loadout> distinctLoadouts = _loadouts.where((l) {
      bool exists = _ids.contains(l.assignedId);
      _ids.add(l.assignedId);
      return !exists;
    }).toList();
    List<dynamic> json = distinctLoadouts.map((l) => l.toJson()).toList();
    await storage.setJson(StorageKeys.cachedLoadouts, json);
  }

  Future<void> saveLoadoutsOrder(List<Loadout> loadouts) async {
    List<String> order =
        loadouts.map((l) => l.assignedId).toList().reversed.toList();
    var storage = StorageService.membership();
    await storage.setJson(StorageKeys.loadoutsOrder, order);
  }

  Future<List<String>> _getLoadoutsOrder() async {
    var storage = StorageService.membership();
    var order = List<String>.from(
        await storage.getJson(StorageKeys.loadoutsOrder) ?? []);
    return order ?? <String>[];
  }
}
