import 'package:economycraft/classes/modals/market_item.dart';

class Inventory {
  final int id;
  final String createdAt;
  final MarketItem marketItem;
  final int quantity;
  final int userId;

  Inventory({
    required this.id,
    required this.createdAt,
    required this.marketItem,
    required this.quantity,
    required this.userId,
  });

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'],
      createdAt: map['created_at'],
      marketItem: MarketItem.fromMap(map['market_item']),
      quantity: map['quantity'],
      userId: map['user_id'],
    );
  }
}
