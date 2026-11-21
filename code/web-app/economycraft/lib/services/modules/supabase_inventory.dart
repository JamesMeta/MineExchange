import 'package:economycraft/classes/modals/inventory.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SupabaseInventory {
  static final _client = Supabase.instance.client;

  Future<List<Inventory>?> getUserInventory() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final userRowId = await SupabaseHelper.player.getPlayerId();

      final response = await _client
          .from("inventory")
          .select("*, valid_market_items:market_item_id(*)")
          .eq("user_id", userRowId);

      return response
          .map((inventoryMap) => Inventory.fromMap(inventoryMap))
          .toList();
    } catch (e) {
      developer.log('Error fetching user inventory $e');
      return null;
    }
  }
}
