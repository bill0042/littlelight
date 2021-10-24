import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_config.consumer.dart';

import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class TriumphCategoryItemWidget extends ConsumerStatefulWidget {
  final int nodeHash;

  TriumphCategoryItemWidget({Key key, this.nodeHash}) : super(key: key);
  @override
  _TriumphCategoryItemWidgetState createState() =>
      _TriumphCategoryItemWidgetState();
}

class _TriumphCategoryItemWidgetState
    extends ConsumerState<TriumphCategoryItemWidget>
    with BungieApiConfigConsumerState {
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    getDefinition();
  }

  void getDefinition() async {
    definition = await ManifestService()
        .getDefinition<DestinyPresentationNodeDefinition>(widget.nodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return ShimmerHelper.getDefaultShimmer(context);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Image.asset(
          "assets/imgs/triumph_bg.png",
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
        QueuedNetworkImage(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          imageUrl: apiConfig.bungieUrl(definition.originalIcon),
        )
      ],
    );
  }
}
