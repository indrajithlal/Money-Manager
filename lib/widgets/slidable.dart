import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableDismissExpense extends StatefulWidget {
  final Widget childWidget;
  final Function onDelete;
  final String index;
  final TransactionModel expense;
  const SlidableDismissExpense({
    required this.childWidget,
    required this.onDelete,
    required this.index,
    required this.expense,
    super.key,
  });

  @override
  State<SlidableDismissExpense> createState() => _SlidableDismissExpenseState();
}

class _SlidableDismissExpenseState extends State<SlidableDismissExpense> {
  bool isDismissed = false;
  @override
  Widget build(BuildContext context) {
    return isDismissed
        ? const SizedBox()
        : Slidable(
            key: Key(widget.index),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              //dismissible: DismissiblePane(onDismissed: () {}),
              extentRatio: 1 / 4,
              children: [
                SlidableAction(
                  onPressed: ((context) {
                    widget.onDelete(widget.expense);
                    isDismissed = true;
                    setState(() {});
                  }),
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor: red,
                  foregroundColor: dark3,
                  icon: Icons.delete,
                  label: 'delete',
                ),
              ],
            ),
            child: widget.childWidget,
          );
  }
}
