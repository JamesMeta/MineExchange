import 'package:economycraft/classes/modals/loan.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_1_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewLoanScreen extends StatefulWidget {
  final Loan? loan;

  const ViewLoanScreen({super.key, required this.loan});

  @override
  State<ViewLoanScreen> createState() => _ViewLoanScreenState();
}

class _ViewLoanScreenState extends State<ViewLoanScreen> {
  // ── State ────────────────────────────────────────────────────────────────────

  late bool _autoPay;
  final TextEditingController _paymentController = TextEditingController();
  bool _isSubmittingPayment = false;

  // ── Design Constants ─────────────────────────────────────────────────────────

  static const Color _accentTeal = Color.fromARGB(255, 74, 237, 217);
  static const Color _accentTealLight = Color.fromARGB(255, 229, 255, 252);
  static const Color _accentGreen = Color.fromARGB(255, 23, 221, 97);
  static const Color _headerBg = Color.fromARGB(255, 233, 233, 233);
  static const Color _cardShadow = Color.fromARGB(255, 189, 189, 189);
  static const Color _textDark = Color.fromARGB(255, 50, 50, 50);
  static const Color _fixedRateText = Color.fromARGB(255, 0, 150, 136);
  static const Color _variableRateText = Color.fromARGB(255, 230, 130, 0);
  static const Color _variableRateLight = Color.fromARGB(255, 255, 243, 224);
  static const Color _errorRed = Color.fromARGB(255, 198, 40, 40);
  static const Color _missedPaymentBg = Color.fromARGB(255, 255, 235, 238);

  @override
  void initState() {
    super.initState();
    _autoPay = widget.loan?.autoPay ?? false;
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  // ── Computed Properties ───────────────────────────────────────────────────────

  Loan get _loan => widget.loan!;

  /// Remaining payment total:
  ///   compoundedPrincipal = currentPrincipal * (1 + interestRate)^remainingInstallments
  ///   remainingTotal      = compoundedPrincipal / remainingInstallments - currentPaymentAmount
  double get _remainingPaymentTotal {
    final n = _loan.remainingInstallments;
    if (n <= 0) return 0.0;
    final compounded =
        _loan.currentPrincipal * _pow(1 + _loan.currentInterestRate, n);
    return (compounded / n) - _loan.currentPaymentAmount;
  }

  /// Generate amortisation data-points: remaining principal after each weekly
  /// installment, starting from the current principal, until payoff.
  List<PriceVsTime> get _amortisationPoints {
    final points = <PriceVsTime>[];

    DateTime date;
    try {
      date = DateTime.parse(_loan.nextPaymentDue);
    } catch (_) {
      date = DateTime.now();
    }

    // Anchor: current principal one week before the first future payment.
    final startDate = date.subtract(const Duration(days: 7));
    points.add(PriceVsTime(time: startDate, price: _loan.currentPrincipal));

    double runningPrincipal = _loan.currentPrincipal;
    final rate = _loan.currentInterestRate;
    int installmentsLeft = _loan.remainingInstallments;

    while (runningPrincipal > 0 && installmentsLeft > 0) {
      final payment = (runningPrincipal * (1 + rate)) / installmentsLeft;

      runningPrincipal = runningPrincipal - payment;
      if (runningPrincipal < 0) runningPrincipal = 0;
      installmentsLeft--;

      points.add(PriceVsTime(time: date, price: runningPrincipal));
      date = date.add(const Duration(days: 7));
    }

    return points;
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    if (widget.loan == null) {
      return _buildErrorScaffold();
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          Center(child: _buildMainCard(screenWidth, screenHeight)),
        ],
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/illager_symbol.png',
            fit: BoxFit.cover,
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 16),
          const Text(
            'Loan Details',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: _accentTealLight,
    );
  }

  // ── Background ───────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/background_images/quartz_background.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ── Main Card ────────────────────────────────────────────────────────────────

