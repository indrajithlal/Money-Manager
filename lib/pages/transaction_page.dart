import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/add_expense_page.dart';
import 'package:money_manager/pages/all_transactions_page.dart';
import 'package:money_manager/widgets/header_card.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<TransactionModel> data = [];
  List<Widget> transactions = [];
  Key headerKey = UniqueKey();

  void getRecentTransactions() async {
    final allTransactions = await DatabaseHelper.getAllTransactions();
    data = (allTransactions ?? []).reversed.toList();
    if (data.isEmpty) {
      if (mounted) {
        setState(() {
          transactions = [];
        });
      }
      return;
    }

    transactions = List.generate(
      data.length < 5 ? data.length : 5,
      (index) => ListTile(
        onTap: () async {
          await nextScreen(
            context,
            AddExpensePage(
              whatData: data[index].name,
              amountData: data[index].amount.toString(),
              descriptionData: data[index].description,
              dateData: data[index].date,
              accountName: data[index].account,
              categoryName: data[index].category,
              isExpense: data[index].isExpense,
            ),
          );
          getRecentTransactions();
          if (mounted) {
            setState(() {
              headerKey = UniqueKey();
            });
          }
        },
        title: Text(
          data[index].name,
          style: TextStyle(color: dark4, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          data[index].category,
          style: TextStyle(color: dark3, fontWeight: FontWeight.w400),
        ),
        trailing: Text(
          data[index].amount.toString(),
          style: TextStyle(
            color: data[index].isExpense ? red : dark_blue,
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void testDatabase() async {
    List<TransactionModel> temp = (await DatabaseHelper.getAllTransactions())!
        .reversed
        .toList();
    data = temp;
    getRecentTransactions();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getRecentTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white1,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 370, child: HeaderCard(key: headerKey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: dark4,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await nextScreen(context, const AllTransactionsPage());
                      getRecentTransactions();
                      if (mounted) {
                        setState(() {
                          headerKey = UniqueKey();
                        });
                      }
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: dark3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: white3, blurRadius: 6, spreadRadius: 2),
                  ],
                ),
                child: Material(
                  color: white1,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: Column(children: transactions),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        foregroundColor: white3,
        backgroundColor: dark2,
        child: const Icon(Icons.add),
        onPressed: () async {
          await nextScreen(
            context,
            AddExpensePage(
              accountName: '',
              amountData: '',
              categoryName: '',
              dateData: DateTime.now(),
              descriptionData: '',
              isExpense: true,
              whatData: '',
            ),
          );
          getRecentTransactions();
          if (mounted) {
            setState(() {
              headerKey = UniqueKey();
            });
          }
        },
      ),
    );
  }
}
