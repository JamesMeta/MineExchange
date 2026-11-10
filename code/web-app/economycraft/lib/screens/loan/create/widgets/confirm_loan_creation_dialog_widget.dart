import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConfirmLoanCreationDialogWidget extends StatelessWidget {
  final bool _fixedRate;
  final bool _autoPay;
  final double _loanAmount;
  final int _loanWeekDuration;
  final double _weeklyPayment;
  final Color _warningAmber;
  final Color _accentGreen;
  final Color _textDark;
  final String Function(double) _formatCurrency;

  const ConfirmLoanCreationDialogWidget({
    super.key,
    required bool fixedRate,
    required bool autoPay,
    required double loanAmount,
    required int loanWeekDuration,
    required double weeklyPayment,
    required Color warningAmber,
    required Color accentGreen,
    required Color textDark,
    required String Function(double) formatCurrency,
  }) : _fixedRate = fixedRate,
       _autoPay = autoPay,
       _loanAmount = loanAmount,
       _loanWeekDuration = loanWeekDuration,
       _weeklyPayment = weeklyPayment,
       _warningAmber = warningAmber,
       _accentGreen = accentGreen,
       _textDark = textDark,
       _formatCurrency = formatCurrency;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _warningAmber, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Confirm Loan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please review your loan details carefully:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildConfirmationRow('Principal', _formatCurrency(_loanAmount)),
          _buildConfirmationRow(
            'Duration',
            '$_loanWeekDuration week${_loanWeekDuration != 1 ? 's' : ''}',
          ),
          _buildConfirmationRow(
            'Weekly Payment',
            _formatCurrency(_weeklyPayment),
          ),
          _buildConfirmationRow('Rate Type', _fixedRate ? 'Fixed' : 'Variable'),
          _buildConfirmationRow('Auto-Pay', _autoPay ? 'Enabled' : 'Disabled'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 243, 224),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _warningAmber.withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: _warningAmber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'By taking this loan you agree to make timely weekly '
                    'payments. Failure to meet payment obligations will '
                    'result in missed payment penalties, increased interest '
                    'rates, and potential retaliation by Illager Bank.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text('Confirm & Create Loan'),
        ),
      ],
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}
