import 'package:economycraft/classes/modals/loan.dart';
import 'package:flutter/material.dart';

class LoanListTileWidget extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanListTileWidget({
    super.key,
    required this.loan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _tileDecoration(),
            child: Row(
              children: [
                _loanIcon(),
                const SizedBox(width: 16),
                Expanded(child: _loanDetails()),
                _paymentInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _tileDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(30, 0, 0, 0),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _loanIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 229, 255, 252),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.account_balance,
        color: Color.fromARGB(255, 74, 237, 217),
        size: 26,
      ),
    );
  }

  Widget _loanDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelValueRow('Loan #${loan.id}', bold: true, fontSize: 16),
        const SizedBox(height: 4),
        _labelValueRow(
          'Principal: \$${loan.currentPrincipal.toStringAsFixed(2)}',
        ),
        _labelValueRow(
          'Interest Rate: ${(loan.currentInterestRate * 100).toStringAsFixed(2)}%',
        ),
        _labelValueRow('Next Due: ${_formatDate(loan.nextPaymentDue)}'),
        if (loan.missedPayments > 0) _missedPaymentsBadge(),
      ],
    );
  }

  Widget _paymentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _rateTypeBadge(),
        const SizedBox(height: 8),
        Text(
          '\$${loan.currentPaymentAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 50, 50, 50),
          ),
        ),
        Text(
          'due in ${(DateTime.tryParse(loan.nextPaymentDue) ?? DateTime.now()).difference(DateTime.now()).inDays} day(s)',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        const Icon(
          Icons.chevron_right,
          color: Color.fromARGB(255, 74, 237, 217),
        ),
      ],
    );
  }

  Widget _labelValueRow(
    String text, {
    bool bold = false,
    double fontSize = 13,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: bold ? const Color.fromARGB(255, 50, 50, 50) : Colors.grey[700],
      ),
    );
  }

  Widget _rateTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            loan.fixedRate
                ? const Color.fromARGB(255, 229, 255, 252)
                : const Color.fromARGB(255, 255, 243, 224),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        loan.fixedRate ? 'Fixed Rate' : 'Variable Rate',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color:
              loan.fixedRate
                  ? const Color.fromARGB(255, 0, 150, 136)
                  : const Color.fromARGB(255, 230, 130, 0),
        ),
      ),
    );
  }

  Widget _missedPaymentsBadge() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 235, 238),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          '${loan.missedPayments} missed payment${loan.missedPayments > 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 198, 40, 40),
          ),
        ),
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate;
    }
  }
}
