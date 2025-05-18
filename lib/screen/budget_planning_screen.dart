import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BudgetPlanningScreen extends StatefulWidget {
  const BudgetPlanningScreen({super.key});

  @override
  State<BudgetPlanningScreen> createState() => _BudgetPlanningScreenState();
}

class _BudgetPlanningScreenState extends State<BudgetPlanningScreen> {
  final TextEditingController _budgetController = TextEditingController();
  double _budget = 0;
  double _spent = 0;
  bool _budgetSet = false;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchSpentAmount();
  }

  void _setBudget() {
    setState(() {
      _budget = double.tryParse(_budgetController.text) ?? 0;
      _budgetSet = true;
    });
    _budgetController.clear();
    _fetchSpentAmount(); // refresh spent after setting budget
  }

  Future<void> _fetchSpentAmount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: 'Expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth))
          .get();

      double totalSpent = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['amount'] != null) {
          totalSpent += (data['amount'] as num).toDouble();
        }
      }

      setState(() {
        _spent = totalSpent;
      });
    } catch (e) {
      print("Error fetching expenses: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = _budget == 0 ? 0 : (_spent / _budget).clamp(0.0, 1.0);
    double remaining = _budget - _spent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget Tracker'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Set Your Monthly Budget',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Month: ${DateFormat.yMMMM().format(_selectedMonth)}",
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedMonth,
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2100),
                      helpText: "Select Month",
                      fieldHintText: 'Month/Date/Year',
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedMonth = DateTime(picked.year, picked.month);
                      });
                      _fetchSpentAmount();
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 10),

            // Budget Input
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Budget (e.g., 5000)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _setBudget,
              child: const Text('Save Budget'),
            ),
            const SizedBox(height: 25),

            // Budget Progress & Chat Box
            if (_budgetSet) ...[
              const Divider(height: 30),
              Text(
                "Budget: Rs. ${_budget.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Spent: Rs. ${_spent.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 18,
                backgroundColor: Colors.grey[300],
                color: progress >= 1 ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 20),

              // Chat Style Box
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: progress >= 1 ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  progress >= 1
                      ? "⚠️ You've exceeded your budget by Rs. ${(_spent - _budget).toStringAsFixed(2)} for ${DateFormat.yMMMM().format(_selectedMonth)}."
                      : "✅ You have Rs. ${remaining.toStringAsFixed(2)} left in your budget for ${DateFormat.yMMMM().format(_selectedMonth)}.",
                  style: TextStyle(
                    fontSize: 16,
                    color: progress >= 1 ? Colors.red : Colors.green[800],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
