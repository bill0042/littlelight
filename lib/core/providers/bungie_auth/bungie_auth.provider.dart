import 'dart:async';
import 'dart:io';

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api.provider.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_config.provider.dart';
import 'package:little_light/core/providers/global_container/global.container.dart';
import 'package:little_light/core/providers/storage/storage.provider.dart';
import 'package:little_light/core/providers/storage/storage_keys.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

bool initialLinkHandled = false;

final bungieAuthProvider = Provider<BungieAuth>((ref) => BungieAuth._(ref));

BungieAuth get globalBungieAuthProvider =>
    globalContainer.read(bungieAuthProvider);

class BungieAuth {
  BungieApi get _bungieApi => _ref.read(bungieApiProvider);
  BungieApiConfig get _bungieApiConfig => _ref.read(bungieApiConfigProvider);
  Storage get accountStorage => _ref.read(currentAccountStorageProvider);
  Storage get languageStorage => _ref.read(currentAccountStorageProvider);
  GlobalStorage get globalStorage => _ref.read(globalStorageProvider);

  BungieNetToken _currentToken;
  GroupUserInfoCard _currentMembership;
  UserMembershipData _membershipData;
  bool waitingAuthCode = false;

  ProviderRef _ref;

  StreamSubscription<String> linkStreamSub;

  BungieAuth._(this._ref);

  Future<BungieNetToken> _getStoredToken() async {
    var json = await accountStorage.getJson(StorageKeys.latestToken);
    try {
      return BungieNetToken.fromJson(json);
    } catch (e) {
      print(
          "failed retrieving token for account: ${globalStorage.getAccount()}");
      print(e);
    }
    return null;
  }

  Future<BungieNetToken> refreshToken(BungieNetToken token) async {
    BungieNetToken bNetToken =
        await _bungieApi.refreshToken(token.refreshToken);
    _saveToken(bNetToken);
    return bNetToken;
  }

  Future<void> _saveToken(BungieNetToken token) async {
    if (token?.accessToken == null) {
      return;
    }
    await globalStorage.setAccount(token.membershipId);
    await accountStorage.setJson(StorageKeys.latestToken, token.toJson());
    await accountStorage.setDate(StorageKeys.latestTokenDate, DateTime.now());
    await Future.delayed(Duration(milliseconds: 1));
    _currentToken = token;
  }

  Future<BungieNetToken> getToken() async {
    BungieNetToken token = _currentToken;
    if (token == null) {
      token = await _getStoredToken();
    }
    if (token?.accessToken == null || token?.expiresIn == null) {
      return null;
    }
    DateTime now = DateTime.now();
    DateTime savedDate = accountStorage.getDate(StorageKeys.latestTokenDate);
    DateTime expire = savedDate.add(Duration(seconds: token.expiresIn));
    DateTime refreshExpire =
        savedDate.add(Duration(seconds: token.refreshExpiresIn));
    if (refreshExpire.isBefore(now)) {
      return null;
    }
    if (expire.isBefore(now)) {
      token = await refreshToken(token);
    }
    return token;
  }

  Future<BungieNetToken> requestToken(String code) async {
    BungieNetToken token = await _bungieApi.requestToken(code);
    await _saveToken(token);
    return token;
  }

  Future<String> checkAuthorizationCode() async {
    Uri uri;
    if (!initialLinkHandled) {
      uri = await getInitialUri();
      initialLinkHandled = true;
    }

    if (uri?.queryParameters == null) return null;
    print("initialURI: $uri");
    if (uri.queryParameters.containsKey("code") ||
        uri.queryParameters.containsKey("error")) {
      closeWebView();
    }

    if (uri.queryParameters.containsKey("code")) {
      return uri.queryParameters["code"];
    } else {
      String errorType = uri.queryParameters["error"];
      String errorDescription =
          uri.queryParameters["error_description"] ?? uri.toString();
      throw OAuthException(errorType, errorDescription);
    }
  }

  Future<String> authorize([bool forceReauth = true]) async {
    String currentLanguage = globalStorage.getLanguage();
    var browser = BungieAuthBrowser();
    OAuth.openOAuth(
        browser, _bungieApiConfig.clientId, currentLanguage, forceReauth);
    Stream<String> _stream = linkStream;
    Completer<String> completer = Completer();

    linkStreamSub?.cancel();

    linkStreamSub = _stream.listen((link) {
      Uri uri = Uri.parse(link);
      if (uri.queryParameters.containsKey("code") ||
          uri.queryParameters.containsKey("error")) {
        closeWebView();
        linkStreamSub.cancel();
      }
      if (uri.queryParameters.containsKey("code")) {
        String code = uri.queryParameters["code"];
        completer.complete(code);
      } else {
        String errorType = uri.queryParameters["error"];
        String errorDescription = uri.queryParameters["error_description"];
        try {
          throw OAuthException(errorType, errorDescription);
        } on OAuthException catch (e, stack) {
          completer.completeError(e, stack);
        }
      }
    });

    return completer.future;
  }

  Future<UserMembershipData> updateMembershipData() async {
    UserMembershipData membershipData = await _bungieApi.getMemberships();
    await accountStorage.setJson(StorageKeys.membershipData, membershipData);
    return membershipData;
  }

  Future<UserMembershipData> getMembershipData() async {
    return _membershipData ?? await _getStoredMembershipData();
  }

  Future<UserMembershipData> _getStoredMembershipData() async {
    var json = await accountStorage.getJson(StorageKeys.membershipData);
    if (json == null) {
      return null;
    }
    UserMembershipData membershipData = UserMembershipData.fromJson(json);
    return membershipData;
  }

  void reset() {
    _currentMembership = null;
    _currentToken = null;
    _membershipData = null;
  }

  Future<GroupUserInfoCard> getMembership() async {
    if (_currentMembership == null) {
      var _membershipData = await _getStoredMembershipData();
      var _membershipId = globalStorage.getMembership();
      _currentMembership = getMembershipById(_membershipData, _membershipId);
    }
    if (_currentMembership?.membershipType ==
        BungieMembershipType.TigerBlizzard) {
      var account = globalStorage.getAccount();
      globalStorage.removeAccount(account);
      return null;
    }
    return _currentMembership;
  }

  GroupUserInfoCard getMembershipById(
      UserMembershipData membershipData, String membershipId) {
    return membershipData?.destinyMemberships?.firstWhere(
        (membership) => membership?.membershipId == membershipId,
        orElse: () => membershipData?.destinyMemberships?.first ?? null);
  }

  Future<void> saveMembership(
      UserMembershipData membershipData, String membershipId) async {
    _currentMembership = getMembershipById(membershipData, membershipId);
    accountStorage.setJson(StorageKeys.membershipData, membershipData.toJson());
    globalStorage.setMembership(membershipId);
  }

  bool get isLogged {
    return _currentMembership != null;
  }

  Future<void> logout() async{
    await accountStorage.remove(StorageKeys.latestToken, true);
  }
}

class BungieAuthBrowser implements OAuthBrowser {
  BungieAuthBrowser() : super();

  @override
  dynamic open(String url) async {
    if (Platform.isIOS) {
      await launch(url,
          forceSafariVC: true, statusBarBrightness: Brightness.light);
    } else {
      await launch(url, forceSafariVC: true);
    }
  }
}
