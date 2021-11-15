import 'dart:convert';
import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/core/providers/storage/storage_keys.dart';
import 'package:little_light/core/providers/translations/timeago_messages/cn_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/de_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/en_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/es_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/fr_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/it_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/ja_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/ko_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/pl_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/pt_messages.dart';
import 'package:little_light/core/providers/translations/timeago_messages/ru_messages.dart';
import 'package:little_light/core/providers/storage/storage.provider.dart';
import 'package:timeago/timeago.dart' as timeago;

final translationsProvider =
    Provider<Translations>((ref) => Translations._(ref));

class Translations {
  String fallbackLanguage = "en";

  ProviderRef _ref;
  GlobalStorage get _storage => _ref.read(globalStorageProvider);
  Storage _languageStorage(String code) => _ref.read(languageStorageProvider(code));
  String get currentLanguage =>
      _storage.getLanguage() ?? fallbackLanguage;
  Map<String, Map<String, String>> _translationMaps = Map();

  Translations._(this._ref) {
    timeago.setLocaleMessages('de', DeMessages());
    timeago.setLocaleMessages('en', EnMessages());
    timeago.setLocaleMessages('es', EsMessages());
    timeago.setLocaleMessages('es-mx', EsMessages());
    timeago.setLocaleMessages('fr', FrMessages());
    timeago.setLocaleMessages('it', ItMessages());
    timeago.setLocaleMessages('ja', JaMessages());
    timeago.setLocaleMessages('ko', KoMessages());
    timeago.setLocaleMessages('pl', PlMessages());
    timeago.setLocaleMessages('pt-br', PtBrMessages());
    timeago.setLocaleMessages('ru', RuMessages());
    timeago.setLocaleMessages('zh-cht', ZhMessages());
    timeago.setLocaleMessages('zh-chs', ZhMessages());
  }

  Map<String, String> languageNames = {
    'de': "Deutsch",
    'en': "English",
    'es': "Español",
    'es-mx': "Español mexicano",
    'fr': "Français",
    'it': "Italiano",
    'ja': "日本語",
    'ko': "한국어",
    'pl': "Polski",
    'pt-br': "Português Brasileiro",
    'ru': "Русский",
    'zh-cht': "繁體中文",
    'zh-chs': "简体中文"
  };

  Future<String> getTranslation(String text,
      {String languageCode, Map<String, String> replace = const {}}) async {
    if (text == null || text.length == 0) return "";
    String code = languageCode ?? currentLanguage;

    Map<String, String> translationMap = await _getTranslationMap(code);
    if (translationMap != null && translationMap.containsKey(text)) {
      return _replace(translationMap[text], replace);
    }

    translationMap = await _getTranslationMap(fallbackLanguage);
    if (translationMap != null && translationMap.containsKey(text)) {
      return _replace(translationMap[text], replace);
    }

    return _replace(text, replace);
  }

  String _replace(String text, Map<String, String> replace) {
    replace.forEach((String index, String replaceText) {
      text = text.replaceAll("{$index}", replaceText);
    });
    return text;
  }

  Future<Map<String, String>> _getTranslationMap(String languageCode) async {
    if (_translationMaps.containsKey(languageCode)) {
      return _translationMaps[languageCode];
    }
    var translations = await _loadTranslationMapFromSavedData(languageCode);
    if (translations == null) {
      translations = await _updateTranslationsFromWeb(languageCode);
      return translations;
    } else {
      _updateTranslationsFromWeb(languageCode);
    }
    return translations;
  }

  Future<Map<String, String>> _updateTranslationsFromWeb(
      String languageCode) async {
    var url =
        "https://cdn.jsdelivr.net/gh/LittleLightForDestiny/LittleLightTranslations/languages/$languageCode.json";
    var req = await http.get(Uri.parse(url));
    var raw = req.body;
    _languageStorage(languageCode).saveRawFile(
        StorageKeys.rawData, StorageKeys.littleLightTranslation.path, raw);
    Map<String, String> translation = Map<String, String>.from(jsonDecode(raw));
    _translationMaps[languageCode] = translation;
    return _translationMaps[languageCode];
  }

  Future<Map<String, String>> _loadTranslationMapFromSavedData(
      String languageCode) async {
    try {
      var storage = _languageStorage(languageCode);
      String raw = await storage.getRawFile(
          StorageKeys.rawData, StorageKeys.littleLightTranslation.path);
      Map<String, String> translation =
          Map<String, String>.from(jsonDecode(raw));
      _translationMaps[languageCode] = translation;
      return _translationMaps[languageCode];
    } catch (e) {
      print(e);
    }
    return null;
  }
}
