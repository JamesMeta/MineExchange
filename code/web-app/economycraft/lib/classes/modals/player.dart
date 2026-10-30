class Player {
  final int id;
  final String name;
  final String deliveryAddress;
  final String avatarUrl;
  final bool ai;
  double money;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.deliveryAddress,
    required this.avatarUrl,
    required this.ai,
    required this.money,
    required this.createdAt,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name']?.toString() ?? '',
      deliveryAddress:
          map['delivery_address']?.toString() ??
          map['deliveryAddress']?.toString() ??
          '',
      avatarUrl:
          map['avatar_url']?.toString() ?? map['avatarUrl']?.toString() ?? '',
      ai:
          map['ai'] is bool
              ? map['ai'] as bool
              : (map['ai']?.toString().toLowerCase() == 'true'),
      money:
          map['money'] is num
              ? (map['money'] as num).toDouble()
              : double.tryParse(map['money'].toString()) ?? 0.0,
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
