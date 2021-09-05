import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/translations/translations.provider.dart';

mixin TranslationsConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  Translations get translations => ref.read(translationsProvider);
}

mixin TranslationsConsumerWidget on ConsumerWidget {
  Translations translations(WidgetRef ref) => ref.read(translationsProvider);
}
