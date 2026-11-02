import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/add_expense_page.dart';
import 'package:money_manager/widgets/filter_page.dart';
import 'package:money_manager/widgets/month_selector.dart';
import 'package:money_manager/widgets/slidable.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  List<TransactionModel> expenses = [];
  List<TransactionModel> sortedExpenses = [];
  int currentMonth = DateTime.now().month;
  DateTime date = DateTime.now();
  List<DateTime> dates = [];
  Widget groupedTransactions = Container();

  void onChangeDate(DateTime changedDate) {
    date = changedDate;
    sortedExpenses = filterByDate(expenses, changedDate);
    dates = getDates(sortedExpenses);
    setState(() {});
  }

  List<TransactionModel> filterByDate(
    List<TransactionModel> unFilteredExpenses,
    DateTime changeDate,
  ) {
    List<TransactionModel> filteredExpenses = [];
    for (TransactionModel expense in unFilteredExpenses) {
      if (expense.date.month == changeDate.month &&
          expense.date.year == changeDate.year) {
        filteredExpenses.add(expense);
      }
    }
    return filteredExpenses;
  }

  void getExpenses() async {
    expenses = (await DatabaseHelper.getAllTransactions())!;
    sortedExpenses = filterByDate(expenses, date);
    setState(() {});
  }

  void onDelete(TransactionModel expense) {
    DatabaseHelper.deleteTransaction(expense);
    expenses.remove(expense);
    nextScreen(context, const AllTransactionsPage());
  }

  void addExpense() {
    Navigator.pop(context);
    nextScreen(context, const AllTransactionsPage());
  }

  String _getDailySum(DateTime day) {
    final dailyTransactions = sortedExpenses.where((expense) {
      // Compare only year, month, and day
      return expense.date.year == day.year &&
          expense.date.month == day.month &&
          expense.date.day == day.day;
    }).toList();

    // 2. Calculate the total amount for the day
    double totalAmount = 0.0;
    for (var transaction in dailyTransactions) {
      // Assuming 'isExpense' is a boolean in TransactionModel:
      // Subtract for expenses, add for income/transactions
      if (transaction.isExpense) {
        totalAmount -= transaction.amount;
      } else {
        totalAmount += transaction.amount;
      }
    }

    return totalAmount.toString();
  }

  @override
  void initState() {
    super.initState();
    getExpenses();
    onChangeDate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      appBar: AppBar(
        elevation: 0.3,
        iconTheme: IconThemeData(color: dark4),
        backgroundColor: white1,
        toolbarTextStyle: TextStyle(color: dark4),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            refreshHomePage(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "All Transactions",
          style: TextStyle(color: dark4, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          //TopBar(changeMonth: changeMonth,),
          MonthSelecterHeader(date: date, onChange: onChangeDate),

          Expanded(
            child: GroupedListView<TransactionModel, DateTime>(
              elements: sortedExpenses,
              //useStickyGroupSeparators: true,
              //floatingHeader: true,
              order: GroupedListOrder.DESC,
              groupBy: (expense) => DateTime(
                expense.date.year,
                expense.date.month,
                expense.date.day,
              ),
              groupHeaderBuilder: (TransactionModel firstTransactionInGroup) {
                // The 'firstTransactionInGroup' gives us the date for the group
                DateTime groupDate = DateTime(
                  firstTransactionInGroup.date.year,
                  firstTransactionInGroup.date.month,
                  firstTransactionInGroup.date.day,
                );

                // Calculate the daily sum using the new function
                String dailySum = _getDailySum(groupDate);

                return SizedBox(
                  height: 40,
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    color: white3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        // Use a Row to place text on the left and sum on the right
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: Date
                          Text(
                            DateFormat.yMMMd().format(
                              firstTransactionInGroup.date,
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: dark3,
                            ),
                          ),
                          // Right side: Sum of the day's transactions
                          Text(
                            dailySum,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: dark3,
                              //color: int.tryParse(dailySum)! > 0 ? green : red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemBuilder: (context, expense) => Material(
                color: white1,
                child: SlidableDismissExpense(
                  expense: expense,
                  onDelete: onDelete,
                  index: "${expenses.indexOf(expense)}",
                  childWidget: ListTile(
                    onTap: () {
                      nextScreen(
                        context,
                        AddExpensePage(
                          whatData: expense.name,
                          dateData: expense.date,
                          amountData: '${expense.amount}',
                          descriptionData: expense.description,
                          accountName: expense.account,
                          categoryName: expense.category,
                          isExpense: expense.isExpense,
                        ),
                      );
                    },
                    title: Text(
                      expense.name,
                      style: TextStyle(
                        color: dark4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      expense.category,
                      style: TextStyle(
                        color: dark3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Text(
                      formatAmount(expense.amount),
                      style: TextStyle(
                        color: expense.isExpense ? red : dark_blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: white1,
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            ),
            builder: (BuildContext) {
              return const FilterPage();
            },
          );
        },
        label: Text(
          'Filters',
          style: TextStyle(fontWeight: FontWeight.w500, color: white1),
        ),
        icon: Icon(Icons.filter_alt_outlined, color: white1),
        backgroundColor: dark1,
      ),
    );
  }
}
