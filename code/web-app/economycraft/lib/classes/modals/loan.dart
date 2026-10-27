class Loan {
  final int id;
  final String createdAt;
  final String userId;
  final double principal;
  final double emi;
  final double currentPaymentAmount;
  final String nextPaymentDue;
  final String gracePeriod;
  final int missedPayments;
  final bool fixedRate;

  const Loan({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.principal,
    required this.emi,
    required this.currentPaymentAmount,
    required this.nextPaymentDue,
    required this.gracePeriod,
    required this.missedPayments,
    required this.fixedRate,
  });

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      createdAt:
          map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? map['userId']?.toString() ?? '',
      principal:
          map['principal'] is num
              ? (map['principal'] as num).toDouble()
              : double.tryParse(map['principal'].toString()) ?? 0.0,
      emi:
          map['emi'] is num
              ? (map['emi'] as num).toDouble()
              : double.tryParse(map['emi'].toString()) ?? 0.0,
      currentPaymentAmount:
          map['current_payment_amount'] is num
              ? (map['current_payment_amount'] as num).toDouble()
              : double.tryParse(map['current_payment_amount'].toString()) ??
                  0.0,
      nextPaymentDue:
          map['next_payment_due']?.toString() ??
          map['nextPaymentDue']?.toString() ??
          '',
      gracePeriod:
          map['grace_period']?.toString() ??
          map['gracePeriod']?.toString() ??
          '',
      missedPayments:
          map['missed_payments'] is int
              ? map['missed_payments'] as int
              : int.tryParse(map['missed_payments'].toString()) ?? 0,
      fixedRate:
          map['fixed_rate'] is bool
              ? map['fixed_rate'] as bool
              : (map['fixed_rate']?.toString().toLowerCase() == 'true'),
    );
  }
}
