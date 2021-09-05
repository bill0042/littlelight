import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/wishlists/wishlists.provider.dart';

mixin WishlistsConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  WishlistsProviderService get wishlistsService => ref.read(wishlistProvider);
}

mixin WishlistsConsumerWidget on ConsumerWidget {
  WishlistsProviderService wishlistsService(WidgetRef ref) =>
      ref.read(wishlistProvider);
}
