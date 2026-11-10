import 'package:economycraft/classes/modals/loan.dart';
import 'package:economycraft/services/supabase_helper.dart';
import 'package:economycraft/screens/loan/widgets/loan_list_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  late Future<List<Loan>?> _currentLoans;

  @override
  void initState() {
    _currentLoans = getCurrentLoans();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildBackground(),
          Center(child: _buildMainCard(screenWidth, screenHeight)),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/illager_symbol.png',
            fit: BoxFit.cover,
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 16),
          const Text(
            'Illager Loans',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 229, 255, 252),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/background_images/quartz_background.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ── Main Card ───────────────────────────────────────────────────────────────

  Widget _buildMainCard(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.6,
      height: screenHeight * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 189, 189, 189),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), _buildLoanList(), _buildFooter()],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 233, 233, 233),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Current Loans',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          _buildNewLoanButton(),
        ],
      ),
    );
  }

  Widget _buildNewLoanButton() {
    return ElevatedButton.icon(
      onPressed: _navigateToNewLoan,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('New Loan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 23, 221, 97),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  // ── Loan List ───────────────────────────────────────────────────────────────

  Widget _buildLoanList() {
    return Expanded(
      child: FutureBuilder<List<Loan>?>(
        future: _currentLoans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          return _buildLoanListView(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoanListView(List<Loan> loans) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: loans.length,
        itemBuilder:
            (context, index) => LoanListTileWidget(
              loan: loans[index],
              onTap: () => _navigateToLoanDetail(loans[index]),
            ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Color.fromARGB(255, 74, 237, 217),
        ),
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
          const Text('Error loading loans', style: TextStyle(fontSize: 16)),
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
          Icon(
            Icons.account_balance_outlined,
            color: Colors.grey[400],
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'No active loans',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Apply for a loan to get started.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color.fromARGB(255, 229, 255, 252), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Illager Bank — your trusted lender',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          TextButton.icon(
            onPressed: _refreshLoans,
            icon: const Icon(
              Icons.refresh,
              size: 18,
              color: Color.fromARGB(255, 74, 237, 217),
            ),
            label: const Text(
              'Refresh',
              style: TextStyle(color: Color.fromARGB(255, 74, 237, 217)),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigation (placeholders) ────────────────────────────────────────────────

  void _navigateToLoanDetail(Loan loan) async {
    final response = await context.push("/home/loans/view", extra: loan);

    if (response == true) {
      _refreshLoans();
    }
  }

  void _navigateToNewLoan() async {
    final response = await context.push("/home/loans/create");

    if (response == true) {
      _refreshLoans();
    }
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  void _refreshLoans() {
    setState(() {
      _currentLoans = getCurrentLoans();
    });
  }

  Future<List<Loan>?> getCurrentLoans() {
    return SupabaseHelper.loan.getUsersLoans();
  }
}
