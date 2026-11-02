import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/pages/setting_page.dart';
import 'package:money_manager/pages/split_page.dart';
import 'package:money_manager/pages/statistics_page.dart';
import 'package:money_manager/pages/transaction_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageNo = 0;
  List<Widget> pages = [
    const TransactionPage(),
    const StatisticsPage(),
    const GroupExpensePage(),
    const SettingsPage(),
  ];
  void changePage(index) {
    setState(() {
      pageNo = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white1,
      body: pages[pageNo],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: white2,
        selectedItemColor: dark_blue,
        currentIndex: pageNo,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: dark3),
            label: 'Trans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, color: dark3),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: dark3),
            label: 'Split',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, color: dark3),
            label: 'More',
          ),
        ],
        onTap: (index) {
          changePage(index);
        },
      ),
    );
  }
}
