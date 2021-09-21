import 'package:bungie_api/enums/destiny_presentation_screen_style.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/littlelight_data/littlelight_data.consumer.dart';
import 'package:little_light/models/game_data.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_list.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';

class PresentationNodeBodyWidget extends ConsumerStatefulWidget {
  final ManifestService manifest = ManifestService();
  final ProfileService profile = ProfileService();
  final PresentationNodeItemBuilder itemBuilder;
  final PresentationNodeTileBuilder tileBuilder;
  final int presentationNodeHash;
  final int depth;
  final bool isCategorySet;
  PresentationNodeBodyWidget(
      {this.presentationNodeHash,
      this.itemBuilder,
      this.tileBuilder,
      this.depth = 0,
      this.isCategorySet = false});

  @override
  PresentationNodeBodyWidgetState createState() =>
      PresentationNodeBodyWidgetState();
}

class PresentationNodeBodyWidgetState<T extends PresentationNodeBodyWidget>
    extends ConsumerState<PresentationNodeBodyWidget> 
    with LittleLightDataConsumerState{
  DestinyPresentationNodeDefinition definition;
  GameData gameData;

  @override
  void initState() {
    super.initState();
    if (definition == null && widget.presentationNodeHash != null) {
      loadDefinition();
    }
  }

  loadDefinition() async {
    definition = await widget.manifest
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    gameData = await littlelightData.getGameData();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (definition?.children == null) return Container();
    print(widget.presentationNodeHash);
    if (gameData?.tabbedPresentationNodes
            ?.contains(widget.presentationNodeHash) ??
        false) return tabBuilder();
    if (definition?.children?.presentationNodes?.length == 1) {
      return tabBuilder();
    }
    return listBuilder();
  }

  Widget tabBuilder() {
    return PresentationNodeTabsWidget(
        presentationNodeHash: widget.presentationNodeHash,
        depth: widget.depth,
        itemBuilder: widget.itemBuilder,
        tileBuilder: widget.tileBuilder,
        isCategorySet: widget.isCategorySet ??
            definition?.screenStyle ==
                DestinyPresentationScreenStyle.CategorySets);
  }

  Widget listBuilder() {
    return PresentationNodeListWidget(
      presentationNodeHash: widget.presentationNodeHash,
      isCategorySets: widget.isCategorySet,
      depth: widget.depth,
      itemBuilder: widget.itemBuilder,
      tileBuilder: widget.tileBuilder,
    );
  }
}
