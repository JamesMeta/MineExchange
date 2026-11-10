import 'dart:math';

import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_1_widget.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CreateLoanScreen extends StatefulWidget {
  const CreateLoanScreen({super.key});

  @override
  State<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends State<CreateLoanScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  bool _isLoading = true;
  bool _isCreatingLoan = false;

  bool _stepMaxWeeklyPaymentLoaded = false;
  bool _stepAssetsLoaded = false;
  bool _stepLoansLoaded = false;
  bool _stepMetricsLoaded = false;

  int get _loadedStepsCount {
    int count = 0;
    if (_stepMaxWeeklyPaymentLoaded) count++;
    if (_stepAssetsLoaded) count++;
    if (_stepLoansLoaded) count++;
    if (_stepMetricsLoaded) count++;
    return count;
  }

  double get _loadingProgress => _loadedStepsCount / 4.0;

  double _maxWeeklyPayment = 0.0;
  double _assets = 0.0;
  double _loans = 0.0;
  double _interestRate = 0.0;
  double _inflation = 0.0;

  int _loanWeekDuration = 6;
  double _loanAmount = 1.0;
  bool _fixedRate = false;
  bool _autoPay = false;

  final TextEditingController _loanAmountController = TextEditingController();

  // ── Design Constants ───────────────────────────────────────────────────────

  static const Color _accentTeal = Color.fromARGB(255, 74, 237, 217);
  static const Color _accentTealLight = Color.fromARGB(255, 229, 255, 252);
  static const Color _accentGreen = Color.fromARGB(255, 23, 221, 97);
  static const Color _headerBg = Color.fromARGB(255, 233, 233, 233);
  static const Color _cardShadow = Color.fromARGB(255, 189, 189, 189);
  static const Color _textDark = Color.fromARGB(255, 50, 50, 50);
  static const Color _fixedRateText = Color.fromARGB(255, 0, 150, 136);
  static const Color _variableRateText = Color.fromARGB(255, 230, 130, 0);
  static const Color _errorRed = Color.fromARGB(255, 198, 40, 40);
  static const Color _warningAmber = Color.fromARGB(255, 255, 152, 0);

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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

  // ── AppBar ─────────────────────────────────────────────────────────────────

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
            'New Illager Loan',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: _accentTealLight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  // ── Background ─────────────────────────────────────────────────────────────

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

  // ── Main Card ──────────────────────────────────────────────────────────────

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
            child:
                _isLoading
                    ? _buildLoadingView()
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEconomicMetricsRow(),
                          const SizedBox(height: 20),
                          _buildMaxWeeklyPaymentCard(),
                          const SizedBox(height: 24),
                          _buildLoanAmountSlider(),
                          const SizedBox(height: 24),
                          _buildLoanDurationSlider(),
                          const SizedBox(height: 24),
                          _buildLoanOptionsRow(),
                          const SizedBox(height: 24),
                          _buildLoanSummaryGrid(),
                          const SizedBox(height: 24),
                          _buildAmortisationChart(),
                          const SizedBox(height: 24),
                          _buildCreateLoanButton(),
                        ],
                      ),
                    ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── Loading View ───────────────────────────────────────────────────────────

  Widget _buildLoadingView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromARGB(255, 230, 230, 230)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(15, 0, 0, 0),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _accentTealLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(_fixedRateText),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Assessing Financial Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Illager Bank is auditing your assets, liabilities, and current market rates.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  minHeight: 8,
                  backgroundColor: _accentTealLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(_accentGreen),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step $_loadedStepsCount of 4 complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${(_loadingProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _fixedRateText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                height: 1,
                color: Color.fromARGB(255, 235, 235, 235),
              ),
              const SizedBox(height: 16),
              _buildLoadingStepTile(
                title: 'Borrowing Capacity',
                subtitle: 'Calculating maximum affordable weekly payment',
                icon: Icons.account_balance_wallet_outlined,
                isCompleted: _stepMaxWeeklyPaymentLoaded,
              ),
              const SizedBox(height: 12),
              _buildLoadingStepTile(
                title: 'Player Assets',
                subtitle: 'Evaluating collateral and asset valuation',
                icon: Icons.inventory_2_outlined,
                isCompleted: _stepAssetsLoaded,
              ),
              const SizedBox(height: 12),
              _buildLoadingStepTile(
                title: 'Outstanding Liabilities',
                subtitle: 'Auditing existing loans and owed debt',
                icon: Icons.receipt_long_outlined,
                isCompleted: _stepLoansLoaded,
              ),
              const SizedBox(height: 12),
              _buildLoadingStepTile(
                title: 'Economic Metrics',
                subtitle: 'Querying live interest rate and inflation index',
                icon: Icons.trending_up,
                isCompleted: _stepMetricsLoaded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStepTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            isCompleted
                ? const Color.fromARGB(255, 245, 255, 248)
                : const Color.fromARGB(255, 250, 250, 250),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isCompleted
                  ? const Color.fromARGB(255, 165, 235, 195)
                  : const Color.fromARGB(255, 230, 230, 230),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? const Color.fromARGB(255, 215, 250, 228)
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCompleted ? _accentGreen : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? _textDark : Colors.grey[700],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle_rounded,
              color: _accentGreen,
              size: 20,
            )
          else
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_fixedRateText),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

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
              const Text(
                'Create a New Loan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Configure your loan terms below',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _accentTealLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance,
                  size: 14,
                  color: _fixedRateText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Illager Bank',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _fixedRateText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Economic Metrics Row ───────────────────────────────────────────────────

  Widget _buildEconomicMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoTile(
            icon: Icons.trending_up,
            label: 'Current Inflation Rate',
            value: '${(_inflation * 100).toStringAsFixed(2)}%',
            accent: _warningAmber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoTile(
            icon: Icons.percent,
            label: 'Current Interest Rate',
            value: '${(_interestRate * 100).toStringAsFixed(2)}%',
            accent: _fixedRateText,
          ),
        ),
      ],
    );
  }

  // ── Max Weekly Payment Card ────────────────────────────────────────────────

  Widget _buildMaxWeeklyPaymentCard() {
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
              color: _accentGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: _accentGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Max Weekly Payment',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'The maximum amount you can afford to pay weekly on a loan.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(_maxWeeklyPayment),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ── Loan Amount Slider ─────────────────────────────────────────────────────

  Widget _buildLoanAmountSlider() {
    final double maxLoanAt12 = calculateMaxLoan(
      _maxWeeklyPayment,
      12,
      _interestRate,
      _assets,
      _loans,
    );
    final double effectiveMax =
        (maxLoanAt12.isFinite && maxLoanAt12 >= 1.0) ? maxLoanAt12 : 1.0;

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
                  Icons.attach_money,
                  color: _accentTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Loan Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              Text(
                _formatCurrency(_loanAmount),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _accentTeal,
              inactiveTrackColor: _accentTealLight,
              thumbColor: _accentTeal,
              overlayColor: _accentTeal.withOpacity(0.2),
              valueIndicatorColor: _accentTeal,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: _loanAmount.clamp(1.0, effectiveMax),
              min: 1.0,
              max: effectiveMax,
              label: _formatCurrency(_loanAmount),
              onChanged: (value) {
                setState(() {
                  _loanAmount = double.parse(value.toStringAsFixed(2));
                  _loanAmountController.text = _loanAmount.toStringAsFixed(2);
                  // Check if the current duration allows this loan amount
                  _adjustDurationForLoanAmount();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${_formatCurrency(1.0)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _loanAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter exact amount',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: const Color.fromARGB(255, 248, 248, 248),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
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
                      borderSide: const BorderSide(
                        color: _accentTeal,
                        width: 2,
                      ),
                    ),
                  ),
                  onSubmitted: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      setState(() {
                        _loanAmount = parsed.clamp(1.0, effectiveMax);
                        _loanAmountController.text = _loanAmount
                            .toStringAsFixed(2);
                        _adjustDurationForLoanAmount();
                      });
                    }
                  },
                ),
              ),
              Text(
                'Max: ${_formatCurrency(effectiveMax)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Loan Duration Slider ───────────────────────────────────────────────────

  Widget _buildLoanDurationSlider() {
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
                  color: Colors.deepPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Loan Duration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const Spacer(),
              Text(
                '$_loanWeekDuration week${_loanWeekDuration != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.deepPurple,
              inactiveTrackColor: Colors.deepPurple.withOpacity(0.15),
              thumbColor: Colors.deepPurple,
              overlayColor: Colors.deepPurple.withOpacity(0.2),
              valueIndicatorColor: Colors.deepPurple,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: _loanWeekDuration.toDouble(),
              min: 1,
              max: 12,
              divisions: 11,
              label:
                  '$_loanWeekDuration week${_loanWeekDuration != 1 ? 's' : ''}',
              onChanged: (value) {
                setState(() {
                  _loanWeekDuration = value.round();
                  // Adjust loan amount if it exceeds the max for this duration
                  _adjustLoanAmountForDuration();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 week',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                '12 weeks',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Loan Options Row (Fixed Rate + Auto-Pay) ───────────────────────────────

  Widget _buildLoanOptionsRow() {
    return Row(
      children: [
        Expanded(child: _buildFixedRateToggle()),
        const SizedBox(width: 16),
        Expanded(child: _buildAutoPayToggle()),
      ],
    );
  }

  Widget _buildFixedRateToggle() {
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
                  _fixedRate
                      ? _fixedRateText.withOpacity(0.12)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lock_outline,
              color: _fixedRate ? _fixedRateText : Colors.grey[500],
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fixed Rate',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fixedRate
                      ? 'Rate locked at ${((_interestRate + 0.02) * 100).toStringAsFixed(2)}%'
                      : 'Variable rate applies',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _fixedRate,
            activeColor: _fixedRateText,
            onChanged: (value) => setState(() => _fixedRate = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoPayToggle() {
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
                      ? 'Payments deducted automatically.'
                      : 'Enable automatic weekly payments.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoPay,
            activeColor: _accentGreen,
            onChanged: (value) => setState(() => _autoPay = value),
          ),
        ],
      ),
    );
  }

  // ── Loan Summary Grid ──────────────────────────────────────────────────────

  Widget _buildLoanSummaryGrid() {
    final double weeklyPayment = _calculateWeeklyPayment();
    final double totalRepayment = weeklyPayment * _loanWeekDuration;
    final double totalInterest = totalRepayment - _loanAmount;
    final double effectiveRate =
        _fixedRate ? _interestRate + 0.02 : _interestRate;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildInfoTile(
          icon: Icons.attach_money,
          label: 'Loan Principal',
          value: _formatCurrency(_loanAmount),
          accent: _accentTeal,
        ),
        _buildInfoTile(
          icon: Icons.payments_outlined,
          label: 'Weekly Payment',
          value: _formatCurrency(weeklyPayment),
          accent: _accentGreen,
        ),
        _buildInfoTile(
          icon: Icons.money,
          label: 'Total Interest',
          value: _formatCurrency(totalInterest < 0 ? 0 : totalInterest),
          accent: _variableRateText,
        ),
        _buildInfoTile(
          icon: Icons.account_balance_wallet,
          label: 'Total Repayment',
          value: _formatCurrency(totalRepayment),
          accent: Colors.deepPurple,
        ),
        _buildInfoTile(
          icon: Icons.percent,
          label: 'Effective Interest Rate',
          value: '${(effectiveRate * 100).toStringAsFixed(2)}%',
          accent: _fixedRate ? _fixedRateText : _variableRateText,
        ),
        _buildInfoTile(
          icon: Icons.calendar_today,
          label: 'Duration',
          value: '$_loanWeekDuration week${_loanWeekDuration != 1 ? 's' : ''}',
          accent: Colors.blueGrey,
        ),
      ],
    );
  }

  // ── Amortisation Chart ─────────────────────────────────────────────────────

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
        title: 'Projected Remaining Principal',
        subtitle: 'Principal',
        data: _buildProjectedAmortisationPoints(),
        xAxisLabel: 'Week',
        yAxisLabel: 'Principal (\$)',
      ),
    );
  }

  List<PriceVsTime> _buildProjectedAmortisationPoints() {
    final points = <PriceVsTime>[];
    final effectiveRate = _fixedRate ? _interestRate + 0.02 : _interestRate;

    DateTime date = DateTime.now();

    // Anchor: starting principal
    points.add(PriceVsTime(time: date, price: _loanAmount));

    double runningPrincipal = _loanAmount;
    int installmentsLeft = _loanWeekDuration;

    while (runningPrincipal > 0 && installmentsLeft > 0) {
      date = date.add(const Duration(days: 7));

      final payment =
          (runningPrincipal * (1 + effectiveRate)) / installmentsLeft;
      runningPrincipal = runningPrincipal - payment;
      if (runningPrincipal < 0) runningPrincipal = 0;
      installmentsLeft--;

      points.add(PriceVsTime(time: date, price: runningPrincipal));
    }

    return points;
  }

  // ── Create Loan Button ─────────────────────────────────────────────────────

  Widget _buildCreateLoanButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isCreatingLoan ? null : _confirmAndCreateLoan,
        icon:
            _isCreatingLoan
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.check_circle_outline, size: 20),
        label: const Text(
          'Create Loan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

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
            'All loans subject to terms & conditions',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Info Tile (reusable) ───────────────────────────────────────────────────

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

  // ── Confirmation Dialog & Loan Creation ────────────────────────────────────

  Future<void> _confirmAndCreateLoan() async {
    final weeklyPayment = _calculateWeeklyPayment();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: _warningAmber,
                  size: 28,
                ),
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
                _buildConfirmationRow(
                  'Principal',
                  _formatCurrency(_loanAmount),
                ),
                _buildConfirmationRow(
                  'Duration',
                  '$_loanWeekDuration week${_loanWeekDuration != 1 ? 's' : ''}',
                ),
                _buildConfirmationRow(
                  'Weekly Payment',
                  _formatCurrency(weeklyPayment),
                ),
                _buildConfirmationRow(
                  'Rate Type',
                  _fixedRate ? 'Fixed' : 'Variable',
                ),
                _buildConfirmationRow(
                  'Auto-Pay',
                  _autoPay ? 'Enabled' : 'Disabled',
                ),
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
                      const Icon(
                        Icons.info_outline,
                        color: _warningAmber,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'By taking this loan you agree to make timely weekly '
                          'payments. Failure to meet payment obligations will '
                          'result in missed payment penalties, increased interest '
                          'rates, and potential asset seizure by Illager Bank.',
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
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
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
          ),
    );

    if (confirmed == true) {
      await _executeLoanCreation();
    }
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeLoanCreation() async {
    setState(() => _isCreatingLoan = true);

    try {
      final result = await createLoan(
        _loanAmount,
        _loanWeekDuration,
        _fixedRate,
        _autoPay,
      );

      if (result == true) {
        _showSnackBar('Loan created successfully!');
        if (mounted) {
          context.pop(true);
        }
      } else {
        _showSnackBar(
          'Failed to create loan. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error creating loan: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isCreatingLoan = false);
    }
  }

  // ── Dynamic Slider Adjustment Logic ────────────────────────────────────────

  /// When the user adjusts the loan amount slider, check if the currently
  /// selected duration allows the weekly payment to stay within
  /// _maxWeeklyPayment. If not, increase the duration until it does.
  void _adjustDurationForLoanAmount() {
    for (int weeks = _loanWeekDuration; weeks <= 12; weeks++) {
      final weeklyPayment = _calculateWeeklyPaymentFor(_loanAmount, weeks);
      if (weeklyPayment <= _maxWeeklyPayment) {
        _loanWeekDuration = weeks;
        return;
      }
    }
    // If even 12 weeks isn't enough, set to 12 and clamp the loan amount
    _loanWeekDuration = 12;
    final maxAtTwelve = calculateMaxLoan(
      _maxWeeklyPayment,
      12,
      _interestRate,
      _assets,
      _loans,
    );
    if (_loanAmount > maxAtTwelve || !maxAtTwelve.isFinite) {
      final safeMax =
          (maxAtTwelve.isFinite && maxAtTwelve >= 1.0) ? maxAtTwelve : 1.0;
      _loanAmount = safeMax;
      _loanAmountController.text = _loanAmount.toStringAsFixed(2);
    }
  }

  /// When the user adjusts the duration slider, check if the selected loan
  /// amount is within the max allowed for that duration. If not, reduce
  /// the loan amount.
  void _adjustLoanAmountForDuration() {
    final maxForDuration = calculateMaxLoan(
      _maxWeeklyPayment,
      _loanWeekDuration,
      _interestRate,
      _assets,
      _loans,
    );
    final safeMax =
        (maxForDuration.isFinite && maxForDuration >= 1.0)
            ? maxForDuration
            : 1.0;
    if (_loanAmount > safeMax) {
      _loanAmount = safeMax;
      _loanAmountController.text = _loanAmount.toStringAsFixed(2);
    }
  }

  /// Calculate the weekly payment for a given principal and week count using
  /// the same amortisation logic the chart uses.
  double _calculateWeeklyPaymentFor(double principal, int weeks) {
    final effectiveRate = _fixedRate ? _interestRate + 0.02 : _interestRate;

    if (effectiveRate == 0 || weeks == 0) {
      return weeks == 0 ? double.infinity : principal / weeks;
    }

    // Standard amortisation weekly payment:
    // P * r / (1 - (1 + r)^(-n))   where r = effectiveRate / 7
    final r = effectiveRate / 7;
    final result = principal * r / (1 - pow(1 + r, -weeks));
    return result.isFinite ? result : double.infinity;
  }

  /// Calculate the weekly payment for the current slider selections.
  double _calculateWeeklyPayment() {
    return _calculateWeeklyPaymentFor(_loanAmount, _loanWeekDuration);
  }

  // ── Data Loading ───────────────────────────────────────────────────────────

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
      _stepMaxWeeklyPaymentLoaded = false;
      _stepAssetsLoaded = false;
      _stepLoansLoaded = false;
      _stepMetricsLoaded = false;
    });

    try {
      final p1 = SupabaseHelper.loan.calculateMaxWeeklyPayment().then((res) {
        if (mounted) setState(() => _stepMaxWeeklyPaymentLoaded = true);
        return res;
      });
      final p2 = SupabaseHelper.player.getUsersAssetEvaluation().then((res) {
        if (mounted) setState(() => _stepAssetsLoaded = true);
        return res;
      });
      final p3 = SupabaseHelper.player.getUsersOwedAmount().then((res) {
        if (mounted) setState(() => _stepLoansLoaded = true);
        return res;
      });
      final p4 = SupabaseHelper.loan.getEconomyMetrics().then((res) {
        if (mounted) setState(() => _stepMetricsLoaded = true);
        return res;
      });

      final futures = await Future.wait([p1, p2, p3, p4]);

      final maxWeeklyPayment = futures[0] as double? ?? 0.0;
      final assets = futures[1] as double? ?? 0.0;
      final loans = futures[2] as double? ?? 0.0;
      final metrics = futures[3] as ({double interestRate, double inflation})?;

      if (!mounted) return;

      setState(() {
        _maxWeeklyPayment = maxWeeklyPayment;
        _assets = assets;
        _loans = loans;
        _interestRate = metrics?.interestRate ?? 0.0;
        _inflation = metrics?.inflation ?? 0.0;
        _isLoading = false;

        // Initialize loan amount to a sensible default (half of max at 6 weeks)
        final maxAt6 = calculateMaxLoan(
          _maxWeeklyPayment,
          _loanWeekDuration,
          _interestRate,
          _assets,
          _loans,
        );
        _loanAmount = (maxAt6 / 2).clamp(
          1.0,
          maxAt6.clamp(1.0, double.infinity),
        );
        _loanAmountController.text = _loanAmount.toStringAsFixed(2);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to load data: $e', isError: true);
      }
    }
  }

  // ── Core Functions (preserved from original) ───────────────────────────────

  double calculateMaxLoan(
    double maxWeeklyPayment,
    int weekLoanDuration,
    double interestRate,
    double assets,
    double loans,
  ) {
    try {
      // final double balance = assets - loans;

      // When interest rate is zero, the formula degenerates (0/0 → NaN).
      // Fall back to simple multiplication.
      if (interestRate == 0) {
        return (maxWeeklyPayment * weekLoanDuration); //+ balance;
      }

      final lCash = maxWeeklyPayment * (weekLoanDuration / (1 + interestRate));

      final result = lCash; // + balance;
      return result.isFinite ? result : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool?> createLoan(
    double principal,
    int durationWeeks,
    bool fixedRate,
    bool autoPay,
  ) async {
    return await SupabaseHelper.loan.createLoan(
      principal,
      durationWeeks,
      fixedRate,
      autoPay,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';
}
