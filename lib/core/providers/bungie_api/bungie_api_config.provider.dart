import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/env/env.provider.dart';

final bungieApiConfigProvider =
    Provider<BungieApiConfig>((ref) => BungieApiConfig(ref));

class BungieApiConfig {
  ProviderRef _ref;
  DotEnv get _env => _ref.read(envProvider);

  BungieApiConfig(this._ref);

  String baseUrl = 'https://www.bungie.net';

  String get apiUrl => "$baseUrl/Platform";

  String get clientSecret => _env.env['client_secret'];

  String get apiKey => _env.env['api_key'];

  String get clientId => _env.env['client_id'];

  String bungieUrl(String path) => "$baseUrl$path";
}
