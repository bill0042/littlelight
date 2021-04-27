import 'dart:ui';

import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class TriumphSubcategoriesTabBarWidget extends StatelessWidget {
  final DestinyPresentationNodeDefinition presentationNodeDefinition;

  TriumphSubcategoriesTabBarWidget(this.presentationNodeDefinition, {Key key})
      : super(key: key);

  TabController getController(BuildContext context) =>
      DefaultTabController.of(context);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      parent: getController(context).animation,
      curve: Curves.fastOutSlowIn,
    );
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget child) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(getController(context).length,
                  (index) => selector(context, index)),
            ));
  }

  List<DestinyPresentationNodeChildEntry> get nodes =>
      presentationNodeDefinition.children.presentationNodes;

  selector(BuildContext context, int index) {
    double value = index.toDouble() - getController(context).animation.value;
    value = value.abs().clamp(0.0, 1.0);
    var node = nodes[index];
    return Expanded(
        child: Opacity(
            opacity: lerpDouble(.8, .3, value),
            child: Container(
              margin: EdgeInsets.only(
                right: node == nodes.last ? 0 : 2,
                left: node == nodes.first ? 0 : 2,
              ),
              height: kToolbarHeight,
              child: Material(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withOpacity(lerpDouble(.3, 0, value)),
                  child: InkWell(
                      onTap: () {
                        getController(context).animateTo(index);
                      },
                      child: buildSubCategoryTab(
                          context, node.presentationNodeHash))),
            )));
  }

  Widget buildSubCategoryTab(BuildContext context, int hash) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
        ),
        padding: EdgeInsets.all(4),
        child: ManifestImageWidget<DestinyPresentationNodeDefinition>(hash));
  }
}
