class BuyOrder {
  final int id;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int companyShareId;
  final int userId;
  final int orderQuality;
  final double maximumSharePrice;

  const BuyOrder({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    required this.companyShareId,
    required this.userId,
    required this.orderQuality,
    required this.maximumSharePrice,
  });

  factory BuyOrder.fromMap(Map<String, dynamic> map) {
    return BuyOrder(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      expiresAt: DateTime.parse(
        map['expires_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      companyShareId:
          map['company_share_id'] is int
              ? map['company_share_id'] as int
              : int.tryParse(map['company_share_id'].toString()) ?? 0,
      userId:
          map['user_id'] is int
              ? map['user_id'] as int
              : int.tryParse(map['user_id'].toString()) ?? 0,
      orderQuality:
          map['order_quality'] is int
              ? map['order_quality'] as int
              : int.tryParse(map['order_quality'].toString()) ?? 0,
      maximumSharePrice:
          map['maximum_share_price'] is num
              ? (map['maximum_share_price'] as num).toDouble()
              : double.tryParse(map['maximum_share_price'].toString()) ?? 0.0,
    );
  }
}
