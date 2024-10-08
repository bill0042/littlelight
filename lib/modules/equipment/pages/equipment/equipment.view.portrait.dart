import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/scroll_area_type.dart';
import 'package:little_light/modules/equipment/widgets/equipment_character_bucket_content.dart';
import 'package:little_light/modules/equipment/widgets/equipment_character_tab_content.widget.dart';
import 'package:little_light/modules/equipment/widgets/equipment_type_tab_menu.widget.dart';
import 'package:little_light/modules/equipment/widgets/equipment_vault_tab_content.widget.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu_view.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:little_light/shared/widgets/tabs/header/character_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/header/loading_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/header/vault_tab_header.widget.dart';
import 'package:little_light/shared/widgets/tabs/item_list_swipe_area/swipe_area_gesture_detector.widget.dart';
import 'package:little_light/shared/widgets/tabs/item_list_swipe_area/swipe_area_indicator_overlay.dart';
import 'package:little_light/shared/widgets/tabs/menus/character_header_tab_menu.widget.dart';
import 'package:little_light/shared/widgets/tabs/menus/current_character_tab_indicator.dart';

import 'equipment.bloc.dart';

const _animationDuration = Duration(milliseconds: 500);

class EquipmentPortraitView extends StatelessWidget {
  final EquipmentBloc bloc;
  final EquipmentBloc state;
  final CustomTabController characterTabController;
  final CustomTabController typeTabController;

