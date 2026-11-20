import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/pages/split_expense/groupexpense_settings_page.dart';
import 'package:money_manager/pages/split_expense/groupexpenses_display_page.dart';
import 'package:money_manager/pages/split_expense/settlement_page.dart';
import 'package:flutter/material.dart';

class SplitExpensePage extends StatefulWidget {
  final String id;
  final String participants;
  const SplitExpensePage({
    required this.id,
    required this.participants,
    super.key,
  });

  @override
  State<SplitExpensePage> createState() => _SplitExpensePageState();
}

class _SplitExpensePageState extends State<SplitExpensePage> {
  String currency = '₹';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  void _loadCurrency() async {
    final curr = await getCurrency();
    if (mounted) {
      setState(() {
        currency = curr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: white2,
        appBar: AppBar(
          title: Text(
            "split expenses",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w500,
              color: white3,
            ),
          ),
          elevation: 0,
          backgroundColor: dark4,
          foregroundColor: white3,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: white3),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          bottom: TabBar(
            labelColor: dark_blue,
            unselectedLabelColor: dark1,
            indicatorColor: dark_blue,
            tabs: [
              Tab(icon: getCurrencyIcon(currency)),
              const Tab(icon: Icon(Icons.balance_rounded)),
              const Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SplitExpenseExpenses(
              id: widget.id,
              participants: widget.participants,
              currency: currency,
            ),
            SplitExpensePageSettlePage(
              gid: widget.id,
              currency: currency,
            ),
            SplitExpenseSettingsPage(id: widget.id),
          ],
        ),
      ),
    );
  }
}
