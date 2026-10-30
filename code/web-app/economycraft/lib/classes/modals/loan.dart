class Loan {
  final int id;
  final String createdAt;
  final String userId;
  final double currentPrincipal;
  final double startingPrincipal;
  final double currentInterestRate;
  final double currentPaymentAmount;
  final double totalPaid;
  final String nextPaymentDue;
  final String gracePeriod;
  final int missedPayments;
  final int remainingInstallments;
  final bool fixedRate;
  final bool autoPay;

  const Loan({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.currentPrincipal,
    required this.startingPrincipal,
    required this.currentInterestRate,
    required this.currentPaymentAmount,
    required this.totalPaid,
    required this.nextPaymentDue,
    required this.gracePeriod,
    required this.missedPayments,
    required this.remainingInstallments,
    required this.fixedRate,
    required this.autoPay,
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
      currentPrincipal:
          map['principal'] is num
              ? (map['principal'] as num).toDouble()
              : double.tryParse(map['principal'].toString()) ?? 0.0,
      startingPrincipal:
          map['starting_principal'] is num
              ? (map['starting_principal'] as num).toDouble()
              : double.tryParse(map['starting_principal'].toString()) ?? 0.0,
      currentInterestRate:
          map['current_interest_rate'] is num
              ? (map['current_interest_rate'] as num).toDouble()
              : double.tryParse(map['current_interest_rate'].toString()) ?? 0.0,
      currentPaymentAmount:
          map['current_payment_amount'] is num
              ? (map['current_payment_amount'] as num).toDouble()
              : double.tryParse(map['current_payment_amount'].toString()) ??
                  0.0,
      totalPaid:
          map['total_paid'] is num
              ? (map['total_paid'] as num).toDouble()
              : double.tryParse(map['total_paid'].toString()) ?? 0.0,
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
      remainingInstallments:
          map['remaining_installments'] is int
              ? map['remaining_installments'] as int
              : int.tryParse(map['remaining_installments'].toString()) ?? 0,
      fixedRate:
          map['fixed_rate'] is bool
              ? map['fixed_rate'] as bool
              : (map['fixed_rate']?.toString().toLowerCase() == 'true'),
      autoPay:
          map['auto_pay'] is bool
              ? map['auto_pay'] as bool
              : (map['auto_pay']?.toString().toLowerCase() == 'true'),
    );
  }
}
