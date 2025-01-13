import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/data/day_time_helper.dart';
import 'package:todo_app/data/expense_data.dart';
import 'package:todo_app/screens/expense_tracker/bar_graph/bar_graph.dart';
import 'package:intl/intl.dart';

class ExpenseSummary extends StatelessWidget {
  final DateTime startOfTheWeek;
  const ExpenseSummary({super.key, required this.startOfTheWeek});

  double calaculateMax(
      ExpenseData value,
      String sunday,
      String monday,
      String tuesday,
      String wednesday,
      String thursday,
      String friday,
      String saturday) {
    double? max = 100;
    List<double> values = [
      value.calculateDailyExpenseSummary()[sunday] ?? 0,
      value.calculateDailyExpenseSummary()[monday] ?? 0,
      value.calculateDailyExpenseSummary()[tuesday] ?? 0,
      value.calculateDailyExpenseSummary()[wednesday] ?? 0,
      value.calculateDailyExpenseSummary()[thursday] ?? 0,
      value.calculateDailyExpenseSummary()[friday] ?? 0,
      value.calculateDailyExpenseSummary()[saturday] ?? 0,
    ];
    values.sort();
    max = values.last * 1.1;
    return max == 0 ? 1000 : max;
  }

  String calculateWeekTotal(
      ExpenseData value,
      String sunday,
      String monday,
      String tuesday,
      String wednesday,
      String thursday,
      String friday,
      String saturday) {
    List<double> values = [
      value.calculateDailyExpenseSummary()[sunday] ?? 0,
      value.calculateDailyExpenseSummary()[monday] ?? 0,
      value.calculateDailyExpenseSummary()[tuesday] ?? 0,
      value.calculateDailyExpenseSummary()[wednesday] ?? 0,
      value.calculateDailyExpenseSummary()[thursday] ?? 0,
      value.calculateDailyExpenseSummary()[friday] ?? 0,
      value.calculateDailyExpenseSummary()[saturday] ?? 0,
    ];

    double total = 0;
    for (int i = 0; i < values.length; i++) {
      total += values[i];
    }
    return NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2).format(total);
  }

  String calculateMonthTotal(ExpenseData value) {
    DateTime now = DateTime.now();
    String currentMonth = now.month.toString().padLeft(2, '0');
    String currentYear = now.year.toString();

    double total = value.getAllExpenseList().fold(0, (sum, expense) {
      String expenseMonth = expense.dateTime.month.toString().padLeft(2, '0');
      String expenseYear = expense.dateTime.year.toString();
      if (expenseMonth == currentMonth && expenseYear == currentYear) {
        return sum + (double.tryParse(expense.amount) ?? 0);
      }
      return sum;
    });

    return NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2).format(total);
  }

  @override
  Widget build(BuildContext context) {
    String sunday =
        convertDateTimeToString(startOfTheWeek.add(const Duration(days: 0)));
    String monday =
        convertDateTimeToString(startOfTheWeek.add(const Duration(days: 1)));
    String tuesday =
        convertDateTimeToString(startOfTheWeek.add(const Duration(days: 2)));
    String wednesday =
        convertDateTimeToString(startOfTheWeek.add(const Duration(days: 3)));
    String thursday =
        convertDateTimeToString(startOfTheWeek.add(const Duration(days: 4)));
    String friday =
        convertDateTimeToString(startOfTheWeek.add(const Duration(days: 5)));
    String saturday =
        convertDateTimeToString(startOfTheWeek.add(const Duration(days: 6)));
    return Consumer<ExpenseData>(
      builder: (context, value, child) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Month's Total: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(calculateMonthTotal(value))
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      "Week's Total: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(calculateWeekTotal(value, sunday, monday, tuesday,
                        wednesday, thursday, friday, saturday))
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: BarGraph(
              maxY: calaculateMax(value, sunday, monday, tuesday, wednesday,
                  thursday, friday, saturday),
              sunAmount: value.calculateDailyExpenseSummary()[sunday] ?? 0,
              monAmount: value.calculateDailyExpenseSummary()[monday] ?? 0,
              tueAmount: value.calculateDailyExpenseSummary()[tuesday] ?? 0,
              wedAmount: value.calculateDailyExpenseSummary()[wednesday] ?? 0,
              thurAmount: value.calculateDailyExpenseSummary()[thursday] ?? 0,
              friAmount: value.calculateDailyExpenseSummary()[friday] ?? 0,
              satAmount: value.calculateDailyExpenseSummary()[saturday] ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}
