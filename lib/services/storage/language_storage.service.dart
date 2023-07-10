import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'language_storage.keys.dart';
import 'storage.base.dart';

setupLanguageStorageService() async {
  GetIt.I.registerFactoryParam<LanguageStorage, String, void>((accountID, _) => LanguageStorage._internal(accountID));
}

class LanguageStorage extends StorageBase<LanguageStorageKeys> {
  LanguageStorage._internal(languageCode) : super("languages/$languageCode");

  @override
  String getKeyPath(LanguageStorageKeys? key) {
    return key?.path ?? "";
  }

  Future<String> _getManifestDBPath() async {
    if (Platform.isWindows) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final dbRoot = directory.path;
        return "$dbRoot/$basePath/manifest.db";
      } catch (e) {}
      try {
        final directory = await getApplicationSupportDirectory();
        final dbRoot = directory.path;
        return "$dbRoot/$basePath/manifest.db";
      } catch (e) {}
      return "";
    }
    String dbRoot = await getDatabasesPath();
    return "$dbRoot/$basePath/manifest.db";
  }

  set manifestVersion(String? manifestVersion) => setString(LanguageStorageKeys.manifestVersion, manifestVersion);
  String? get manifestVersion => getString(LanguageStorageKeys.manifestVersion);

  Future<void> saveManifestDatabase(List<int> data) async {
    final manifestFile = File(await _getManifestDBPath());
    final dir = manifestFile.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await manifestFile.writeAsBytes(data);
  }

  Future<File?> getManifestDatabaseFile() async {
    final manifestFile = File(await _getManifestDBPath());
    if (await manifestFile.exists()) {
      return manifestFile;
    }
    return null;
  }

  Future<Map<String, String>?> getTranslations() async {
    try {
      final Map<String, dynamic>? json = await getJson(LanguageStorageKeys.littleLightTranslation);
      if (json == null) return null;
      return Map<String, String>.from(json);
    } catch (e) {
      logger.error("can't parse translations", error: e);
    }
    return null;
  }

  Future<void> saveTranslations(Map<String, String> translations) async {
    await setJson(LanguageStorageKeys.littleLightTranslation, translations);
  }

  Future<void> purge() async {
    await purgePath(basePath);
  }
}
