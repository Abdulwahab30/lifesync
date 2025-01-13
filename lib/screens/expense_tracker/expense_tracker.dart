import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/data/expense_data.dart';
import 'package:todo_app/model/expense_item.dart';
import 'package:todo_app/screens/expense_tracker/expense_summary.dart';
import 'package:todo_app/screens/expense_tracker/expense_tile.dart';
import 'package:todo_app/screens/expense_tracker/monthly_expense_screen.dart';

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  final newExpenseNameController = TextEditingController();
  final newExpenseAmountController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  void addNewExpense() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "Add new Expense",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(hintText: "Expense Name"),
                    controller: newExpenseNameController,
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(hintText: "Expense Amount"),
                    keyboardType: TextInputType.number,
                    controller: newExpenseAmountController,
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                  onPressed: cancel,
                  child: const Text("Cancel"),
                ),
                MaterialButton(
                  onPressed: save,
                  child: const Text(
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ));
  }

  void deleteExense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExense(expense);
  }

  void save() {
    if (newExpenseAmountController.text.isNotEmpty &&
        newExpenseNameController.text.isNotEmpty) {
      ExpenseItem newExpense = ExpenseItem(
          name: newExpenseNameController.text,
          amount: newExpenseAmountController.text,
          dateTime: DateTime.now());
      Provider.of<ExpenseData>(context, listen: false)
          .addNewExpense(newExpense);
    }
    clear();
    Navigator.pop(context);
  }

  void cancel() {
    clear();
    Navigator.pop(context);
  }

  void clear() {
    newExpenseNameController.clear();
    newExpenseAmountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
        builder: (context, value, child) => Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton(
              onPressed: addNewExpense,
              backgroundColor: Colors.blueGrey,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            appBar: AppBar(
              title: const Text(
                "Finance Management",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Colors.white,
              actions: [
                PopupMenuButton<String>(
                  color: Colors.grey[200],
                  onSelected: (value) {
                    if (value == 'Monthly Expenses') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MonthlyExpenseScreen(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Monthly Expenses',
                        child: Text(
                          'Monthly Expenses',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: ListView(
              children: [
                ExpenseSummary(startOfTheWeek: value.startOfWeekDate()),
                const SizedBox(
                  height: 30,
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: value.getAllExpenseList().length,
                    itemBuilder: (context, index) => ExpenseTile(
                          name: value.getAllExpenseList()[index].name,
                          amount: value.getAllExpenseList()[index].amount,
                          dateTime: value.getAllExpenseList()[index].dateTime,
                          deleteTapped: (BuildContext) {
                            deleteExense(value.getAllExpenseList()[index]);
                          },
                        ))
              ],
            )));
  }
}
