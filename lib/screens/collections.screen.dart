import 'package:flutter/material.dart';
import 'package:little_light/core/providers/bungie_auth/bungie_auth.consumer.dart';
import 'package:little_light/core/providers/destiny_settings/destiny_settings.consumer.dart';
import 'package:little_light/core/providers/profile/component_groups.dart';
import 'package:little_light/core/providers/profile/profile.consumer.dart';
import 'package:little_light/core/providers/starting_page/starting_page.consumer.dart';
import 'package:little_light/core/providers/starting_page/starting_page_options.dart';
import 'package:little_light/screens/collectible_search.screen.dart';
import 'package:little_light/screens/presentation_node.screen.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/presentation_nodes/collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/nested_collectible_item.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';

class CollectionsScreen extends PresentationNodeScreen {
  CollectionsScreen({int presentationNodeHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeScreenState createState() => CollectionsScreenState();
}

class CollectionsScreenState
    extends PresentationNodeScreenState<CollectionsScreen>
    with
        BungieAuthConsumerState,
        DestinySettingsConsumerState,
        ProfileConsumerState,
        StartingPageConsumerState {
  Map<int, List<ItemWithOwner>> itemsByHash;
  @override
  void initState() {
    profile.updateComponents = ProfileComponentGroups.collections;
    profile.fetchProfileData();
    startingPage.saveLatestScreen(
        StartingPageOptions.Collections);
    if (auth.isLogged) {
      this.loadItems();
    }
    super.initState();
  }

  loadItems() async {
    List<ItemWithOwner> allItems = [];
    Iterable<String> charIds =
        profile.getCharacters().map((char) => char.characterId);
    charIds.forEach((charId) {
      allItems.addAll(profile
          .getCharacterEquipment(charId)
          .map((item) => ItemWithOwner(item, charId)));
      allItems.addAll(profile
          .getCharacterInventory(charId)
          .map((item) => ItemWithOwner(item, charId)));
    });
    allItems.addAll(
        profile.getProfileInventory().map((item) => ItemWithOwner(item, null)));
    Map<int, List<ItemWithOwner>> itemsByHash = {};
    allItems.forEach((i) {
      int hash = i.item.itemHash;
      if (!itemsByHash.containsKey(hash)) {
        itemsByHash[hash] = [];
      }
      itemsByHash[hash].add(i);
    });
    this.itemsByHash = itemsByHash;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context), body: buildScaffoldBody(context));
  }

  Widget itemBuilder(CollectionListItem item, int depth, bool isCategorySet) {
    switch (item.type) {
      case CollectionListItemType.nestedCollectible:
        return NestedCollectibleItemWidget(
            hash: item.hash, itemsByHash: itemsByHash);

      case CollectionListItemType.collectible:
        return CollectibleItemWidget(
          hash: item.hash,
          itemsByHash: itemsByHash,
        );

      default:
        return super.itemBuilder(item, depth, isCategorySet);
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    return PresentationNodeTabsWidget(
      presentationNodeHashes: [
        destinySettings.collectionsRootNode,
        destinySettings.badgesRootNode
      ],
      depth: 0,
      itemBuilder: this.itemBuilder,
      tileBuilder: this.tileBuilder,
    );
  }

  buildAppBar(BuildContext context) {
    if (widget.depth == 0) {
      return AppBar(
          leading: IconButton(
            enableFeedback: false,
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: <Widget>[
            IconButton(
              enableFeedback: false,
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollectibleSearchScreen(),
                  ),
                );
              },
            )
          ],
          title: TranslatedTextWidget("Collections"));
    }
    return AppBar(title: Text(definition?.displayProperties?.name ?? ""));
  }
}
