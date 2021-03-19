import 'package:bungie_api/enums/destiny_scope.dart';
import 'package:bungie_api/models/destiny_presentation_node_component.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

typedef OnTriumphCategoryTap = Function(int nodeHash);

class TriumphCategoryItemWidget extends StatefulWidget {
  final int nodeHash;
  final OnTriumphCategoryTap onTap;

  TriumphCategoryItemWidget({Key key, this.nodeHash, this.onTap})
      : super(key: key);
  @override
  _TriumphCategoryItemWidgetState createState() =>
      _TriumphCategoryItemWidgetState();
}

class _TriumphCategoryItemWidgetState extends State<TriumphCategoryItemWidget> {
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    getDefinition();
  }

  void getDefinition() async {
    definition = await ManifestService()
        .getDefinition<DestinyPresentationNodeDefinition>(widget.nodeHash);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return ShimmerHelper.getDefaultShimmer(context);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Positioned(
          child: buildIcon(context),
          top: 0,
          left: 0,
          right: 0,
        ),
        Positioned(bottom: 0, child: buildTriumphScore(context))
      ],
    );
  }

  buildIcon(BuildContext context) => AspectRatio(
      aspectRatio: 1,
      child: Stack(alignment: Alignment.center, children: [
        Image.asset(
          "assets/imgs/triumph_bg.png",
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
        QueuedNetworkImage(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          imageUrl: BungieApiService.url(definition.originalIcon),
        ),
        Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
              onTap: widget.onTap != null
                  ? () => widget.onTap(widget.nodeHash)
                  : null),
        )
      ]));

  buildTriumphScore(BuildContext context) {
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
