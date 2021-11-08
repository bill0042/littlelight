import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/core/providers/profile/profile.provider.dart';

mixin ProfileConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Profile get profile => ref.read(profileProvider);
}

mixin ProfileConsumerWidget on ConsumerWidget {
  Profile profile(WidgetRef ref) => ref.read(profileProvider);
}

const List<int> ProfileBuckets = [
  InventoryBucket.modifications,
  InventoryBucket.shaders,
  InventoryBucket.consumables
];
