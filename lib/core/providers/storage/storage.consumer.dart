import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/storage/storage.provider.dart';

class StorageContainer {
  WidgetRef _ref;
  StorageContainer._(this._ref);
  GlobalStorage get global => _ref.read(globalStorageProvider);
  Storage get account => _ref.read(currentAccountStorageProvider);
  Storage get language => _ref.read(currentLanguageStorageProvider);
  Storage get membership => _ref.read(currentMembershipStorageProvider);
  Storage byAccount(String id) => _ref.read(accountStorageProvider(id));
  Storage byLanguage(String code) => _ref.read(languageStorageProvider(code));
  Storage byMembership(String id) => _ref.read(membershipStorageProvider(id));
}

mixin StorageConsumerState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  StorageContainer get storage => StorageContainer._(ref);
}

mixin StorageConsumerWidget on ConsumerWidget {
  StorageContainer storage(WidgetRef ref) => StorageContainer._(ref);
}
