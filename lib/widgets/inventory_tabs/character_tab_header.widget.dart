import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_character_progression_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_api/bungie_api_config.consumer.dart';
import 'package:little_light/core/providers/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';

class TabHeaderWidget extends ConsumerStatefulWidget {
  final DestinyCharacterComponent character;

  final ProfileService profile = ProfileService();
  @override
  TabHeaderWidget(this.character, {Key key}) : super(key: key);

  @override
  TabHeaderWidgetState createState() => TabHeaderWidgetState();
}

class TabHeaderWidgetState extends ConsumerState<TabHeaderWidget>
    with BungieApiConfigConsumerState, ManifestConsumerState {
  DestinyInventoryItemDefinition emblemDefinition;

  DestinyCharacterProgressionComponent progression;
  @override
  void initState() {
    if (widget.character != null) {
      progression =
          widget.profile.getCharacterProgression(widget.character.characterId);
    }

    super.initState();
    getDefinitions();
  }

  getDefinitions() async {
    emblemDefinition =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(
            widget.character.emblemHash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (emblemDefinition == null) {
      return Container(
        color: Theme.of(context).backgroundColor,
      );
    }
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[emblemBackground(context), powerBar(context)],
        ),
        emblemIcon(context)
      ],
    );
  }

  Widget emblemIcon(BuildContext context) {
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Colors.transparent,
        highlightColor: Colors.white,
        child: Icon(
          DestinyData.getClassIcon(widget.character.classType),
          size: 56,
        ));
    double top = getTopPadding(context) + 10;
    return Positioned(
        left: kToolbarHeight,
        top: top,
        width: kToolbarHeight + 8,
        height: kToolbarHeight + 8,
        child: QueuedNetworkImage(
          key: Key("secondary_overlay_${emblemDefinition.hash}"),
          imageUrl: apiConfig.bungieUrl(emblemDefinition.secondaryOverlay),
          fit: BoxFit.fill,
          placeholder: shimmer,
        ));
  }

  Widget emblemBackground(BuildContext context) {
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .1),
        highlightColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .3),
        child: Container(color: Colors.white));
    double height = getTopPadding(context) + kToolbarHeight;
    return Container(
        height: height,
        color: Theme.of(context).backgroundColor,
        child: QueuedNetworkImage(
          key: Key("secondary_special_${emblemDefinition.hash}"),
          imageUrl: apiConfig.bungieUrl(emblemDefinition.secondarySpecial),
          placeholder: shimmer,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ));
  }

  Widget powerBar(BuildContext context) {
    var settings = DestinySettingsService();
    DestinyProgression levelProg =
        progression.progressions["${settings.seasonalRankProgressionHash}"];
    DestinyProgression overLevelProg = progression
        .progressions["${settings.seasonalPrestigeRankProgressionHash}"];
    Color fg = Colors.cyan.shade300;
    Color bg = Color.lerp(Colors.black, fg, .6);
    Color shine = Colors.cyan.shade100;
    DestinyProgression currentProg =
        (levelProg?.level ?? 0) < (levelProg?.levelCap ?? 0)
            ? levelProg
            : overLevelProg;
    double completed = (currentProg?.progressToNextLevel ?? 0) /
        (currentProg?.nextLevelAt ?? 1);
    return Container(
      height: 2,
      color: bg,
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: completed,
        child: Shimmer.fromColors(
            baseColor: fg,
            period: Duration(seconds: 2),
            highlightColor: shine,
            child: Container(
              color: Colors.white,
            )),
      ),
    );
  }

  double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
