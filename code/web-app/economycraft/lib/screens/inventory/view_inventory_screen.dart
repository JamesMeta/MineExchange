import 'package:economycraft/classes/modals/inventory.dart';
import 'package:economycraft/classes/modals/market_item.dart';
import 'package:economycraft/common_widgets/base_screen_widget.dart';
import 'package:economycraft/common_widgets/screen_central_body.dart';
import 'package:economycraft/screens/inventory/widgets/inventory_item_grid_tile.dart';
import 'package:economycraft/screens/inventory/widgets/widgets/inventory_item_dialog_widget.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewInventoryScreen extends StatefulWidget {
  const ViewInventoryScreen({super.key});

  @override
  State<ViewInventoryScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<ViewInventoryScreen> {
  late Future<List<Inventory>?> _inventoryItems;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Design Constants ──────────────────────────────────────────────────────

  static const Color _accentTeal = Color.fromARGB(255, 74, 237, 217);
  static const Color _accentTealLight = Color.fromARGB(255, 229, 255, 252);
  static const Color _headerBg = Color.fromARGB(255, 233, 233, 233);

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BaseScreenWidget(
      onBackPressed: () => context.pop(),
      appBarTitle: const Text(
        'Inventory',
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
      child: ScreenCentralBody(
        screenWidth: screenWidth * 0.7,
        screenHeight: screenHeight * 0.8,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildInventoryGrid()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _headerBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Deposited Items',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _refreshInventoryItems,
                icon: const Icon(Icons.refresh, color: _accentTeal),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search items by name...',
        prefixIcon: const Icon(Icons.search, color: _accentTeal),
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _searchController.clear(),
                )
                : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
          borderSide: const BorderSide(color: _accentTeal, width: 2),
        ),
      ),
    );
  }

  // ── Inventory Grid ────────────────────────────────────────────────────────

  Widget _buildInventoryGrid() {
    return FutureBuilder<List<Inventory>?>(
      future: _inventoryItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final filteredItems = _filterItems(snapshot.data!);

        if (filteredItems.isEmpty) {
          return _buildNoResultsState();
        }

        return _buildGridView(filteredItems);
      },
    );
  }

  Widget _buildGridView(List<Inventory> items) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return InventoryItemGridTile(
            inventoryItem: items[index],
            onTap: () => _showItemDialog(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_accentTeal),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text('Error loading inventory', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.grey[400], size: 60),
          const SizedBox(height: 16),
          const Text(
            'No items in your inventory',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Deposit items in-game or purchase them on the market to see them here.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, color: Colors.grey[400], size: 60),
          const SizedBox(height: 16),
          const Text(
            'No items match your search',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

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
            'EconomyCraft — Inventory Management',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          TextButton.icon(
            onPressed: _refreshInventoryItems,
            icon: const Icon(Icons.refresh, size: 18, color: _accentTeal),
            label: const Text('Refresh', style: TextStyle(color: _accentTeal)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  List<Inventory> _filterItems(List<Inventory> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where(
          (item) => item.marketItem.name.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  void _showItemDialog(Inventory item) {
    showDialog(
      context: context,
      builder: (context) => InventoryItemDialogWidget(inventoryItem: item),
    );
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  void _loadInventoryItems() {
    _inventoryItems = _fetchInventoryItems();
  }

  void _refreshInventoryItems() {
    setState(() {
      _loadInventoryItems();
    });
  }

  Future<List<Inventory>?> _fetchInventoryItems() {
    return SupabaseHelper.inventory.getUserInventory();
  }
}
