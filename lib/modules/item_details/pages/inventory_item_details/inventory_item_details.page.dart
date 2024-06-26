import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_details.view.dart';
import 'package:little_light/modules/item_details/pages/inventory_item_details/inventory_item_socket_controller.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:provider/provider.dart';

class InventoryItemDetailsPage extends StatelessWidget {
  final InventoryItemInfo item;

  const InventoryItemDetailsPage(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScopedValueRepositoryBloc>(create: (context) => ScopedValueRepositoryBloc()),
        ChangeNotifierProvider<SocketControllerBloc>(create: (context) => InventoryItemSocketControllerBloc(context)),
        ChangeNotifierProvider<ItemDetailsBloc>(create: (context) => InventoryItemDetailsBloc(context, item: item)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<ItemDetailsBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => item is InventoryItemInfo ? bloc.onDuplicateItemTap(item) : null,
            onHold: (item) => item is InventoryItemInfo ? bloc.onDuplicateItemHold(item) : null,
          );
        }),
      ],
      builder: (context, _) => InventoryItemDetailsView(
        context.read<ItemDetailsBloc>(),
        context.watch<ItemDetailsBloc>(),
        context.watch<SocketControllerBloc>(),
        context.watch<SelectionBloc>(),
      ),
    );
  }
}
