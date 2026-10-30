class CompanyShare {
  final int id;
  final int companyId;
  final double value;
  final bool isPublic;
  final int numberOfShares;

  CompanyShare({
    required this.id,
    required this.companyId,
    required this.value,
    required this.isPublic,
    required this.numberOfShares,
  });

  factory CompanyShare.fromMap(Map<String, dynamic> map) {
    return CompanyShare(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      companyId:
          map['company_id'] is int
              ? map['company_id'] as int
              : int.tryParse(map['company_id'].toString()) ?? 0,
      value:
          map['value'] is num
              ? (map['value'] as num).toDouble()
              : double.tryParse(map['value'].toString()) ?? 0.0,
      isPublic:
          map['is_public'] is bool
              ? map['is_public'] as bool
              : (map['is_public']?.toString().toLowerCase() == 'true'),
      numberOfShares:
          map['number_of_shares'] is int
              ? map['number_of_shares'] as int
              : int.tryParse(map['number_of_shares'].toString()) ?? 0,
    );
  }
}
