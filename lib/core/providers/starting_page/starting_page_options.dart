enum StartingPageOptions {
  Equipment,
  Collections,
  Triumphs,
  Loadouts,
  Progress,
  DuplicatedItems,
  Search
}

extension StartingPageString on StartingPageOptions {
  String asString() => this.toString().split(".").last;
  bool isEqual(String str) => asString() == str;
}

const List<StartingPageOptions> publicPages = [
  StartingPageOptions.Collections,
  StartingPageOptions.Triumphs,
];