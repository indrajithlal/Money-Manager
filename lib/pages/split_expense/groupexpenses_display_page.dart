import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/split_expense/add_groupexpense_page.dart';
import 'package:money_manager/widgets/slidable_dismiss.dart';
import 'package:flutter/material.dart';

class SplitExpenseExpenses extends StatefulWidget {
  final String id;
  final String participants;
  const SplitExpenseExpenses({
    required this.id,
    required this.participants,
    super.key,
  });

  @override
  State<SplitExpenseExpenses> createState() => _SplitExpenseExpensesState();
}

class _SplitExpenseExpensesState extends State<SplitExpenseExpenses> {
  Future<List<Expense>?> getExpenses() async {
    List<Expense>? expenses = await DatabaseHelper.getExpensesFromGid(
      widget.id,
    );

    return expenses;
  }

  void onDelete(Expense expense) {
    print("delete from database");
    DatabaseHelper.deleteExpense("${expense.tid}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      body: FutureBuilder(
        future: getExpenses(),
        builder: (context, snapshot) {
          List<Expense>? data = snapshot.data;
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                itemCount: data!.length,
                itemBuilder: (context, index) => SlidableDismiss(
                  onDelete: onDelete,
                  index: "$index",
                  expense: data[index],
                  childWidget: ListTile(
                    onTap: () async {
                      Expense expense = data[index];
                      Group? group =
                          await DatabaseHelper.getGroupByID(widget.id);
                      String latestParticipants =
                          (group != null && group.participants.isNotEmpty)
                              ? group.participants
                              : widget.participants;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplitExpenseAddExpensepage(
                            id: widget.id,
                            participants: latestParticipants,
                            expense: expense,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    title: Text(
                      data[index].tname,
                      style: TextStyle(
                        color: dark_blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Paid by ${data[index].payername}',
                      style: TextStyle(
                        color: dark3,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Text(
                      '₹ ${data[index].amount}',
                      style: TextStyle(
                        color: red,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return Container();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: dark3,
        foregroundColor: white3,
        child: const Icon(Icons.add),
        onPressed: () async {
          Expense expense = Expense(
            gid: int.parse(widget.id),
            tname: '',
            payername: '',
            amount: 0,
            date: DateTime.now(),
            borrowers: '',
            borrowedamt: '',
          );
          Group? group = await DatabaseHelper.getGroupByID(widget.id);
          String latestParticipants =
              (group != null && group.participants.isNotEmpty)
                  ? group.participants
                  : widget.participants;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SplitExpenseAddExpensepage(
                id: widget.id,
                participants: latestParticipants,
                expense: expense,
              ),
            ),
          );
          setState(() {});
        },
      ),
    );
  }
}
