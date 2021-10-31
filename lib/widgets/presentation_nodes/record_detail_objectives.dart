import 'dart:async';

import 'package:bungie_api/enums/destiny_record_state.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_record_component.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/bungie_auth/bungie_auth.consumer.dart';
import 'package:little_light/core/providers/manifest/manifest.consumer.dart';
import 'package:little_light/core/providers/notification/events/notification.event.dart';
import 'package:little_light/core/providers/notification/notifications.consumer.dart';

import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class RecordObjectivesWidget extends ConsumerStatefulWidget {
  final ProfileService profile = ProfileService();
  final DestinyRecordDefinition definition;

  RecordObjectivesWidget({Key key, this.definition}) : super(key: key);

  @override
  RecordObjectivesWidgetState createState() {
    return RecordObjectivesWidgetState();
  }
}

class RecordObjectivesWidgetState extends ConsumerState<RecordObjectivesWidget>
    with BungieAuthConsumerState, ManifestConsumerState, NotificationsConsumerState {
  bool get isLogged => auth.isLogged;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  StreamSubscription<NotificationEvent> subscription;

  DestinyRecordDefinition get definition {
    return widget.definition;
  }

  @override
  void initState() {
    super.initState();
    loadDefinitions();
    if (isLogged) {
      listenToUpdates();
    }
  }

  @override
  void dispose() {
    if (subscription != null) subscription.cancel();
    super.dispose();
  }

  listenToUpdates() {
    subscription = notifications.listen((event) {
      if (!mounted) return;
      if (event.type == NotificationType.receivedUpdate) {
        setState(() {});
      }
    });
  }

  loadDefinitions() async {
    if (definition?.objectiveHashes != null) {
      objectiveDefinitions =
          await manifest.getDefinitions<DestinyObjectiveDefinition>(
              definition.objectiveHashes);
      if (mounted) setState(() {});
    }
  }

  DestinyRecordComponent get record {
    if (!isLogged) return null;
    return ProfileService().getRecord(definition.hash, definition.scope);
  }

  DestinyRecordState get recordState {
    return record?.state ?? DestinyRecordState.ObjectiveNotCompleted;
  }

  bool get completed {
    return !recordState.contains(DestinyRecordState.ObjectiveNotCompleted);
  }

  Color get foregroundColor {
    return Colors.grey.shade300;
  }

  build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(children: [
          HeaderWidget(
              padding: EdgeInsets.all(0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        child: TranslatedTextWidget(
                          "Objectives",
                          uppercase: true,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    buildRefreshButton(context)
                  ])),
          buildObjectives(context)
        ]));
  }

  buildRefreshButton(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            InkWell(
                child: Container(
                    padding: EdgeInsets.all(8), child: Icon(Icons.refresh)),
                onTap: () {
                  widget.profile.fetchProfileData(
                      components: ProfileComponentGroups.triumphs);
                })
          ],
        ));
  }

  buildObjectives(BuildContext context) {
    if (definition?.objectiveHashes == null) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
            children: definition.objectiveHashes.map((hash) {
          var objective = getRecordObjective(hash);
          return ObjectiveWidget(
              definition: objectiveDefinitions != null
                  ? objectiveDefinitions[hash]
                  : null,
              key: Key("objective_${hash}_${objective?.progress}"),
              objective: objective,
              placeholder: definition?.displayProperties?.name ?? "",
              color: foregroundColor);
        }).toList()));
  }

  DestinyObjectiveProgress getRecordObjective(hash) {
    if (record == null) return null;
    return record.objectives
        .firstWhere((o) => o.objectiveHash == hash, orElse: () => null);
  }
}
