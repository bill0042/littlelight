import 'dart:ui';

import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class TriumphSubcategoriesListWidget extends StatefulWidget {
  final int presentationNodeHash;
  TriumphSubcategoriesListWidget(this.presentationNodeHash, {Key key})
      : super(key: key);

  @override
  _TriumphSubcategoriesListWidgetState createState() =>
      _TriumphSubcategoriesListWidgetState();
}

class _TriumphSubcategoriesListWidgetState
    extends State<TriumphSubcategoriesListWidget> {
  DestinyPresentationNodeDefinition presentationNodeDefinition;

  @override
  void initState() {
    super.initState();
    getDefinition();
  }

  void getDefinition() async {
    presentationNodeDefinition = await ManifestService()
        .getDefinition<DestinyPresentationNodeDefinition>(
            widget.presentationNodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (nodes == null) return LoadingAnimWidget();
    final mq = MediaQuery.of(context);
    return ListView.builder(
        padding:
            EdgeInsets.all(8).copyWith(top: 0, bottom: 8 + mq.padding.bottom),
        itemCount: nodes.length,
        itemBuilder: (context, index) => buildSubCategoryListItem(
            context, nodes[index].presentationNodeHash));
  }

  List<DestinyPresentationNodeChildEntry> get nodes =>
      presentationNodeDefinition?.children?.presentationNodes;

  Widget buildSubCategoryListItem(BuildContext context, int hash) {
    final color = Theme.of(context).colorScheme.onPrimary.withOpacity(0.5);
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: color),
      ),
      child: ManifestText<DestinyPresentationNodeDefinition>(
        hash,
        style: TextStyle(color: color, fontSize: 15),
        uppercase: true,
      ),
    );
  }
}
