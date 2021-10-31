import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/vendors/vendors.provider.dart';

mixin VendorsConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Vendors get vendors => ref.read(vendorsProvider);
}

mixin VendorsConsumerWidget on ConsumerWidget {
  Vendors vendors(WidgetRef ref) =>
      ref.read(vendorsProvider);
}
