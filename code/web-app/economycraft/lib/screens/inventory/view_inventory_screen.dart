import 'package:economycraft/common_widgets/base_screen_widget.dart';
import 'package:economycraft/common_widgets/screen_central_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewInventoryScreen extends StatefulWidget {
  const ViewInventoryScreen({super.key});

  @override
  State<ViewInventoryScreen> createState() => _ViewInventoryScreenState();
}

class _ViewInventoryScreenState extends State<ViewInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BaseScreenWidget(
      onBackPressed: () {
        context.pop();
      },
      appBarTitle: const Text(
        'Inventory',
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
      child: ScreenCentralBody(
        screenWidth: screenWidth * 0.7,
        screenHeight: screenHeight * 0.8,
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.1),
            const Text(
              'Inventory Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.05),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
