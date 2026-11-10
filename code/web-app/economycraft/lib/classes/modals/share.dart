import 'package:economycraft/classes/modals/company.dart';

class Share {
  final int id;
  final DateTime createdAt;
  final int companyId;
  final double stake;
  final double purchasePrice;
  final double value;
  double salePrice;
  bool purchasable;
  final int userId;
  final bool isPublic;
  final int numberOfShares;
  final int companyShareId;

  Company? company;

  Share({
    required this.id,
    required this.createdAt,
    required this.companyId,
    required this.stake,
    required this.purchasePrice,
    required this.value,
    required this.salePrice,
    required this.purchasable,
    required this.userId,
    this.company,
    required this.isPublic,
    required this.numberOfShares,
    required this.companyShareId,
  });

  factory Share.fromMap(Map<String, dynamic> map) {
    return Share(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      companyId:
          map['company_id'] is int
              ? map['company_id'] as int
              : int.tryParse(map['company_id'].toString()) ?? 0,
      stake:
          map['stake'] is num
              ? (map['stake'] as num).toDouble()
              : double.tryParse(map['stake'].toString()) ?? 0.0,
      purchasePrice:
          map['purchase_price'] is num
              ? (map['purchase_price'] as num).toDouble()
              : double.tryParse(map['purchase_price'].toString()) ?? 0.0,
      value:
          map['value'] is num
              ? (map['value'] as num).toDouble()
              : double.tryParse(map['value'].toString()) ?? 0.0,
      salePrice:
          map['sale_price'] is num
              ? (map['sale_price'] as num).toDouble()
              : double.tryParse(map['sale_price'].toString()) ?? 0.0,
      purchasable:
          map['purchasable'] is bool
              ? map['purchasable'] as bool
              : (map['purchasable']?.toString().toLowerCase() == 'true'),
      userId:
          map['user_id'] is int
              ? map['user_id'] as int
              : int.tryParse(map['user_id'].toString()) ?? 0,
      company:
          map['company'] is Map<String, dynamic>
              ? Company.fromMap(map['company'] as Map<String, dynamic>)
              : null,
      isPublic:
          map['is_public'] is bool
              ? map['is_public'] as bool
              : (map['is_public']?.toString().toLowerCase() == 'true'),
      numberOfShares:
          map['number_of_shares'] is int
              ? map['number_of_shares'] as int
              : int.tryParse(map['number_of_shares'].toString()) ?? 0,
      companyShareId:
          map['company_share_id'] is int
              ? map['company_share_id'] as int
              : int.tryParse(map['company_share_id'].toString()) ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Share && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
