import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/core/providers/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.service.dart';

abstract class BaseDestinyStatefulItemWidget extends ConsumerStatefulWidget {
  final ProfileService profile = ProfileService();

  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  final DestinyItemInstanceComponent instanceInfo;
  final String characterId;

  BaseDestinyStatefulItemWidget(
      {Key key,
      this.item,
      this.definition,
      this.instanceInfo,
      this.characterId})
      : super(key: key);
}

abstract class BaseDestinyItemState<T extends BaseDestinyStatefulItemWidget>
    extends ConsumerState<T> with ManifestConsumerState {
  DestinyItemComponent get item => widget.item;
  DestinyInventoryItemDefinition get definition => widget.definition;
  DestinyItemInstanceComponent get instanceInfo => widget.instanceInfo;
  String get characterId => widget.characterId;
}
