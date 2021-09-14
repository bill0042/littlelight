import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/item_notes/item_notes.provider.dart';

mixin ItemNotesConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  ItemNotesService get itemNotesService => ref.read(itemNotesProvider);
}

mixin ItemNotesConsumerWidget on ConsumerWidget {
  ItemNotesService itemNotesService(WidgetRef ref) =>
      ref.read(itemNotesProvider);
}
