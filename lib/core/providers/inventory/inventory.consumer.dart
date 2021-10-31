import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory.provider.dart';

mixin InventoryConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Inventory get inventory => ref.read(inventoryProvider);
}

mixin InventoryConsumerWidget on ConsumerWidget {
  Inventory inventory(WidgetRef ref) => ref.read(inventoryProvider);
}
