import 'dart:math';

import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';

class CreateLoanScreen extends StatefulWidget {
  const CreateLoanScreen({super.key});

  @override
  State<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends State<CreateLoanScreen> {
  int _loanWeekDuration = 12;
  late Future<double> _maxWeeklyPayment;
  late Future<double> _assets;
  late Future<double> _loans;
  late Future<double> _interestRate;
  late Future<double> _maxLoan;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Image.asset(
                "assets/images/illager_symbol.png",
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
            SizedBox(width: 16),
            const Text(
              'New Illager Loan',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/background_images/quartz_background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main Content
          Center(
            child: Container(
              width: screenWidth * 0.6,
              height: screenHeight * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create a New Loan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Additional form fields and buttons can be added here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getData() async {
    final futures = await Future.wait([
      SupabaseHelper.loan.calculateMaxWeeklyPayment(),
      SupabaseHelper.player.getUsersAssetEvaluation(),
      SupabaseHelper.player.getUsersOwedAmount(),
      SupabaseHelper.loan.getEconomyMetrics(),
    ]);

    _maxWeeklyPayment = Future.value(futures[0] as double? ?? 0.0);
    _assets = Future.value(futures[1] as double? ?? 0.0);
    _loans = Future.value(futures[2] as double? ?? 0.0);
    _interestRate = Future.value(
      (futures[3] as ({double interestRate, double inflation})?)
              ?.interestRate ??
          0.0,
    );
    _maxLoan = Future.value(
      calculateMaxLoan(
        await _maxWeeklyPayment,
        _loanWeekDuration,
        await _interestRate,
        await _assets,
        await _loans,
      ),
    );
  }

  double calculateMaxLoan(
    double maxWeeklyPayment,
    int weekLoanDuration,
    double interestRate,
    double assets,
    double loans,
  ) {
    try {
      final double balance = assets - loans;

      final lCash =
          maxWeeklyPayment *
          ((1 - pow(1 + (interestRate), -weekLoanDuration)) /
              (interestRate / 7));

      return lCash + balance;
    } catch (e) {
      return 0;
    }
  }
}
