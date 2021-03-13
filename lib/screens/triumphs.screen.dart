import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/triumphs/seals_grid.widget.dart';
import 'package:little_light/widgets/triumphs/triumph_categories_grid.widget.dart';

class TriumphsScreen extends StatefulWidget {
  @override
  _TriumphsScreenState createState() => _TriumphsScreenState();
}

class _TriumphsScreenState extends State<TriumphsScreen> {
  DestinySettingsService settings = DestinySettingsService();

  Map<int, String> get rootNodesBgPaths => {
        settings.statsRootNode: "assets/imgs/triumphs-stats-list-item.png",
        settings.medalsRootNode: "assets/imgs/triumphs-medals-list-item.png",
        settings.loreRootNode: "assets/imgs/triumphs-lore-list-item.png",
        settings.exoticCatalystsRootNode:
            "assets/imgs/triumphs-catalysts-list-item.png",
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(context), body: body(context));
  }

  AppBar appBar(BuildContext context) => AppBar(
        leading: IconButton(
          enableFeedback: false,
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        centerTitle: false,
        title: ManifestText<DestinyPresentationNodeDefinition>(
            settings.triumphsRootNode),
      );

  Widget body(BuildContext context) => SingleChildScrollView(
      padding: EdgeInsets.all(8),
      child: Column(children: [
        TriumphCategoriesGridWidget(
          nodeHash: settings.triumphsRootNode,
          columns: MediaQueryHelper(context)
              .responsiveValue<int>(3, tablet: 4, laptop: 5, desktop: 8),
        ),
        SealsGridWidget(
          nodeHash: settings.sealsRootNode,
          rows: 1,
          columns: MediaQueryHelper(context)
              .responsiveValue<int>(4, tablet: 6, laptop: 8, desktop: 10),
        ),
        Container(height: 8),
        buildRootItem(context, settings.medalsRootNode),
        Container(height: 8),
        buildRootItem(context, settings.exoticCatalystsRootNode),
        Container(height: 8),
        buildRootItem(context, settings.loreRootNode),
        Container(height: 8),
        buildRootItem(context, settings.statsRootNode),
      ]));

  Widget buildRootItem(BuildContext context, int nodeHash) {
    return Container(
        key: Key("rootNode_$nodeHash"),
        child: DefinitionProviderWidget<DestinyPresentationNodeDefinition>(
            nodeHash,
            (def) => Stack(
                  children: [
                    Image.asset(rootNodesBgPaths[nodeHash]),
                    Positioned.fill(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(flex: 25, child: Container()),
                        Expanded(
                            flex: 75,
                            child: Container(
                                child: Text(
                              def.displayProperties.name.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )))
                      ],
                    ))
                  ],
                )));
  }
}
