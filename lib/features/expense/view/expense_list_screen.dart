import 'package:flutter/material.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expense List')),
      body: Center(child: Text('Expense List Screen')),
    );
  }
}
