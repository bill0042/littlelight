import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/starting_page/starting_page.provider.dart';

mixin StartingPageConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  StartingPage get startingPage => ref.read(startingPageProvider);
}