  Widget _buildMainCard(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.6,
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: _cardShadow, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryBadgesRow(),
                  const SizedBox(height: 20),
                  _buildInfoGrid(),
                  const SizedBox(height: 24),
                  _buildAutoPayToggleCard(),
                  const SizedBox(height: 24),
                  _buildAmortisationChart(),
                  const SizedBox(height: 24),
                  _buildMakePaymentCard(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _headerBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loan #${_loan.id}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Opened ${_formatDate(_loan.createdAt)}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          _buildRateTypeBadge(),
        ],
      ),
    );
  }

  // ── Summary Badges Row ───────────────────────────────────────────────────────

  Widget _buildSummaryBadgesRow() {
    return Row(
      children: [
        if (_loan.missedPayments > 0) ...[
          _buildBadge(
            icon: Icons.warning_amber_rounded,
            label:
                '${_loan.missedPayments} Missed Payment${_loan.missedPayments > 1 ? 's' : ''}',
            bgColor: _missedPaymentBg,
            textColor: _errorRed,
          ),
          const SizedBox(width: 8),
        ],
        _buildBadge(
          icon: Icons.schedule,
          label: '${_loan.remainingInstallments} Installments Left',
          bgColor: _accentTealLight,
          textColor: _fixedRateText,
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Grid ────────────────────────────────────────────────────────────────

  Widget _buildInfoGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildInfoTile(
          icon: Icons.flag_outlined,
          label: 'Starting Principal',
          value: _formatCurrency(_loan.startingPrincipal),
          accent: Colors.blueGrey,
        ),
        _buildInfoTile(
          icon: Icons.payments_outlined,
          label: 'Total Paid',
          value: _formatCurrency(_loan.totalPaid),
          accent: _accentGreen,
        ),
        _buildInfoTile(
          icon: Icons.money,
          label: 'Total Interest Paid',
          value: _formatCurrency(
            _loan.totalPaid -
                (_loan.startingPrincipal - _loan.currentPrincipal),
          ),
          accent: _variableRateText,
        ),
        _buildInfoTile(
          icon: Icons.account_balance_wallet,
          label: 'Total Remaining',
          value: _formatCurrency(_loan.currentPrincipal),
          accent: _accentTeal,
        ),
        _buildInfoTile(
          icon: Icons.percent,
          label: 'Interest Rate',
          value: '${(_loan.currentInterestRate * 100).toStringAsFixed(2)}%',
          accent: _loan.fixedRate ? _fixedRateText : _variableRateText,
        ),
        _buildInfoTile(
          icon: Icons.calculate_outlined,
          label: 'Next Installment Remaining',
          value: _formatCurrency(_remainingPaymentTotal),
          accent: Colors.deepPurple,
        ),
        _buildInfoTile(
          icon: Icons.calendar_today,
          label: 'Next Payment Due',
          value: _formatDate(_loan.nextPaymentDue),
          accent: _accentTeal,
        ),
        _buildInfoTile(
          icon: Icons.payments,
          label: 'Current Payment Amount',
          value: _formatCurrency(_loan.currentPaymentAmount),
          accent: _accentGreen,
        ),
        _buildInfoTile(
          icon: Icons.warning_amber_rounded,
          label: 'Missed Payments',
          value: '${_loan.missedPayments}',
          accent: _loan.missedPayments > 0 ? _errorRed : _fixedRateText,
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Auto-Pay Toggle Card ─────────────────────────────────────────────────────

  Widget _buildAutoPayToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  _autoPay
                      ? _accentGreen.withOpacity(0.12)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.autorenew,
              color: _autoPay ? _accentGreen : Colors.grey[500],
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto-Pay',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _autoPay
                      ? 'Payments are automatically deducted each week.'
                      : 'Enable to automatically make payments each week.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoPay,
            activeColor: _accentGreen,
            onChanged: (value) => _toggleAutoPay(value),
          ),
        ],
      ),
    );
  }

  // ── Amortisation Chart ───────────────────────────────────────────────────────

  Widget _buildAmortisationChart() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Linegraph1Widget(
        title: 'Remaining Principal Over Time',
        subtitle: 'Principal',
        data: _amortisationPoints,
        xAxisLabel: 'Week',
        yAxisLabel: 'Principal (\$)',
      ),
    );
  }

  // ── Make a Payment Card ──────────────────────────────────────────────────────

  Widget _buildMakePaymentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _accentTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: _accentTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Make a Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Text(
              'This amount will be subtracted from your account on the installment data.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPaymentTextField()),
              const SizedBox(width: 12),
              _buildSubmitPaymentButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTextField() {
    return TextField(
      controller: _paymentController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        hintText: 'Enter payment amount',
        prefixText: '\$ ',
        filled: true,
        fillColor: const Color.fromARGB(255, 248, 248, 248),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 220, 220, 220),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 220, 220, 220),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _accentTeal, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitPaymentButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSubmittingPayment ? null : _submitPayment,
        icon:
            _isSubmittingPayment
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.check_circle_outline, size: 18),
        label: const Text('Submit Payment'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
        ),
      ),
    );
  }

  // ── Footer ───────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _accentTealLight, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Illager Bank — your trusted lender',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            'Grace Period: ${_formatDate(_loan.gracePeriod)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────────

  Widget _buildRateTypeBadge() {
    final isFixed = _loan.fixedRate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFixed ? _accentTealLight : _variableRateLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isFixed ? 'Fixed Rate' : 'Variable Rate',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isFixed ? _fixedRateText : _variableRateText,
        ),
      ),
    );
  }

  Widget _buildErrorScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
        backgroundColor: _accentTealLight,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text('No loan data available.', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  /// Toggles auto-pay on/off. Replace the TODO with the database call.
  void _toggleAutoPay(bool value) {
    setState(() => _autoPay = value);

    // TODO: Persist auto-pay preference to database.
    // Example:
    //   await SupabaseHelper.loan.updateAutoPay(loanId: _loan.id, autoPay: value);
  }

  /// Submits a manual payment against the loan. Replace the TODO with the
  /// database call.
  Future<void> _submitPayment() async {
    final raw = _paymentController.text.trim();
    final amount = double.tryParse(raw);

    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid payment amount.', isError: true);
      return;
    }

    setState(() => _isSubmittingPayment = true);

    try {
      // TODO: Submit payment to the database.
      // Example:
      //   await SupabaseHelper.loan.makePayment(loanId: _loan.id, amount: amount);

      // Simulate network delay for UI demonstration purposes.
      await Future.delayed(const Duration(milliseconds: 600));

      _paymentController.clear();
      _showSnackBar('Payment of ${_formatCurrency(amount)} submitted!');
    } catch (e) {
      _showSnackBar('Failed to submit payment: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmittingPayment = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _errorRed : _accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Formatting Helpers ────────────────────────────────────────────────────────

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate;
    }
  }

  // ── Math Helpers ──────────────────────────────────────────────────────────────

  /// Iterative integer exponentiation — avoids importing dart:math.
  double _pow(double base, int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
