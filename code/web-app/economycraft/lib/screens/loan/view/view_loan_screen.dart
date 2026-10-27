import 'package:flutter/material.dart';

class ViewLoanScreen extends StatefulWidget {
  const ViewLoanScreen({super.key});

  @override
  State<ViewLoanScreen> createState() => _ViewLoanScreenState();
}

class _ViewLoanScreenState extends State<ViewLoanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Image.asset(
                "assets/images/illager_symbol.png",
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
            SizedBox(width: 16),
            const Text(
              'Current Illager Loan',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/background_images/quartz_background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main Content
        ],
      ),
    );
  }
}