  const EquipmentPortraitView(
    this.bloc,
    this.state, {
    Key? key,
    required CustomTabController this.characterTabController,
    required CustomTabController this.typeTabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final characters = state.characters;
    if (characters == null) return Container();
    final viewPadding = MediaQuery.of(context).viewPadding;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(children: [
              SizedBox(
                height: viewPadding.top + kToolbarHeight + 2,
              ),
              Expanded(
                child: Stack(children: [
                  Positioned.fill(child: buildTabContent(context)),
                  Positioned.fill(
                    child: buildScrollGestureDetectors(context),
                  ),
                  Positioned.fill(
                    child: buildScrollIndicators(context),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    right: 8,
                    child: const NotificationsWidget(),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: const BusyIndicatorLineWidget(),
                  ),
                ]),
              ),
              SelectedItemsWidget(),
              Container(
                height: kToolbarHeight + viewPadding.bottom,
                decoration: BoxDecoration(
                    color: context.theme.surfaceLayers,
                    border: Border(top: BorderSide(width: .5, color: context.theme.surfaceLayers.layer3))),
                child: Stack(children: [
                  Row(
                    children: [
                      EquipmentTypeTabMenuWidget(typeTabController),
                      Expanded(
                        child: buildCharacterContextMenuButton(context),
                      ),
                    ],
                  ),
                  Positioned(bottom: 0, left: 0, right: 0, child: BusyIndicatorBottomGradientWidget()),
                ]),
              ),
            ]),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: viewPadding.top + kToolbarHeight * 1.4 + 2,
            child: buildTabHeader(context),
          ),
          Positioned(
              top: 0 + viewPadding.top,
              right: 8,
              child: Row(children: [
                buildSearchButton(context),
                CharacterHeaderTabMenuWidget(
                  characters,
                  characterTabController,
                  vaultItemCount: state.vaultItemCount,
                )
              ])),
          Positioned(
            top: 0 + viewPadding.top,
            left: 0,
            child: SizedBox(
              width: kToolbarHeight,
              height: kToolbarHeight,
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabHeader(BuildContext context) {
    final characters = state.characters;
    if (characters == null) return buildLoadingAppBar(context);
    return CustomTabPassiveView(
        controller: characterTabController,
        pageBuilder: (context, index) {
          final character = characters[index];
          if (character != null) return CharacterTabHeaderWidget(character);
          return VaultTabHeaderWidget();
        });
  }

  Widget buildLoadingAppBar(BuildContext context) {
    return LoadingTabHeaderWidget();
  }

  Widget buildTabContent(BuildContext context) {
    final characters = state.characters;
    if (characters == null) return Container();
    return CustomTabPassiveView(
      controller: characterTabController,
      pageBuilder: (context, index) {
        final character = characters[index];
        return CustomTabPassiveView(
            controller: typeTabController,
            pageBuilder: (context, index) {
              final tab = EquipmentBucketGroup.values[index];
              if (character != null) {
                return buildCharacterTabContent(context, tab, character);
              }
              return buildVaultTabContent(context, tab);
            });
      },
    );
  }

  Widget buildCharacterTabContent(BuildContext context, EquipmentBucketGroup tab, DestinyCharacterInfo character) {
    final bucketHashes = tab.bucketHashes;
    final currencies = state.relevantCurrencies;
    final buckets = bucketHashes
        .map((h) => EquipmentCharacterBucketContent(
              h,
              equipped: state.getEquippedItem(character, h),
              unequipped: state.getUnequippedItems(character, h) ?? [],
            ))
        .toList();
    return EquipmentCharacterTabContentWidget(
      character,
      scrollViewKey: PageStorageKey("character_tab_${tab.name}_${character.characterId}"),
      buckets: buckets,
      currencies: currencies,
    );
  }

  Widget buildVaultTabContent(BuildContext context, EquipmentBucketGroup tab) {
    final bucketHashes = tab.bucketHashes;
    final currencies = state.relevantCurrencies;
    final buckets = bucketHashes
        .map((h) {
          final items = state.getVaultItems(h) ?? [];
          if (items.isEmpty) return null;
          return EquipmentVaultBucketContent(
            h,
            items: items,
          );
        })
        .whereType<EquipmentVaultBucketContent>()
        .toList();
    return EquipmentVaultTabContentWidget(
      buckets: buckets,
      currencies: currencies,
      itemsOnVault: state.vaultItemCount,
      progressions: state.characters?.firstOrNull?.progression?.progressions,
    );
  }

  Widget buildCharacterContextMenuButton(
    BuildContext context,
  ) {
    final characters = state.characters;
    final viewPadding = MediaQuery.of(context).viewPadding;
    if (characters == null) return Container();
    return Builder(
      builder: (context) => Stack(
        alignment: Alignment.centerRight,
        fit: StackFit.expand,
        children: [
          Container(
              padding: EdgeInsets.only(bottom: viewPadding.bottom),
              child: CurrentCharacterTabIndicator(
                characters,
                characterTabController,
              )),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            key: CharacterContextMenu.menuButtonKey,
            child: InkWell(onTap: () {
              bloc.openContextMenu(characterTabController, typeTabController);
            }),
          ))
        ],
      ),
    );
  }

  Widget buildScrollIndicators(
    BuildContext context,
  ) {
    return AnimatedBuilder(
        animation: typeTabController,
        builder: (context, child) => AnimatedBuilder(
            animation: characterTabController,
            builder: (context, child) => AnimatedOpacity(
                  duration: _animationDuration,
                  opacity: typeTabController.isDragging || characterTabController.isDragging ? 1 : 0,
                  child: DividerIndicatorOverlay(
                    activeTypes: {
                      ScrollAreaType.Characters: characterTabController.isDragging,
                      ScrollAreaType.Sections: typeTabController.isDragging,
                    },
                  ),
                )));
  }

  Widget buildScrollGestureDetectors(
    BuildContext context,
  ) {
    return SwipeAreaGestureDetector({
      ScrollAreaType.Characters: characterTabController,
      ScrollAreaType.Sections: typeTabController,
    });
  }

  Widget buildSearchButton(BuildContext context) {
    return Stack(children: [
      Container(
        width: kToolbarHeight,
        height: kToolbarHeight,
        child: Icon(FontAwesomeIcons.magnifyingGlass),
      ),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: () {
            final currentBucketGroup = EquipmentBucketGroup.values[typeTabController.index];
            final currentClassType = state.characters?[characterTabController.index]?.character.classType;
            bloc.openSearch(currentBucketGroup, currentClassType);
          }),
        ),
      ),
    ]);
  }
}
