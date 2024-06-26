enum AccountStorageKeys { latestToken, latestTokenDate, membershipData }

extension StorageKeyPathsExtension on AccountStorageKeys {
  String get path {
    String name = toString().split(".")[1];
    return name;
  }
}
