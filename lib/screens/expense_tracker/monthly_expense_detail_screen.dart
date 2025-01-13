import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/data/expense_data.dart';

class MonthlyExpenseDetailScreen extends StatelessWidget {
  final String monthYear;

  const MonthlyExpenseDetailScreen({super.key, required this.monthYear});

  @override
  Widget build(BuildContext context) {
    final expenseData = Provider.of<ExpenseData>(context);
    final allExpenses = expenseData.getAllExpenseList();

    // Filter expenses for the selected month-year
    final month = int.parse(monthYear.split('-')[0]);
    final year = int.parse(monthYear.split('-')[1]);
    final filteredExpenses = allExpenses.where((expense) {
      return expense.dateTime.month == month && expense.dateTime.year == year;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Expenses for $monthYear",
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: filteredExpenses.isEmpty
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
                    "No expenses for $monthYear.",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final expense = filteredExpenses[index];
                return ListTile(
                  title: Text(expense.name),
                  subtitle: Text(
                      "${expense.dateTime.day}-${expense.dateTime.month}-${expense.dateTime.year}"),
                  trailing: Text(
                    "Rs ${expense.amount}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}
