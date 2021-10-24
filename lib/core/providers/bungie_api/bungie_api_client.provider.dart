import 'dart:convert';
import 'dart:io' as io;

import 'package:bungie_api/helpers/bungie_net_token.dart';
import 'package:bungie_api/helpers/http.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_config.provider.dart';
import 'package:little_light/core/providers/bungie_auth/bungie_auth.provider.dart';


import 'exceptions/bungie_api.exception.dart';

typedef BungieApiClient ClientBuilder(
    {BungieNetToken token, bool autoRefreshToken});

final Provider<ClientBuilder> bungieApiClientBuilderProvider = Provider<ClientBuilder>(
    (ref) => ({BungieNetToken token, bool autoRefreshToken}) =>
        _clientBuilder(ref, token: token, autoRefreshToken: autoRefreshToken));

BungieApiClient _clientBuilder(ProviderRef ref,
        {BungieNetToken token, bool autoRefreshToken = true}) =>
    BungieApiClient._(ref, token: token, autoRefreshToken: autoRefreshToken);

class BungieApiClient implements HttpClient {
  ProviderRef _ref;
  bool autoRefreshToken;
  int retries = 0;

  BungieApiConfig get config => _ref.read(bungieApiConfigProvider);

  BungieNetToken token;

  BungieAuth get auth => _ref.read(bungieAuthProvider);

  BungieApiClient._(this._ref, {this.token, this.autoRefreshToken = true});

  @override
  Future<HttpResponse> request(HttpClientConfig config) async {
    var req = await _request(config);
    return req;
  }

  Future<HttpResponse> _request(HttpClientConfig clientConfig) async {
    Map<String, String> headers = {
      'X-API-Key': config.apiKey,
      'Accept': 'application/json'
    };
    if (clientConfig.bodyContentType != null) {
      headers['Content-Type'] = clientConfig.bodyContentType;
    }
    if (this.token != null) {
      headers['Authorization'] = "Bearer ${this.token.accessToken}";
    }
    String paramsString = "";
    if (clientConfig.params != null) {
      clientConfig.params.forEach((name, value) {
        String valueStr;
        if (value is String) {
          valueStr = value;
        }
        if (value is num) {
          valueStr = "$value";
        }
        if (value is List) {
          valueStr = value.join(',');
        }
        if (paramsString.length == 0) {
          paramsString += "?";
        } else {
          paramsString += "&";
        }
        paramsString += "$name=$valueStr";
      });
    }

    io.HttpClientResponse response;
    io.HttpClient client = io.HttpClient();

    if (clientConfig.method == 'GET') {
      var req = await client.getUrl(
          Uri.parse("${config.apiUrl}${clientConfig.url}$paramsString"));
      headers.forEach((name, value) {
        req.headers.add(name, value);
      });
      response = await req.close().timeout(Duration(seconds: 12));
    } else {
      String body = clientConfig.bodyContentType == 'application/json'
          ? jsonEncode(clientConfig.body)
          : clientConfig.body;
      var req = await client.postUrl(
          Uri.parse("${config.apiUrl}${clientConfig.url}$paramsString"));
      headers.forEach((name, value) {
        req.headers.add(name, value);
      });
      req.write(body);
      response = await req.close().timeout(Duration(seconds: 12));
    }

    if (response.statusCode == 401 && autoRefreshToken) {
      this.token = await auth.refreshToken(token);
      return _request(clientConfig);
    }
    dynamic json;
    try {
      var stream = response.transform(Utf8Decoder());
      var text = "";
      await for (var t in stream) {
        text += t;
      }
      json = jsonDecode(text ?? "{}");
    } catch (e) {
      json = {};
    }

    if (response.statusCode != 200) {
      throw BungieApiException.fromJson(json, response.statusCode);
    }

    if (json["ErrorCode"] != null && json["ErrorCode"] > 2) {
      throw BungieApiException.fromJson(json, response.statusCode);
    }
    return HttpResponse(json, response.statusCode);
  }
}
