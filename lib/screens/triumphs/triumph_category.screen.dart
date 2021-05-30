import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/mixins/route_params.mixin.dart';
import 'package:little_light/routes/triumph_category.route.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:little_light/widgets/triumphs/triumph_subcategories_list.widget.dart';
import 'package:little_light/widgets/triumphs/triumph_subcategories_tab_bar.widget.dart';

class TriumphCategoryScreen extends StatefulWidget {
  TriumphCategoryScreen({Key key}) : super(key: key);
  @override
  _TriumphCategoryScreenState createState() => _TriumphCategoryScreenState();
}

class _TriumphCategoryScreenState extends State<TriumphCategoryScreen>
    with RouteParams<TriumphCategoryRouteArguments> {
  DestinyPresentationNodeDefinition definition;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    getDefinition();
  }

  int get triumphCategoryNodeHash =>
      getRouteParams(context).presentationNodeHash;

  getDefinition() async {
    print(triumphCategoryNodeHash);
    definition = await ManifestService()
        .getDefinition<DestinyPresentationNodeDefinition>(
            triumphCategoryNodeHash);

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    return bodyPortrait(context);
  }

  Widget bodyPortrait(BuildContext context) {
    return subCategoriesMenu(context);
  }

  Widget subCategoriesMenu(BuildContext context) {
    return DefaultTabController(
        length: definition.children.presentationNodes.length,
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.all(8),
                child: TriumphSubcategoriesTabBarWidget(definition)),
            Row(children: [Icon(LittleLightIcons.triumph)]),
            Expanded(
                child: TabBarView(
              children: definition.children.presentationNodes
                  .map(
                      (p) => subcategoriesList(context, p.presentationNodeHash))
                  .toList(),
            ))
          ],
        ));
  }

  Widget subcategoriesList(BuildContext context, int nodeHash) {
    return TriumphSubcategoriesListWidget(nodeHash);
  }

  AppBar appBar(BuildContext context) => AppBar(
      leading: BackButton(), centerTitle: false, title: appBarTitle(context));

  Widget appBarTitle(BuildContext context) {
    if (definition == null) return Container();
    return Row(
      children: [
        Container(
            height: kToolbarHeight,
            child: QueuedNetworkImage(
              fit: BoxFit.fitHeight,
              imageUrl: BungieApiService.url(definition.displayProperties.icon),
            )),
        Text(definition.displayProperties.name)
      ],
    );
  }
}
