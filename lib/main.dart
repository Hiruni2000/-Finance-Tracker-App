import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wadayak/screen/Transaction_History_screen.dart';
import 'package:wadayak/screen/add_transaction_screen.dart';
import 'package:wadayak/screen/budget_planning_screen.dart';

import 'package:wadayak/screen/reports_insights_screen.dart';
import 'firebase_options.dart'; // generated file
import 'screen/login.dart';
import 'screen/register.dart';
import 'screen/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/addTransaction': (context) => const AddTransactionScreen(),
        '/transactionHistory': (context) => const TransactionHistoryScreen(),
        '/budgetPlanner': (context) =>BudgetPlanningScreen(),
        '/reports': (context) => const ReportsInsightsScreen(),
      },
    );
  }
}
