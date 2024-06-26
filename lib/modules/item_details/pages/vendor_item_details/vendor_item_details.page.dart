import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/vendor_item_details/vendor_item_details.bloc.dart';
import 'package:little_light/modules/item_details/pages/vendor_item_details/vendor_item_socket_controller.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/scoped_value_repository.bloc.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:provider/provider.dart';
import 'vendor_item_details.view.dart';

class VendorItemDetailsPage extends StatelessWidget {
  final VendorItemInfo item;

  const VendorItemDetailsPage(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ScopedValueRepositoryBloc>(create: (context) => ScopedValueRepositoryBloc()),
        ChangeNotifierProvider<SocketControllerBloc>(create: (context) => VendorItemSocketControllerBloc(context)),
        ChangeNotifierProvider<ItemDetailsBloc>(create: (context) => VendorItemDetailsBloc(context, item: item)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<ItemDetailsBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => item is InventoryItemInfo ? bloc.onDuplicateItemTap(item) : null,
            onHold: (item) => item is InventoryItemInfo ? bloc.onDuplicateItemHold(item) : null,
          );
        }),
      ],
      builder: (context, _) => VendorItemDetailsView(
        context.read<ItemDetailsBloc>(),
        context.watch<ItemDetailsBloc>(),
        context.watch<SocketControllerBloc>(),
        context.watch<SelectionBloc>(),
      ),
    );
  }
}
