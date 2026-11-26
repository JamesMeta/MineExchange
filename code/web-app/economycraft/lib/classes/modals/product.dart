import 'package:economycraft/classes/modals/market_item.dart';
import 'package:economycraft/classes/modals/player.dart';

class Product {
  final int id;

  //TODO
  // Make final
  String name;
  String description;
  double price;
  int quantity;
  String createdAt;
  MarketItem marketItem;
  Player player;
  bool isSell; // Indicates if the product is being sold or bought
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.marketItem,
    required this.player,
    required this.isSell,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      quantity: map['quantity'],
      createdAt: map['created_at'],
      marketItem: MarketItem.fromMap(map['valid_market_items']),
      player: Player.fromMap(map['users']),
      isSell: map['is_sell'] ?? false,
    );
  }
}
