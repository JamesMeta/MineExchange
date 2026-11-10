import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingViewWidget extends StatelessWidget {
  final double _loadingProgress;
  final int _loadedStepsCount;
  final bool _stepMaxWeeklyPaymentLoaded;
  final bool _stepAssetsLoaded;
  final bool _stepLoansLoaded;
  final bool _stepMetricsLoaded;
  final Color _accentTealLight;
  final Color _accentGreen;
  final Color _fixedRateText;
  final Color _textDark;
  const LoadingViewWidget({
    super.key,
    required double loadingProgress,
    required int loadedStepsCount,
    required bool stepMaxWeeklyPaymentLoaded,
    required bool stepAssetsLoaded,
    required bool stepLoansLoaded,
    required bool stepMetricsLoaded,
    required Color accentTealLight,
    required Color accentGreen,
    required Color fixedRateText,
    required Color textDark,
  }) : _loadingProgress = loadingProgress,
       _loadedStepsCount = loadedStepsCount,
       _stepMaxWeeklyPaymentLoaded = stepMaxWeeklyPaymentLoaded,
       _stepAssetsLoaded = stepAssetsLoaded,
       _stepLoansLoaded = stepLoansLoaded,
       _stepMetricsLoaded = stepMetricsLoaded,
       _accentTealLight = accentTealLight,
       _accentGreen = accentGreen,
       _fixedRateText = fixedRateText,
       _textDark = textDark;

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(
                  color: _accentTealLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
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
              Text(
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
                  valueColor: AlwaysStoppedAnimation<Color>(_accentGreen),
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
                    style: TextStyle(
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
            Icon(Icons.check_circle_rounded, color: _accentGreen, size: 20)
          else
            SizedBox(
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
}
