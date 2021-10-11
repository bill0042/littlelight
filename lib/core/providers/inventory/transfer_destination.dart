enum ItemDestination { Character, Inventory, Vault }
enum InventoryAction { Transfer, Equip, Unequip, Pull }

class TransferDestination {
  final String characterId;
  final ItemDestination type;
  final InventoryAction action;

  TransferDestination(this.type,
      {this.action = InventoryAction.Transfer, this.characterId});
}
