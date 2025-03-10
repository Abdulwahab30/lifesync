import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// ignore: must_be_immutable
class ExpenseTile extends StatelessWidget {
  final String name;
  final String amount;
  final DateTime dateTime;
  void Function(BuildContext)? deleteTapped;
  ExpenseTile(
      {super.key,
      required this.name,
      required this.amount,
      required this.dateTime,
      required this.deleteTapped});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: StretchMotion(), children: [
        SlidableAction(
          onPressed: deleteTapped,
          icon: Icons.delete,
          backgroundColor: Colors.red,
          borderRadius: BorderRadius.circular(6),
        )
      ]),
      child: ListTile(
        tileColor: Colors.grey[200],
        title: Text(name),
        subtitle: Text('${dateTime.day}/${dateTime.month}/${dateTime.year}'),
        trailing: Text(
          "Rs ${amount}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
