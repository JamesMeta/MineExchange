class Product {
  final int id;
  String name;
  String description;
  String minecraftTag;
  double price;
  int quantity;
  String avatarUrl;
  int companyId;
  DateTime createdAt;
  bool? isVerified;
  double? value;
  double? nicheCoefficient;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.avatarUrl,
    required this.companyId,
    required this.minecraftTag,
    required this.createdAt,
    this.isVerified,
    this.value,
    this.nicheCoefficient,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price:
          map['price'] is num
              ? (map['price'] as num).toDouble()
              : double.tryParse(map['price'].toString()) ?? 0.0,
      quantity:
          map['quantity'] is int
              ? map['quantity'] as int
              : int.tryParse(map['quantity'].toString()) ?? 0,
      avatarUrl:
          map['avatar_url']?.toString() ?? map['avatarUrl']?.toString() ?? '',
      companyId:
          map['company_id'] is int
              ? map['company_id'] as int
              : int.tryParse(map['company_id'].toString()) ?? 0,
      minecraftTag:
          map['minecraft_tag']?.toString() ??
          map['minecraftTag']?.toString() ??
          '',
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      isVerified:
          map['is_verified'] == null
              ? null
              : (map['is_verified'] is bool
                  ? map['is_verified'] as bool
                  : (map['is_verified']?.toString().toLowerCase() == 'true')),
      value:
          map['value'] == null
              ? null
              : (map['value'] is num
                  ? (map['value'] as num).toDouble()
                  : double.tryParse(map['value'].toString())),
      nicheCoefficient:
          map['niche_coefficient'] == null
              ? null
              : (map['niche_coefficient'] is num
                  ? (map['niche_coefficient'] as num).toDouble()
                  : double.tryParse(map['niche_coefficient'].toString())),
    );
  }
}
