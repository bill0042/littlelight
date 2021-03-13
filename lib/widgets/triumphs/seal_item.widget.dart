import 'package:bungie_api/enums/destiny_scope.dart';
import 'package:bungie_api/models/destiny_presentation_node_component.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class SealItemWidget extends StatefulWidget {
  final int nodeHash;

  SealItemWidget({Key key, this.nodeHash}) : super(key: key);
  @override
  _SealItemWidgetState createState() => _SealItemWidgetState();
}

class _SealItemWidgetState extends State<SealItemWidget> {
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
      children: [
        buildIcon(context),
        Positioned(child: buildLabel(context), top: 0),
        Positioned(child: buildTriumphScore(context), bottom: 0),
        Positioned.fill(
            child: Material(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.vertical(
                    top: Radius.zero, bottom: Radius.circular(100)),
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                )))
      ],
    );
  }

  buildIcon(BuildContext context) {
    var score = triumphScore;
    var complete = score.progressValue >= score.completionValue;
    return AspectRatio(
        aspectRatio: 1,
        child: Stack(fit: StackFit.expand, children: [
          Positioned.fill(
              child: Opacity(child: iconImage, opacity: complete ? 1 : .4)),
        ]));
  }

  Widget get iconImage => QueuedNetworkImage(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        imageUrl: BungieApiService.url(definition.displayProperties.icon),
      );

  Widget buildLabel(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).cardColor),
        child: ManifestText<DestinyRecordDefinition>(
          definition.completionRecordHash,
          textExtractor: (def) => def.titleInfo.titlesByGender["Male"],
          style: TextStyle(fontSize: 12),
        ));
  }

  Widget buildTriumphScore(BuildContext context) {
    var score = triumphScore;
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
            border: Border.all(
                width: .5, color: Theme.of(context).colorScheme.onPrimary),
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).cardColor),
        child: Text(
          "${score?.progressValue}/${score?.completionValue}",
          style: TextStyle(fontSize: 12),
        ));
  }

  DestinyPresentationNodeComponent get triumphScore {
    var profile = ProfileService();
    if (definition.scope == DestinyScope.Profile) {
      var profileNodes = profile.getProfilePresentationNodes();
      return profileNodes["${definition.hash}"];
    }
    var character = profile.getCharacters().first;
    var characterNodes =
        profile.getCharacterPresentationNodes(character.characterId);
    return characterNodes["${definition.hash}"];
  }
}
