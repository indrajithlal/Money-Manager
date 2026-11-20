import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableDismissExpense extends StatelessWidget {
  final Widget childWidget;
  final Function onDelete;
  final String? index;
  final TransactionModel expense;

  const SlidableDismissExpense({
    required this.childWidget,
    required this.onDelete,
    this.index,
    required this.expense,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ObjectKey(expense),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 1 / 4,
        children: [
          SlidableAction(
            onPressed: (context) {
              onDelete(expense);
            },
            borderRadius: BorderRadius.circular(5),
            backgroundColor: red,
            foregroundColor: dark3,
            icon: Icons.delete,
            label: 'delete',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 1 / 4,
        children: [
          SlidableAction(
            onPressed: (context) {
              onDelete(expense);
            },
            borderRadius: BorderRadius.circular(5),
            backgroundColor: red,
            foregroundColor: dark3,
            icon: Icons.delete,
            label: 'delete',
          ),
        ],
      ),
      child: childWidget,
    );
  }
}
