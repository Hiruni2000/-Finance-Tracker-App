import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          double totalIncome = 0.0;
          double totalExpenses = 0.0;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final double amount = (data['amount'] as num).toDouble();
            final String type = data['type'];

            if (type == 'Income') {
              totalIncome += amount;
            } else if (type == 'Expense') {
              totalExpenses += amount;
            }
          }

          double remainingBudget = totalIncome - totalExpenses;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Budget Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard("Income", totalIncome, Colors.green),
                    _buildStatCard("Expenses", totalExpenses, Colors.red),
                    _buildStatCard("Remaining", remainingBudget, Colors.blue),
                  ],
                ),
                const SizedBox(height: 30),

                // Navigation Buttons
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addTransaction');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Transaction"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transactionHistory');
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("View Transaction History"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/budgetPlanner');
                  },
                  icon: const Icon(Icons.pie_chart),
                  label: const Text("Plan Monthly Budget"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/reports');
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text("Reports & Insights"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),


              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text("${value.toStringAsFixed(2)}",
                style: TextStyle(color: color, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
