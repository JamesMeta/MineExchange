import 'package:economycraft/classes/modals/loan.dart';
import 'package:economycraft/services/modules/supabase_player.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:math';

class SupabaseLoan {
  static final _client = Supabase.instance.client;

  Future<List<Loan>?> getUsersLoans() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();

      final response = await _client
          .from("loans")
          .select()
          .eq("user_id", userRowId);

      return response.map((loanMap) => Loan.fromMap(loanMap)).toList();
    } catch (e) {
      developer.log('Error fetching user loans $e');
      return null;
    }
  }

  Future<bool?> setLoanPaymentForPayPeriod(
    Loan loan,
    double paymentAmount,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final response =
          await _client
              .from("loans")
              .update({"current_payment_amount": paymentAmount})
              .eq('id', loan.id)
              .select();

      if (response == null || response.isEmpty) {
        return false;
      }
      return true;
    } catch (e) {
      developer.log('Error setting loan payment  $e');
      return null;
    }
  }

  Future<bool?> updateLoanAutopaymentStatus(Loan loan, bool state) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final response =
          await _client
              .from("loans")
              .update({"auto_pay": state})
              .eq('id', loan.id)
              .select();

      if (response == null || response.isEmpty) {
        return false;
      }
      return true;
    } catch (e) {
      developer.log('Error setting autopayment state  $e');
      return null;
    }
  }

  Future<double?> calculateMaxWeeklyPayment() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final results = await Future.wait<dynamic>([
        SupabaseHelper.player.calculateUsersAvgWeeklyIncome(),
        _client
            .from("economy_metrics")
            .select('inflation, interest_rate')
            .order('created_at', ascending: false) // Sort newest first
            .limit(1) // Restrict to 1 row
            .maybeSingle(),
      ]);
      final averageWeeklyIncome = results[0] as double?;
      final response = results[1] as Map<String, dynamic>?;

      if (response == null || averageWeeklyIncome == null) {
        return null;
      }

      final double inflation = response["inflation"];

      final safeWeeklySurplus = averageWeeklyIncome * (1 - inflation);
      final maximumSafePayment = safeWeeklySurplus * 0.5;

      return maximumSafePayment;
    } catch (e) {
      developer.log('Error calculating max weekly payment  $e');
      return null;
    }
  }

  Future<({double interestRate, double inflation})?> getEconomyMetrics() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final response =
          await _client
              .from("economy_metrics")
              .select('interest_rate, inflation')
              .order('created_at', ascending: false) // Sort newest first
              .limit(1) // Restrict to 1 row
              .maybeSingle();

      if (response == null) {
        return null;
      }

      final interestRate = response['interest_rate'];
      final inflation = response['inflation'];
      if (interestRate is! num || inflation is! num) {
        return null;
      }

      return (
        interestRate: interestRate.toDouble(),
        inflation: inflation.toDouble(),
      );
    } catch (e) {
      developer.log('Error fetching economy metrics: $e');
      return null;
    }
  }
}
