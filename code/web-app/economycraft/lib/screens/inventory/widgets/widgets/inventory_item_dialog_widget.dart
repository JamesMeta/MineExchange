import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:economycraft/classes/modals/inventory.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_1_widget.dart';
import 'package:flutter/material.dart';

class InventoryItemDialogWidget extends StatelessWidget {
  final Inventory inventoryItem;

  const InventoryItemDialogWidget({super.key, required this.inventoryItem});

  // ── Design Constants ────────────────────────────────────────────────────

  static const Color _accentTeal = Color.fromARGB(255, 74, 237, 217);
  static const Color _accentTealLight = Color.fromARGB(255, 229, 255, 252);
  static const Color _textDark = Color.fromARGB(255, 50, 50, 50);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemInfoRow(),
                    const SizedBox(height: 24),
                    _buildPriceChart(),
                  ],
                ),
              ),
            ),
            _buildDialogActions(context),
          ],
        ),
      ),
    );
  }

  // ── Dialog Header ─────────────────────────────────────────────────────────

  Widget _buildDialogHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 233, 233, 233),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Text(
        inventoryItem.marketItem.name,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _textDark,
        ),
      ),
    );
  }

  // ── Item Info Row ─────────────────────────────────────────────────────────

  Widget _buildItemInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDialogAvatar(),
        const SizedBox(width: 20),
        Expanded(child: _buildItemDetails()),
      ],
    );
  }

  Widget _buildDialogAvatar() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: _accentTealLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 220, 220, 220),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: CachedNetworkImage(
        imageUrl: inventoryItem.marketItem.avatarUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Name', inventoryItem.marketItem.name),
        const SizedBox(height: 8),
        _buildDetailRow('Tag', inventoryItem.marketItem.minecraftTag),
        const SizedBox(height: 8),
        _buildDetailRow('Quantity', 'x${inventoryItem.quantity}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ── Price Chart ───────────────────────────────────────────────────────────

  Widget _buildPriceChart() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 220, 220, 220),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Linegraph1Widget(
        title: 'Price History',
        subtitle: inventoryItem.marketItem.name,
        data: _getToyPriceHistory(),
        xAxisLabel: 'Date',
        yAxisLabel: 'Price (\$)',
      ),
    );
  }

  // ── Dialog Actions ────────────────────────────────────────────────────────

  Widget _buildDialogActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 229, 255, 252),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _accentTeal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Close', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── Toy Data (replace with real service call) ─────────────────────────────

  /// TODO: Replace with a real API call to fetch price history for
  /// inventoryItem.marketItem.id once the backend is ready.
  List<PriceVsTime> _getToyPriceHistory() {
    final random = Random(inventoryItem.marketItem.id);
    final now = DateTime.now();
    final basePrice = (inventoryItem.marketItem.id * 15 + 10).toDouble();

    return List.generate(14, (i) {
      final date = now.subtract(Duration(days: 13 - i));
      final fluctuation = (random.nextDouble() - 0.5) * basePrice * 0.3;
      final price = (basePrice + fluctuation).clamp(1.0, double.infinity);
      return PriceVsTime(time: date, price: double.parse(price.toStringAsFixed(2)));
    });
  }
}
