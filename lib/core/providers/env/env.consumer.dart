import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/env/env.provider.dart';

mixin EnvConsumer {
  WidgetRef ref;
  DotEnv get dotEnv => ref.read(envProvider);
  Map<String, String> get env => dotEnv.env;
}
