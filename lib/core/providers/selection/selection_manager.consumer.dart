
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/selection/selection_manager.provider.dart';


mixin SelectionConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  SelectionManager get selection => ref.read(selectionManagerProvider);
}

mixin SelectionConsumerWidget on ConsumerWidget {
  SelectionManager selection(WidgetRef ref) => ref.read(selectionManagerProvider);
}
