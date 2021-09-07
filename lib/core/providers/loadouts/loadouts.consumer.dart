import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/loadouts/loadouts.provider.dart';

mixin LoadoutsConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  LoadoutsService get loadoutsService => ref.read(loadoutsProvider);
}
