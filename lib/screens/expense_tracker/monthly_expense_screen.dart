import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/data/expense_data.dart';
import 'package:todo_app/screens/expense_tracker/monthly_expense_detail_screen.dart';

class MonthlyExpenseScreen extends StatelessWidget {
  const MonthlyExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseData = Provider.of<ExpenseData>(context);
    final allExpenses = expenseData.getAllExpenseList();

    // Generate month-year map
    final Map<String, double> monthlySummary = {};
    for (var expense in allExpenses) {
      String monthYear =
          "${expense.dateTime.month.toString().padLeft(2, '0')}-${expense.dateTime.year}";
      double amount = double.tryParse(expense.amount) ?? 0;
      monthlySummary[monthYear] = (monthlySummary[monthYear] ?? 0) + amount;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: const Text(
          "Monthly Expenses",
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: monthlySummary.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No expenses available.",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              children: monthlySummary.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key), // Month-Year
                  subtitle: Text("Total: Rs ${entry.value.toStringAsFixed(2)}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonthlyExpenseDetailScreen(
                          monthYear: entry.key,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
