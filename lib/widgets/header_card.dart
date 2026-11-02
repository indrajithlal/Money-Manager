import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/pages/notification_page.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderCard extends StatefulWidget {
  const HeaderCard({super.key});

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  String username = 'Aleena m.a';

  void getUsername() async {
    username = await getUserName();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: dark1,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back,',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: white3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            username,
                            //user?.email?.split("@")[0]??'UserName',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: white1,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          nextScreen(context, const NotificationPage());
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            child: Container(
                              height: 40,
                              width: 40,
                              color: dark2,
                              child: Icon(
                                Icons.notification_add_outlined,
                                size: 30,
                                color: yellow,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const Positioned(top: 120, child: InfoCard()),
      ],
    );
  }
}

class InfoCard extends StatefulWidget {
  const InfoCard({super.key});

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  String totalExpenseAmount = '';
  String totalIncomeAmount = '';
  String totalBalanceAmount = '';
  String thisMonth = '';
  int offset = 0;
  List<String> accounts = [];

  void updateExpenseAmount() async {
    totalExpenseAmount = await getFormatedAmount(
      await DatabaseHelper.getTotalExpenseAmount(
        DateTime.now().year,
        DateTime.now().month + offset,
      ),
    );
    totalIncomeAmount = await getFormatedAmount(
      await DatabaseHelper.getTotalIncomeAmount(
        DateTime.now().year,
        DateTime.now().month + offset,
      ),
    );
    totalBalanceAmount = await getFormatedAmount(
      await DatabaseHelper.getTotalIncomeAmount(
            DateTime.now().year,
            DateTime.now().month + offset,
          ) -
          await DatabaseHelper.getTotalExpenseAmount(
            DateTime.now().year,
            DateTime.now().month + offset,
          ),
    );
    print(totalExpenseAmount);
    setState(() {});
  }

  void updateMonth() {
    int monthNum = DateTime.now().month + offset;
    print(monthNum);
    thisMonth = DateFormat.MMMM().format(DateTime(0, monthNum));
    print(thisMonth);
    if (thisMonth.length > 4) {
      thisMonth = thisMonth.substring(0, 3);
    }
    updateExpenseAmount();
  }

  @override
  void initState() {
    super.initState();
    updateExpenseAmount();
    updateMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 215,
        width: MediaQuery.of(context).size.width - 40,
        decoration: BoxDecoration(
          color: dark4,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 25,
                      color: green,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: Icon(Icons.arrow_back_ios, color: white3),
                        onTap: () {
                          offset = offset - 1;
                          updateMonth();
                        },
                      ),
                      SizedBox(width: 10),
                      Text(
                        thisMonth,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25,
                          color: white3,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        child: Icon(Icons.arrow_forward_ios, color: white3),
                        onTap: () {
                          offset = offset + 1;
                          updateMonth();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  totalBalanceAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: white1,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: white3,
                        child: Icon(Icons.arrow_downward, color: dark_blue),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Income',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: dark_blue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: white3,
                        child: Icon(Icons.arrow_upward, color: red),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Expenses',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    totalIncomeAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: white1,
                    ),
                  ),
                  Text(
                    totalExpenseAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: white1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
