import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final envProvider = Provider<DotEnv>((_) => DotEnv());
