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

  Set<String> selectedCategories = {};

  void onChangeDate(DateTime changedDate) {
    date = changedDate;
    sortedExpenses = filterExpenses(expenses, changedDate, selectedCategories);
    dates = getDates(sortedExpenses);
    setState(() {});
  }

  List<TransactionModel> filterExpenses(
    List<TransactionModel> unFilteredExpenses,
    DateTime changeDate,
    Set<String> categories,
  ) {
    List<TransactionModel> filteredExpenses = [];
    final normalizedCategories =
        categories.map((c) => c.trim().toLowerCase()).toSet();

    for (TransactionModel expense in unFilteredExpenses) {
      bool matchesDate = expense.date.month == changeDate.month &&
          expense.date.year == changeDate.year;

      bool matchesCategory = normalizedCategories.isEmpty;
      if (!matchesCategory) {
        final expCat = expense.category.trim().toLowerCase();
        final isIncomeSelected = normalizedCategories.contains('income');
        matchesCategory = normalizedCategories.contains(expCat) ||
            (isIncomeSelected && (!expense.isExpense || expCat == 'income'));
      }

      if (matchesDate && matchesCategory) {
        filteredExpenses.add(expense);
      }
    }
    return filteredExpenses;
  }

  DateTime? getFirstMatchingOtherMonth() {
    if (selectedCategories.isEmpty) return null;
    final normalizedCategories =
        selectedCategories.map((c) => c.trim().toLowerCase()).toSet();
    for (var exp in expenses) {
      bool sameMonth =
          exp.date.month == date.month && exp.date.year == date.year;
      if (sameMonth) continue;
      final expCat = exp.category.trim().toLowerCase();
      final isIncomeSelected = normalizedCategories.contains('income');
      if (normalizedCategories.contains(expCat) ||
          (isIncomeSelected && (!exp.isExpense || expCat == 'income'))) {
        return exp.date;
      }
    }
    return null;
  }

  int getOtherMonthsMatchCount() {
    if (selectedCategories.isEmpty) return 0;
    final normalizedCategories =
        selectedCategories.map((c) => c.trim().toLowerCase()).toSet();
    int count = 0;
    for (var exp in expenses) {
      bool sameMonth =
          exp.date.month == date.month && exp.date.year == date.year;
      if (sameMonth) continue;
      final expCat = exp.category.trim().toLowerCase();
      final isIncomeSelected = normalizedCategories.contains('income');
      if (normalizedCategories.contains(expCat) ||
          (isIncomeSelected && (!exp.isExpense || expCat == 'income'))) {
        count++;
      }
    }
    return count;
  }

  void getExpenses() async {
    expenses = (await DatabaseHelper.getAllTransactions()) ?? [];
    if (mounted) {
      setState(() {
        sortedExpenses = filterExpenses(expenses, date, selectedCategories);
        dates = getDates(sortedExpenses);
      });
    }
  }

  void onDelete(TransactionModel expense) async {
    await DatabaseHelper.deleteTransaction(expense);
    if (mounted) {
      setState(() {
        expenses.remove(expense);
        sortedExpenses = filterExpenses(expenses, date, selectedCategories);
        dates = getDates(sortedExpenses);
      });
    }
  }

  void addExpense() {
    getExpenses();
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
            Navigator.pop(context);
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

          if (selectedCategories.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              color: white2,
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 18, color: dark3),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (String cat in selectedCategories)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: white1,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: white3),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      cat,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: dark4,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCategories.remove(cat);
                                          sortedExpenses = filterExpenses(
                                            expenses,
                                            date,
                                            selectedCategories,
                                          );
                                          dates = getDates(sortedExpenses);
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: dark3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategories.clear();
                        sortedExpenses = filterExpenses(
                          expenses,
                          date,
                          selectedCategories,
                        );
                        dates = getDates(sortedExpenses);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: sortedExpenses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: dark3,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            selectedCategories.isNotEmpty
                                ? "No matching transactions in ${DateFormat.MMMM().format(date)} ${date.year}"
                                : "No transactions found",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: dark3,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (getOtherMonthsMatchCount() > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Found ${getOtherMonthsMatchCount()} transaction(s) in other months",
                              style: TextStyle(
                                color: dark2,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: dark_blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                final target = getFirstMatchingOtherMonth();
                                if (target != null) {
                                  onChangeDate(target);
                                }
                              },
                              icon: Icon(
                                Icons.calendar_month,
                                size: 16,
                                color: white1,
                              ),
                              label: Text(
                                "View ${DateFormat.MMMM().format(getFirstMatchingOtherMonth()!)} ${getFirstMatchingOtherMonth()!.year}",
                                style: TextStyle(
                                  color: white1,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : GroupedListView<TransactionModel, DateTime>(
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
                      key: ObjectKey(expense),
                      color: white1,
                      child: SlidableDismissExpense(
                        expense: expense,
                        onDelete: onDelete,
                        childWidget: ListTile(
                          onTap: () async {
                            await nextScreen(
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
                            getExpenses();
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
        onPressed: () async {
          final result = await showModalBottomSheet<Set<String>>(
            backgroundColor: white1,
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            ),
            builder: (BuildContext context) {
              return FilterPage(
                selectedCategories: selectedCategories,
                availableExpenses: expenses,
              );
            },
          );
          if (result != null && mounted) {
            setState(() {
              selectedCategories = result;
              sortedExpenses =
                  filterExpenses(expenses, date, selectedCategories);
              dates = getDates(sortedExpenses);
            });
          }
        },
        label: Text(
          selectedCategories.isEmpty
              ? 'Filters'
              : 'Filters (${selectedCategories.length})',
          style: TextStyle(fontWeight: FontWeight.w500, color: white1),
        ),
        icon: Icon(
          selectedCategories.isEmpty
              ? Icons.filter_alt_outlined
              : Icons.filter_alt,
          color: white1,
        ),
        backgroundColor: selectedCategories.isEmpty ? dark1 : dark_blue,
      ),
    );
  }
}
