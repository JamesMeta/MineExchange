import 'package:economycraft/classes/modals/product.dart';
import 'package:economycraft/classes/modals/company.dart';

class Order {
  final int id;
  final int productId;
  final int companyId;
  final int userId;
  final int quantity;
  final double payment;
  final String deliveryAddress;
  final DateTime orderTimeout;
  final DateTime createdAt;
  bool complete;
  bool received;

  Product? product;
  Company? company;

  Order({
    required this.id,
    required this.productId,
    required this.companyId,
    required this.userId,
    required this.quantity,
    required this.payment,
    required this.deliveryAddress,
    required this.orderTimeout,
    required this.createdAt,
    required this.complete,
    required this.received,
    this.product,
    this.company,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      productId:
          map['product_id'] is int
              ? map['product_id'] as int
              : int.tryParse(map['product_id'].toString()) ?? 0,
      companyId:
          map['company_id'] is int
              ? map['company_id'] as int
              : int.tryParse(map['company_id'].toString()) ?? 0,
      userId:
          map['user_id'] is int
              ? map['user_id'] as int
              : int.tryParse(map['user_id'].toString()) ?? 0,
      quantity:
          map['quantity'] is int
              ? map['quantity'] as int
              : int.tryParse(map['quantity'].toString()) ?? 0,
      payment:
          map['payment'] is num
              ? (map['payment'] as num).toDouble()
              : double.tryParse(map['payment'].toString()) ?? 0.0,
      deliveryAddress:
          map['delivery_address']?.toString() ??
          map['deliveryAddress']?.toString() ??
          '',
      orderTimeout: DateTime.parse(
        map['order_timeout']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      complete:
          map['complete'] is bool
              ? map['complete'] as bool
              : (map['complete']?.toString().toLowerCase() == 'true'),
      received:
          map['received'] is bool
              ? map['received'] as bool
              : (map['received']?.toString().toLowerCase() == 'true'),
      product:
          map['product'] is Map<String, dynamic>
              ? Product.fromMap(map['product'] as Map<String, dynamic>)
              : null,
      company:
          map['company'] is Map<String, dynamic>
              ? Company.fromMap(map['company'] as Map<String, dynamic>)
              : null,
    );
  }
}
