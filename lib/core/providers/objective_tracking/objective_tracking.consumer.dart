import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/objective_tracking/objective_tracking.provider.dart';

mixin ObjectiveTrackingConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  ObjectiveTracking get objectiveTracking =>
      ref.read(objectiveTrackingProvider);
}
