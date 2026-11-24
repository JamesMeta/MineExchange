import 'package:economycraft/classes/modals/inventory.dart';
import 'package:economycraft/classes/price_vs_time.dart';
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

  Future<List<PriceVsTime>?> getMarketItemPriceHistory(int marketItemId) async {
    try {
      final response = await _client
          .from("market_item_price_history")
          .select("*")
          .eq("market_item_id", marketItemId)
          .order("created_at", ascending: true)
          .limit(3000);

      // Aggregate price histories that have the same hour and find the average price for that hour
      final Map<String, List<double>> hourlyPrices = {};

      for (var priceHistoryMap in response) {
        final priceHistory = PriceVsTime(
          time: DateTime.parse(priceHistoryMap['created_at']),
          price: priceHistoryMap['sold_price'],
        );

        final hourKey =
            '${priceHistory.time.year}-${priceHistory.time.month}-${priceHistory.time.day}-${priceHistory.time.hour}';
        if (!hourlyPrices.containsKey(hourKey)) {
          hourlyPrices[hourKey] = [];
        }
        hourlyPrices[hourKey]!.add(priceHistory.price);
      }

      // Calculate the average price for each hour
      final List<PriceVsTime> aggregatedPrices =
          hourlyPrices.entries.map((entry) {
            final hourKey = entry.key;
            final prices = entry.value;
            final averagePrice = prices.reduce((a, b) => a + b) / prices.length;

            // Parse the hour key to create a DateTime object
            final parts = hourKey.split('-');
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final day = int.parse(parts[2]);
            final hour = int.parse(parts[3]);
            final time = DateTime(year, month, day, hour);

            return PriceVsTime(time: time, price: averagePrice);
          }).toList();

      return aggregatedPrices;
    } catch (e) {
      developer.log(
        'Error fetching price history for market item $marketItemId: $e',
      );
      return null;
    }
  }
}
