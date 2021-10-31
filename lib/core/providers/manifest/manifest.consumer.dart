import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'manifest.provider.dart';

mixin ManifestConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Manifest get manifest => ref.read(manifestProvider);
}

mixin ManifestConsumerWidget on ConsumerWidget {
  Manifest manifest(WidgetRef ref) => ref.read(manifestProvider);
}
