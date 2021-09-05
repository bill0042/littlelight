import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/global_container/global.container.dart';

final envProvider = Provider<DotEnv>((_) => DotEnv());

get globalEnvProvider => globalContainer.read(envProvider);
