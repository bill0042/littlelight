import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class EmptyEngramInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with MinimalInfoLabelMixin {
  EmptyEngramInventoryItemWidget({
    Key key,
    String characterId,
    @required String uniqueId,
  }) : super(null, null, null,
            uniqueId: uniqueId, characterId: characterId, key: key);

  @override
  Widget itemIconHero(BuildContext context, WidgetRef ref) {
    return itemIcon(context, ref);
  }

  @override
  Widget primaryStatWidget(BuildContext context, WidgetRef ref) {
    return Container();
  }

  @override
  Widget itemIcon(BuildContext context, WidgetRef ref) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Image.asset("assets/imgs/engram-placeholder.png"));
  }
}
