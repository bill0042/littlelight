//@dart=2.12

import 'dart:io';

import 'package:get_it/get_it.dart';
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
      final Map<String, dynamic> json = await getJson(LanguageStorageKeys.littleLightTranslation);
      return Map<String, String>.from(json);
    } catch (e) {
      print("can't parse translations");
      print(e);
    }
    return null;
  }

  Future<void> saveTranslations(Map<String, String> translations) async {
    await setJson(LanguageStorageKeys.littleLightTranslation, translations);
  }

  Future<void> purge() async {
    await purgePath(this.basePath);
  }
}
