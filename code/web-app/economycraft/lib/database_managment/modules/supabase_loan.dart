import 'package:economycraft/classes/modals/loan.dart';
import 'package:economycraft/database_managment/modules/supabase_player.dart';
import 'package:economycraft/database_managment/supabase_helper.dart';
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
}
