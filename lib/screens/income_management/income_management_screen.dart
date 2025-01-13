import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:todo_app/firebase/crud_task.dart';
import 'package:todo_app/model/income_model.dart';
import 'package:todo_app/screens/income_management/add_income_dialogue.dart';

class IncomeManagementScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  IncomeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Income Management',
          style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Customize app bar color
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Info') {
                _showInfoDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Info'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
            icon: const Icon(Icons.info, color: Colors.blueGrey),
          ),
        ],
      ),
      body: StreamBuilder<List<IncomeEntry>>(
        stream: _firestoreService.getIncomeEntriesForUser(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading income data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No income/expense data available',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          final entries = snapshot.data!;
          final Map<String, List<IncomeEntry>> categorizedEntries =
              _groupEntriesByMonth(entries);

          return ListView(
            padding: const EdgeInsets.all(12.0),
            children: categorizedEntries.entries.map((entry) {
              final month = entry.key;
              final monthlyEntries = entry.value;

              double totalIncome = 0;
              double totalExpenses = 0;

              for (var incomeEntry in monthlyEntries) {
                if (incomeEntry.type == 'Income') {
                  totalIncome += incomeEntry.amount;
                } else {
                  totalExpenses += incomeEntry.amount;
                }
              }

              double savings = totalIncome - totalExpenses;

              return _buildMonthlySummary(context, month, totalIncome,
                  totalExpenses, savings, monthlyEntries);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddIncomeEntryDialog(),
          );
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // Helper method to group entries by month
  Map<String, List<IncomeEntry>> _groupEntriesByMonth(
      List<IncomeEntry> entries) {
    Map<String, List<IncomeEntry>> groupedEntries = {};

    for (var entry in entries) {
      final month = DateFormat('MMMM yyyy')
          .format(entry.date); // Get the month name and year
      if (!groupedEntries.containsKey(month)) {
        groupedEntries[month] = [];
      }
      groupedEntries[month]!.add(entry);
    }

    return groupedEntries;
  }

  // Method to build monthly summary with expandable details
  Widget _buildMonthlySummary(
      BuildContext context,
      String month,
      double totalIncome,
      double totalExpenses,
      double savings,
      List<IncomeEntry> entries) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Colors.white,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            month,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueGrey,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryText('Income', totalIncome, Colors.teal),
                _buildSummaryText('Expenses', totalExpenses, Colors.red),
                _buildSummaryText('Savings', savings, Colors.blueGrey),
              ],
            ),
          ),
          children: entries.map((entry) {
            return _buildIncomeExpenseDetails(entry);
          }).toList(),
        ),
      ),
    );
  }

  // Method to build details for each income/expense entry
  Widget _buildIncomeExpenseDetails(IncomeEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        child: ListTile(
          leading: Icon(
            entry.type == 'Income' ? Icons.attach_money : Icons.money_off,
            color: entry.type == 'Income' ? Colors.green : Colors.red,
            size: 28,
          ),
          title: Text(
            entry.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Amount: PKR ${entry.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          trailing: Text(
            entry.type,
            style: TextStyle(
              color: entry.type == 'Income'
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build summary text
  Widget _buildSummaryText(String label, double amount, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          'PKR ${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  // Show info dialog with instructions on how to use the feature
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("How to Use Income Management"),
          content: const Text(
            "This feature allows you to track your monthly income and expenses.\n\n"
            "1. Add entries by clicking the + button.\n"
            "2. The entries will be automatically categorized into 'Income' or 'Expenses'.\n"
            "3. The monthly summary will show your total income, expenses, and savings for each month.\n"
            "4. You can expand each month to view detailed entries.\n"
            "5. Monitor your savings and financial health over time!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close",
                  style: TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
