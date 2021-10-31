import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_config.consumer.dart';
import 'package:little_light/core/providers/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class LoadoutBackgroundItemWidget extends ConsumerStatefulWidget {
  final ProfileService profile = ProfileService();
  final int hash;
  LoadoutBackgroundItemWidget({Key key, this.hash}) : super(key: key);

  @override
  createState() {
    return LoadoutBackgroundItemWidgetState();
  }
}

class LoadoutBackgroundItemWidgetState
    extends ConsumerState<LoadoutBackgroundItemWidget>
    with BungieApiConfigConsumerState, ManifestConsumerState {
  DestinyInventoryItemDefinition definition;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  void loadDefinitions() async {
    var collectible =
        await manifest.getDefinition<DestinyCollectibleDefinition>(widget.hash);
    definition = await manifest
        .getDefinition<DestinyInventoryItemDefinition>(collectible?.itemHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildEmblemBackground(context),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey.shade300, width: 1)),
    );
  }

  buildPlaceholder(BuildContext context) {
    return ShimmerHelper.getDefaultShimmer(context);
  }

  buildEmblemBackground(BuildContext context) {
    if (definition == null) return buildPlaceholder(context);
    String url = apiConfig.bungieUrl(definition.secondarySpecial);
    if (url == null) return buildPlaceholder(context);
    return Stack(children: [
      Positioned.fill(
          child: QueuedNetworkImage(
        alignment: Alignment.centerLeft,
        fadeInDuration: Duration(milliseconds: 300),
        imageUrl: "$url",
        fit: BoxFit.cover,
        placeholder: buildPlaceholder(context),
      )),
      Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, definition.hash);
                },
              )))
    ]);
  }
}
