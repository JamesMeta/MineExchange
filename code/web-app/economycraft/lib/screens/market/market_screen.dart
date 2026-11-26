import 'package:economycraft/classes/modals/product.dart';
import 'package:economycraft/common_widgets/base_screen_widget.dart';
import 'package:economycraft/common_widgets/screen_central_body.dart';
import 'package:flutter/material.dart';
import 'package:economycraft/services/supabase_helper.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late Future<List<Product>?> productsFuture;

  @override
  void initState() {
    productsFuture = fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return BaseScreenWidget(
      appBarTitle: Text("Market"),
      child: ScreenCentralBody(
        screenWidth: screenWidth * 0.8,
        screenHeight: screenHeight * 0.8,
        child: Column(children: []),
      ),
    );
  }

  Future<List<Product>?> fetchProducts() async {
    final products = await SupabaseHelper.product.getAllProducts();
    return products;
  }
}
