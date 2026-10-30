import 'package:economycraft/classes/modals/loan.dart';
import 'package:economycraft/services/modules/supabase_player.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

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
}
