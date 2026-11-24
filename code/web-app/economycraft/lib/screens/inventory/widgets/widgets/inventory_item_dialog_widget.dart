import 'package:cached_network_image/cached_network_image.dart';
import 'package:economycraft/classes/modals/inventory.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/common_widgets/linegraph_1_widget.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class InventoryItemDialogWidget extends StatefulWidget {
  final Inventory inventoryItem;

  const InventoryItemDialogWidget({super.key, required this.inventoryItem});

  // ── Design Constants ────────────────────────────────────────────────────

  static const Color _accentTeal = Color.fromARGB(255, 74, 237, 217);
  static const Color _accentTealLight = Color.fromARGB(255, 229, 255, 252);
  static const Color _accentGreen = Color.fromARGB(255, 23, 221, 97);
  static const Color _textDark = Color.fromARGB(255, 50, 50, 50);

  @override
  State<InventoryItemDialogWidget> createState() =>
      _InventoryItemDialogWidgetState();
}

/// Hours of price data each time-range option represents.
/// Each [PriceVsTime] is a 1-hour average, so 24 entries = 1 day.
enum _TimeRange {
  oneDay('1D', 24),
  fiveDays('5D', 24 * 5),
  oneMonth('1M', 24 * 30),
  sixMonths('6M', 24 * 180),
  oneYear('1Y', 24 * 365),
  allTime('All', -1);

  const _TimeRange(this.label, this.hours);

  final String label;

  /// Number of hourly data-points to display. -1 means show everything.
  final int hours;
}

class _InventoryItemDialogWidgetState
    extends State<InventoryItemDialogWidget> {
  late Future<List<PriceVsTime>> _priceHistoryFuture;
  _TimeRange _selectedRange = _TimeRange.oneMonth;

  @override
  void initState() {
    super.initState();
    _priceHistoryFuture = _getPriceHistory();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
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
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 12),
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
        widget.inventoryItem.marketItem.name,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: InventoryItemDialogWidget._textDark,
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
        color: InventoryItemDialogWidget._accentTealLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
      ),
      padding: const EdgeInsets.all(8),
      child: CachedNetworkImage(
        imageUrl: widget.inventoryItem.marketItem.avatarUrl,
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
        _buildDetailRow('Name', widget.inventoryItem.marketItem.name),
        const SizedBox(height: 8),
        _buildDetailRow('Tag', widget.inventoryItem.marketItem.minecraftTag),
        const SizedBox(height: 8),
        _buildDetailRow('Quantity', 'x${widget.inventoryItem.quantity}'),
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
              color: InventoryItemDialogWidget._textDark,
            ),
          ),
        ),
      ],
    );
  }

  // ── Time Range Selector ───────────────────────────────────────────────────

  Widget _buildTimeRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _TimeRange.values.map((range) {
        final isSelected = range == _selectedRange;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: ChoiceChip(
            label: Text(
              range.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : InventoryItemDialogWidget._textDark,
              ),
            ),
            selected: isSelected,
            selectedColor: InventoryItemDialogWidget._accentTeal,
            backgroundColor: Colors.grey[100],
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (_) => _onRangeChanged(range),
          ),
        );
      }).toList(),
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
        border: Border.all(color: const Color.fromARGB(255, 220, 220, 220)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(20, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<List<PriceVsTime>>(
        future: _priceHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildChartShimmer();
          }
          if (snapshot.hasError) {
            return _buildChartError();
          }

          final data = _applyTimeRange(snapshot.data ?? []);

          if (data.isEmpty) {
            return _buildChartEmpty();
          }

          return Linegraph1Widget(
            title: 'Price History',
            subtitle: widget.inventoryItem.marketItem.name,
            data: data,
            xAxisLabel: 'Date',
            yAxisLabel: 'Price (\$)',
          );
        },
      ),
    );
  }

  Widget _buildChartShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            Container(
              width: 140,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            // Chart area placeholder
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Y-axis label placeholder
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (_) => Container(
                        width: 30,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chart bars placeholder
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(10, (i) {
                        final height = 40.0 + (i % 3) * 30.0 + (i * 7 % 50);
                        return Container(
                          width: 16,
                          height: height,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // X-axis labels placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (_) => Container(
                  width: 36,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 36),
          const SizedBox(height: 8),
          Text(
            'Error fetching price history',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildChartEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.show_chart, color: Colors.grey[300], size: 36),
          const SizedBox(height: 8),
          Text(
            'No price data for this range',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
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
          top: BorderSide(color: Color.fromARGB(255, 229, 255, 252), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildBuyButton(),
          const SizedBox(width: 10),
          _buildSellButton(),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: InventoryItemDialogWidget._accentTeal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Close', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton() {
    return ElevatedButton.icon(
      onPressed: _onBuyPressed,
      icon: const Icon(Icons.add_shopping_cart, size: 16),
      label: const Text('Buy'),
      style: ElevatedButton.styleFrom(
        backgroundColor: InventoryItemDialogWidget._accentGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  Widget _buildSellButton() {
    return ElevatedButton.icon(
      onPressed: _onSellPressed,
      icon: const Icon(Icons.sell_outlined, size: 16),
      label: const Text('Sell'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _onRangeChanged(_TimeRange range) {
    setState(() {
      _selectedRange = range;
    });
  }

  /// TODO: Implement buy logic.
  void _onBuyPressed() {
    // Placeholder — will navigate to or trigger the buy flow.
  }

  /// TODO: Implement sell logic.
  void _onSellPressed() {
    // Placeholder — will navigate to or trigger the sell flow.
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  /// Trims the full price-history list to the selected [_TimeRange].
  List<PriceVsTime> _applyTimeRange(List<PriceVsTime> all) {
    if (all.isEmpty || _selectedRange == _TimeRange.allTime) return all;

    final cutoff = DateTime.now().subtract(
      Duration(hours: _selectedRange.hours),
    );

    return all.where((p) => p.time.isAfter(cutoff)).toList();
  }

  Future<List<PriceVsTime>> _getPriceHistory() async {
    final response = await SupabaseHelper.inventory.getMarketItemPriceHistory(
      widget.inventoryItem.marketItem.id,
    );
    return response ?? [];
  }
}
