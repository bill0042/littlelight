import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/notifications/notification_actions.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/postmaster_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

const _pendingOpacity = .4;
const _animationDuration = Duration(milliseconds: 300);

const _stepsOrder = [
  TransferSteps.PullFromPostmaster,
  TransferSteps.Unequip,
  TransferSteps.MoveToVault,
  TransferSteps.MoveToCharacter,
  TransferSteps.EquipOnCharacter,
];

const _armorIconPresentationNodeHash = 615947643;

extension on TransferSteps {
  int? diff(TransferSteps? other) {
    final thisIndex = _stepsOrder.indexOf(this);
    final otherIndex = other != null ? _stepsOrder.indexOf(other) : -1;
    if (thisIndex == -1) return null;
    if (otherIndex == -1) return null;
    return thisIndex - otherIndex;
  }
}

class ActiveTransferNotificationWidget extends StatelessWidget {
  final SingleTransferAction notification;
  ActiveTransferNotificationWidget(
    this.notification, {
    Key? key,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return buildAnimationContainers(
      context,
      Stack(
        children: [
          Positioned.fill(child: buildBackground(context)),
          AnimatedContainer(
            duration: _animationDuration,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(.5),
            decoration: BoxDecoration(
              color: notification.hasError ? context.theme.errorLayers.layer2 : context.theme.surfaceLayers.layer2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: buildNotificationContent(context),
          ),
        ],
      ),
    );
  }

  Widget buildAnimationContainers(BuildContext context, Widget child) {
    final hash = notification.item.item.itemHash;
    final char = notification.destinationCharacter;
    return AnimatedSize(
      key: Key("animated size ${hash} ${char}"),
      duration: _animationDuration,
      child: notification.dismissAnimationFinished
          ? Container()
          : AnimatedSlide(
              key: Key(
                  "animated_transfer_slide_${notification.item.item.itemHash}_${notification.destinationCharacter}"),
              duration: _animationDuration,
              curve: accelerateEasing,
              offset: Offset(notification.shouldPlayDismissAnimation ? 1.5 : 0, 0),
              child: Container(child: child, padding: EdgeInsets.only(bottom: 4)),
            ),
    );
  }

  Widget buildNotificationContent(BuildContext context) {
    final hash = notification.item.item.itemHash;
    if (hash == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTransferPath(context),
            Container(width: 8),
            Container(
              width: 32,
              height: 32,
              child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
                hash,
                (def) => InventoryItemIcon(
                  notification.item,
                  definition: def,
                  borderSize: .5,
                ),
              ),
            ),
            AnimatedSize(
              duration: _animationDuration,
              child: notification.finishedWithSuccess
                  ? Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        FontAwesomeIcons.squareCheck,
                        size: 24,
                        color: context.theme.successLayers,
                      ),
                    )
                  : Container(),
            )
          ],
        ),
        if (notification.hasError)
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              notification.errorMessage ?? "",
              style: context.textTheme.body,
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }

  Widget buildBackground(BuildContext context) {
    if (notification.finishedWithSuccess) {
      return AnimatedContainer(
          duration: _animationDuration,
          decoration: BoxDecoration(
            color: context.theme.successLayers.layer1,
            borderRadius: BorderRadius.circular(8),
          ));
    }
    if (notification.hasError) {
      return AnimatedContainer(
          duration: _animationDuration,
          decoration: BoxDecoration(
            color: context.theme.errorLayers.layer1,
            borderRadius: BorderRadius.circular(8),
          ));
    }

    return DefaultLoadingShimmer(
        child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ));
  }

  Widget buildTransferPath(BuildContext context) {
    final sourceCharacter = notification.sourceCharacter;
    final destinationCharacter = notification.destinationCharacter;
    return Row(
      children: [
        buildTransferStepEntity(
            context,
            PostmasterIconWidget(
              borderWidth: .5,
            ),
            requiredSteps: {TransferSteps.PullFromPostmaster},
            progressStep: TransferSteps.PullFromPostmaster),
        buildTransferArrow(context, step: TransferSteps.PullFromPostmaster),
        buildTransferStepEntity(context, buildEquipIcon(context),
            requiredSteps: {TransferSteps.Unequip}, progressStep: TransferSteps.Unequip),
        buildTransferArrow(context, step: TransferSteps.Unequip),
        if (sourceCharacter != null)
          buildTransferStepEntity(
              context,
              CharacterIconWidget(
                sourceCharacter,
                borderWidth: .5,
              ),
              requiredSteps: {TransferSteps.PullFromPostmaster, TransferSteps.MoveToVault},
              progressStep: TransferSteps.MoveToVault),
        buildTransferArrow(context, step: TransferSteps.MoveToVault),
        buildTransferStepEntity(
          context,
          VaultIconWidget(),
          requiredSteps: {
            TransferSteps.MoveToVault,
            TransferSteps.MoveToCharacter,
          },
          progressStep: TransferSteps.MoveToCharacter,
        ),
        buildTransferArrow(context, step: TransferSteps.MoveToCharacter),
        if (destinationCharacter != null)
          buildTransferStepEntity(
              context,
              CharacterIconWidget(
                destinationCharacter,
                borderWidth: .5,
              ),
              requiredSteps: {TransferSteps.MoveToCharacter, TransferSteps.EquipOnCharacter}),
        buildTransferArrow(context, step: TransferSteps.EquipOnCharacter),
        buildTransferStepEntity(context, buildEquipIcon(context),
            requiredSteps: {TransferSteps.EquipOnCharacter}, progressStep: TransferSteps.EquipOnCharacter),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? buildTransferStepEntity(
    BuildContext context,
    Widget widget, {
    Set<TransferSteps> requiredSteps = const {},
    TransferSteps? progressStep,
  }) {
    if (!this.notification.hasSteps(requiredSteps)) return null;
    final progressStepDiff = notification.currentStep?.diff(progressStep) ?? -1;
    final isFinishedOrInProgress = notification.finishedWithSuccess || progressStepDiff >= 0;
    return AnimatedOpacity(
      key: Key("step_animated_opacity_$progressStep"),
      duration: _animationDuration,
      opacity: isFinishedOrInProgress ? 1 : _pendingOpacity,
      child: Container(
        margin: EdgeInsets.only(right: 4),
        width: 32,
        height: 32,
        child: widget,
      ),
    );
  }

  Widget? buildTransferArrow(
    BuildContext context, {
    TransferSteps step = TransferSteps.PullFromPostmaster,
  }) {
    if (!this.notification.hasSteps({step})) return null;
    final progressStepDiff = notification.currentStep?.diff(step) ?? -1;
    final isFinished = notification.finishedWithSuccess || progressStepDiff > 0;
    final isInProgress = progressStepDiff == 0;
    final arrow = Container(
      margin: EdgeInsets.only(right: 4),
      width: 32,
      height: 32,
      child: Icon(FontAwesomeIcons.arrowRight),
    );
    if (isFinished) {
      return arrow;
    }
    if (isInProgress && notification.hasError) {
      return Container(
        margin: EdgeInsets.only(right: 4),
        width: 32,
        height: 32,
        child: Icon(
          FontAwesomeIcons.circleXmark,
          size: 24,
        ),
      );
    }
    if (isInProgress) {
      return DefaultLoadingShimmer(child: arrow);
    }
    return Opacity(opacity: _pendingOpacity, child: arrow);
  }

  Widget buildEquipIcon(BuildContext context) => ManifestImageWidget<DestinyPresentationNodeDefinition>(
        _armorIconPresentationNodeHash,
        color: context.theme.onSurfaceLayers.layer1,
      );
}
