import 'package:economycraft/classes/modals/market_item.dart';

class InventoryItem {
  final int id;
  final String createdAt;
  final MarketItem marketItem;
  final int quantity;
  final int userId;

  InventoryItem({
    required this.id,
    required this.createdAt,
    required this.marketItem,
    required this.quantity,
    required this.userId,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      createdAt: map['created_at'],
      marketItem: MarketItem.fromMap(map['valid_market_items']),
      quantity: map['quantity'],
      userId: map['user_id'],
    );
  }
}
