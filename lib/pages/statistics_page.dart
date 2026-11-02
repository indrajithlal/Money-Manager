import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/add_expense_page.dart';
import 'package:money_manager/widgets/month_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime date = DateTime.now();
  List<Map<String, dynamic>> data = [];
  Map<String, List<TransactionModel>> categoryExpenses = {};
  final Set<String> expandedCategories = {};
  double totalAmount = 0;

  final colorList = <Color>[
    dark_blue,
    red,
    green,
    light_blue,
    yellow,
    white3,
    orange,
    purple,
    frostGreen,
    greyBlue,
  ];
  final dataMap = <String, double>{"temp": 100};

  @override
  void initState() {
    super.initState();
    onChangeDate(date);
  }

  double getPercentage(int index) {
    if (totalAmount == 0 || index >= data.length) return 0.0;
    double val = double.tryParse("${data[index]['total_amount']}") ?? 0.0;
    double percentage = (val / totalAmount) * 100;
    return double.parse(percentage.toStringAsFixed(1));
  }

  void onChangeDate(DateTime changedDate) async {
    date = changedDate;
    double tempAmount = 0.0;
    data = await DatabaseHelper.getStatistics(changedDate);
    final List<TransactionModel> monthlyExpenses =
        await DatabaseHelper.getExpensesByMonth(changedDate);

    categoryExpenses.clear();
    for (TransactionModel expense in monthlyExpenses) {
      categoryExpenses.putIfAbsent(expense.category, () => []).add(expense);
    }

    dataMap.clear();
    if (data.isEmpty) {
      dataMap.addAll({"": 0});
      totalAmount = 0.0;
      expandedCategories.clear();
      setState(() {});
      return;
    }
    for (Map item in data) {
      dataMap.addAll({
        item['category']: double.parse("${item['total_amount']}"),
      });

      tempAmount += double.parse("${item['total_amount']}");
    }

    totalAmount = tempAmount;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTotal =
        totalAmount.truncateToDouble() == totalAmount
            ? "${totalAmount.toInt()}"
            : totalAmount.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: white1,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: MonthSelecterHeader(
                  date: date,
                  onChange: onChangeDate,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: PieChart(
                      dataMap: dataMap,
                      animationDuration: const Duration(milliseconds: 800),
                      chartLegendSpacing: 32,
                      chartRadius: MediaQuery.of(context).size.width / 2,
                      colorList: colorList,
                      initialAngleInDegree: 0,
                      chartType: ChartType.ring,
                      ringStrokeWidth: 32,
                      centerText: "₹ $formattedTotal",
                      legendOptions: const LegendOptions(
                        showLegends: false,
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValueBackground: true,
                        showChartValues: true,
                        showChartValuesInPercentage: true,
                        showChartValuesOutside: false,
                        decimalPlaces: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        color: dark3,
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (data.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Center(
                        child: Text(
                          "No expenses recorded for this month",
                          style: TextStyle(
                            color: dark3,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int index = 0; index < data.length; index++)
                          _buildCategoryTile(index),
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(int index) {
    final String categoryName = data[index]['category'];
    final double categoryTotal =
        double.tryParse("${data[index]['total_amount']}") ?? 0.0;
    final String formattedCategoryTotal =
        categoryTotal.truncateToDouble() == categoryTotal
            ? "${categoryTotal.toInt()}"
            : categoryTotal.toStringAsFixed(2);
    final double percentage = getPercentage(index);
    final Color categoryColor = index < colorList.length
        ? colorList[index]
        : colorList[index - colorList.length];
    final bool isExpanded = expandedCategories.contains(categoryName);
    final List<TransactionModel> items = categoryExpenses[categoryName] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: white2,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    expandedCategories.remove(categoryName);
                  } else {
                    expandedCategories.add(categoryName);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 70,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "$percentage %",
                          style: TextStyle(
                            color: dark4,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          color: dark3,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      "₹ $formattedCategoryTotal",
                      style: TextStyle(
                        color: red,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: dark3,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1, thickness: 1, color: Color(0xFFD8DEE9)),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Text(
                    "No individual expenses found",
                    style: TextStyle(
                      color: dark3,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: items.length,
                  separatorBuilder: (context, i) => const Divider(
                    height: 1,
                    indent: 48,
                    endIndent: 16,
                    color: Color(0xFFECEFF4),
                  ),
                  itemBuilder: (context, i) {
                    final expense = items[i];
                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddExpensePage(
                              whatData: expense.name,
                              dateData: expense.date,
                              amountData: '${expense.amount}',
                              descriptionData: expense.description,
                              accountName: expense.account,
                              categoryName: expense.category,
                              isExpense: expense.isExpense,
                            ),
                          ),
                        );
                        onChangeDate(date);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: white1,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 17,
                                color: dark3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.name,
                                    style: TextStyle(
                                      color: dark4,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy')
                                            .format(expense.date),
                                        style: TextStyle(
                                          color: dark3,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (expense.account.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: white3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            expense.account,
                                            style: TextStyle(
                                              color: dark4,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (expense.description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      expense.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: dark3,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              "₹ ${expense.amount}",
                              style: TextStyle(
                                color: red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

