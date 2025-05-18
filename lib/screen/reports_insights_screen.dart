import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsInsightsScreen extends StatelessWidget {
  const ReportsInsightsScreen({super.key});

  Future<Map<String, double>> fetchCategoryData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .where('type', isEqualTo: 'Expense')
        .get();

    Map<String, double> data = {};

    for (var doc in query.docs) {
      final tx = doc.data();
      final category = tx['category'];
      final amount = (tx['amount'] ?? 0).toDouble();

      if (data.containsKey(category)) {
        data[category] = data[category]! + amount;
      } else {
        data[category] = amount;
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports & Insights"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, double>>(
        future: fetchCategoryData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data to display."));
          }

          final data = snapshot.data!;
          final total = data.values.fold(0.0, (sum, val) => sum + val);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("Spending by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: data.entries.map((e) {
                        final percentage = (e.value / total) * 100;
                        return PieChartSectionData(
                          value: e.value,
                          title: "${e.key} \n${percentage.toStringAsFixed(1)}%",
                          color: Colors.primaries[data.keys.toList().indexOf(e.key) % Colors.primaries.length],
                          radius: 100,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
