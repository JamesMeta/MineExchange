import 'package:economycraft/classes/modals/market_item.dart';

class Product {
  final int id;
  String name;
  String description;
  double price;
  int quantity;
  String createdAt;
  MarketItem marketItem;
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.marketItem,
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
    );
  }
}
