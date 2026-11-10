class Company {
  final int id;
  String name;
  String slogan;
  String avatarUrl;
  final int reputation;
  final double evaluation;
  bool isPublic;
  final int userId;
  final DateTime createdAt;
  final int lotNumber;
  final bool verified;
  double? visibilityFactor;

  Company({
    required this.id,
    required this.name,
    required this.slogan,
    required this.avatarUrl,
    required this.reputation,
    required this.evaluation,
    required this.isPublic,
    required this.userId,
    required this.createdAt,
    required this.lotNumber,
    required this.verified,
    this.visibilityFactor,
  });

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name']?.toString() ?? '',
      slogan: map['slogan']?.toString() ?? '',
      avatarUrl:
          map['avatar_url']?.toString() ?? map['avatarUrl']?.toString() ?? '',
      reputation:
          map['reputation'] is int
              ? map['reputation'] as int
              : int.tryParse(map['reputation'].toString()) ?? 0,
      evaluation:
          map['evaluation'] is num
              ? (map['evaluation'] as num).toDouble()
              : double.tryParse(map['evaluation'].toString()) ?? 0.0,
      isPublic:
          map['is_public'] is bool
              ? map['is_public'] as bool
              : (map['is_public']?.toString().toLowerCase() == 'true'),
      userId:
          map['user_id'] is int
              ? map['user_id'] as int
              : int.tryParse(map['user_id'].toString()) ?? 0,
      createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      lotNumber:
          map['lot_number'] is int
              ? map['lot_number'] as int
              : int.tryParse(map['lot_number'].toString()) ?? 0,
      verified:
          map['verified'] is bool
              ? map['verified'] as bool
              : (map['verified']?.toString().toLowerCase() == 'true'),
      visibilityFactor:
          map['visibility_factor'] == null
              ? null
              : (map['visibility_factor'] is num
                  ? (map['visibility_factor'] as num).toDouble()
                  : double.tryParse(map['visibility_factor'].toString())),
    );
  }
}
