import 'dart:async';

import 'package:bungie_api/api/destiny2.dart';
import 'package:bungie_api/api/settings.dart';
import 'package:bungie_api/api/user.dart';
import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:bungie_api/enums/destiny_vendor_filter.dart';
import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/oauth.dart';
import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:bungie_api/models/destiny_equip_item_result.dart';
import 'package:bungie_api/models/destiny_item_action_request.dart';
import 'package:bungie_api/models/destiny_item_set_action_request.dart';
import 'package:bungie_api/models/destiny_item_state_request.dart';
import 'package:bungie_api/models/destiny_item_transfer_request.dart';
import 'package:bungie_api/models/destiny_postmaster_transfer_request.dart';
import 'package:bungie_api/models/destiny_profile_response.dart';
import 'package:bungie_api/models/destiny_vendors_response.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:bungie_api/responses/destiny_profile_response_response.dart';
import 'package:bungie_api/responses/destiny_vendors_response_response.dart';
import 'package:bungie_api/responses/int32_response.dart';
import 'package:bungie_api/responses/user_membership_data_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_client.provider.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_config.provider.dart';
import 'package:little_light/core/providers/bungie_auth/bungie_auth.provider.dart';
import 'package:little_light/core/providers/global_container/global.container.dart';


final bungieApiProvider =
    Provider<BungieApi>((ref) => BungieApi._(ref));

BungieApi get globalBungieApiProvider => globalContainer.read(bungieApiProvider);

class BungieApi {
  ProviderRef _ref;

  BungieApi._(this._ref);

  BungieAuth get auth => _ref.read(bungieAuthProvider);

  BungieApiConfig get config => _ref.read(bungieApiConfigProvider);

  ClientBuilder get clientBuilder => _ref.read(bungieApiClientBuilderProvider);

  String get baseUrl => config.baseUrl;

  String url(String url) {
    if (url == null ?? url.length == 0) return null;
    if (url.contains('://')) return url;
    return "$baseUrl$url";
  }


  Future<DestinyManifestResponse> getManifest() {
    return Destiny2.getDestinyManifest(clientBuilder());
  }

  Future<BungieNetToken> requestToken(String code) {
    return OAuth.getToken(clientBuilder(), config.clientId, config.clientSecret, code);
  }

  Future<BungieNetToken> refreshToken(String refreshToken) {
    return OAuth.refreshToken(
        clientBuilder(autoRefreshToken: false), config.clientId, config.clientSecret, refreshToken);
  }

  Future<DestinyProfileResponse> getCurrentProfile(
      List<DestinyComponentType> components) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    if (membership == null) return null;
    var profile = await getProfile(
        components, membership.membershipId, membership.membershipType, token);
    return profile;
  }

  Future<DestinyProfileResponse> getProfile(
      List<DestinyComponentType> components,
      String membershipId,
      BungieMembershipType membershipType,
      [BungieNetToken token]) async {
    DestinyProfileResponseResponse response = await Destiny2.getProfile(
        clientBuilder(token: token), components, membershipId, membershipType);
    return response.response;
  }

  Future<DestinyVendorsResponse> getVendors(
      List<DestinyComponentType> components, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    if (membership == null) return null;
    DestinyVendorsResponseResponse response = await Destiny2.getVendors(
        clientBuilder(token: token),
        characterId,
        components,
        membership.membershipId,
        DestinyVendorFilter.None,
        membership.membershipType);
    return response.response;
  }

  Future<UserMembershipData> getMemberships() async {
    BungieNetToken token = await auth.getToken();
    UserMembershipDataResponse response =
        await User.getMembershipDataForCurrentUser(clientBuilder(token: token));
    return response.response;
  }

  Future<int> transferItem(int itemHash, int stackSize, bool transferToVault,
      String itemId, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    Int32Response response = await Destiny2.transferItem(
        clientBuilder(token: token),
        DestinyItemTransferRequest()
          ..itemReferenceHash = itemHash
          ..stackSize = stackSize
          ..transferToVault = transferToVault
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response;
  }

  Future<int> pullFromPostMaster(
      int itemHash, int stackSize, String itemId, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    Int32Response response = await Destiny2.pullFromPostmaster(
        clientBuilder(token: token),
        DestinyPostmasterTransferRequest()
          ..itemReferenceHash = itemHash
          ..stackSize = stackSize
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response;
  }

  Future<int> equipItem(String itemId, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    Int32Response response = await Destiny2.equipItem(
        clientBuilder(token: token),
        DestinyItemActionRequest()
          ..itemId = itemId
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response;
  }

  Future<int> changeLockState(
      String itemId, String characterId, bool locked) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    var response = await Destiny2.setItemLockState(
        clientBuilder(token: token),
        DestinyItemStateRequest()
          ..itemId = itemId
          ..membershipType = membership.membershipType
          ..characterId = characterId
          ..state = locked);
    return response.response;
  }

  Future<int> changeTrackState(
      String itemId, String characterId, bool tracked) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    var response = await Destiny2.setQuestTrackedState(
        clientBuilder(token: token),
        DestinyItemStateRequest()
          ..itemId = itemId
          ..membershipType = membership.membershipType
          ..characterId = characterId
          ..state = tracked);
    return response.response;
  }

  Future<List<DestinyEquipItemResult>> equipItems(
      List<String> itemIds, String characterId) async {
    BungieNetToken token = await auth.getToken();
    GroupUserInfoCard membership = await auth.getMembership();
    var response = await Destiny2.equipItems(
        clientBuilder(token: token),
        DestinyItemSetActionRequest()
          ..itemIds = itemIds
          ..characterId = characterId
          ..membershipType = membership.membershipType);
    return response.response.equipResults;
  }

  Future<CoreSettingsConfiguration> getCommonSettings() async {
    var response = await Settings.getCommonSettings(clientBuilder());
    return response.response;
  }
}

