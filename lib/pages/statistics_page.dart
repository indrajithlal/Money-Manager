import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/add_expense_page.dart';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/widgets/month_selector.dart';
import 'package:money_manager/widgets/stats/account_breakdown_card.dart';
import 'package:money_manager/widgets/stats/daily_bar_chart.dart';
import 'package:money_manager/widgets/stats/monthly_summary_card.dart';
import 'package:money_manager/widgets/stats/monthly_trend_chart.dart';
import 'package:money_manager/widgets/stats/top_expenses_card.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  DateTime date = DateTime.now();
  bool isExpenseMode = true;
  String currency = '₹';

  // Monthly summary stats
  double monthlyIncome = 0.0;
  double monthlyExpense = 0.0;
  double monthlySavings = 0.0;
  double savingsRate = 0.0;
  double avgDailySpend = 0.0;

  // Category breakdown
  List<Map<String, dynamic>> categoryData = [];
  Map<String, List<TransactionModel>> categoryTransactions = {};
  final Set<String> expandedCategories = {};
  double categoryTotalAmount = 0.0;
  final Map<String, double> dataMap = {"temp": 100};

  // Day-wise & Account data
  List<Map<String, dynamic>> dailyData = [];
  List<Map<String, dynamic>> accountData = [];
  List<Map<String, dynamic>> trendData = [];
  List<TransactionModel> topTransactions = [];

  final List<Color> colorList = <Color>[
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

  @override
  void initState() {
    super.initState();
    _loadAllStats(date);
  }

  Future<void> _loadAllStats(DateTime targetDate) async {
    date = targetDate;
    currency = await getCurrency();

    // 1. Monthly summary card data
    final summary = await DatabaseHelper.getMonthlySummary(date);
    monthlyIncome = summary['income'] ?? 0.0;
    monthlyExpense = summary['expense'] ?? 0.0;
    monthlySavings = summary['savings'] ?? 0.0;
    savingsRate = summary['savingsRate'] ?? 0.0;
    avgDailySpend = summary['avgDailySpend'] ?? 0.0;

    // 2. Category data based on isExpenseMode
    categoryData = await DatabaseHelper.getStatistics(
      date,
      isExpense: isExpenseMode,
    );
    final List<TransactionModel> monthlyItems =
        await DatabaseHelper.getExpensesByMonth(
      date,
      isExpense: isExpenseMode,
    );

    categoryTransactions.clear();
    for (TransactionModel item in monthlyItems) {
      categoryTransactions.putIfAbsent(item.category, () => []).add(item);
    }

    dataMap.clear();
    double tempTotal = 0.0;
    if (categoryData.isEmpty) {
      dataMap.addAll({"": 0});
      categoryTotalAmount = 0.0;
      expandedCategories.clear();
    } else {
      for (Map item in categoryData) {
        final double amt =
            double.tryParse("${item['total_amount']}") ?? 0.0;
        dataMap.addAll({item['category']: amt});
        tempTotal += amt;
      }
      categoryTotalAmount = tempTotal;
    }

    // 3. Daily spending trend
    dailyData = await DatabaseHelper.getDailySpending(
      date,
      isExpense: isExpenseMode,
    );

    // 4. Account breakdown
    accountData = await DatabaseHelper.getAccountBreakdown(
      date,
      isExpense: isExpenseMode,
    );

    // 5. 6-Month cashflow trend
    trendData = await DatabaseHelper.getMonthlyTrend(date);

    // 6. Top transactions
    topTransactions = await DatabaseHelper.getTopTransactions(
      date,
      isExpense: isExpenseMode,
      limit: 5,
    );

    if (mounted) {
      setState(() {});
    }
  }

  void onChangeDate(DateTime changedDate) {
    _loadAllStats(changedDate);
  }

  void onToggleMode(bool isExpense) {
    if (isExpenseMode == isExpense) return;
    setState(() {
      isExpenseMode = isExpense;
    });
    _loadAllStats(date);
  }

  double getPercentage(int index) {
    if (categoryTotalAmount == 0 || index >= categoryData.length) return 0.0;
    double val =
        double.tryParse("${categoryData[index]['total_amount']}") ?? 0.0;
    double percentage = (val / categoryTotalAmount) * 100;
    return double.parse(percentage.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final String formattedCategoryTotal =
        categoryTotalAmount.truncateToDouble() == categoryTotalAmount
            ? "${categoryTotalAmount.toInt()}"
            : categoryTotalAmount.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: white1,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector Header
              Padding(
                padding: const EdgeInsets.all(10),
                child: MonthSelecterHeader(
                  date: date,
                  onChange: onChangeDate,
                ),
              ),

              // 1. Monthly Summary KPI Card
              MonthlySummaryCard(
                income: monthlyIncome,
                expense: monthlyExpense,
                savings: monthlySavings,
                savingsRate: savingsRate,
                avgDailySpend: avgDailySpend,
                currency: currency,
              ),

              const SizedBox(height: 6),

              // Mode toggle: Expense vs Income
              _buildTypeSelector(),

              const SizedBox(height: 12),

              // 2. Category Pie / Ring Chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PieChart(
                  dataMap: dataMap,
                  animationDuration: const Duration(milliseconds: 700),
                  chartLegendSpacing: 32,
                  chartRadius: MediaQuery.of(context).size.width / 2.3,
                  colorList: colorList,
                  initialAngleInDegree: 0,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 28,
                  centerText: "$currency $formattedCategoryTotal",
                  centerTextStyle: TextStyle(
                    color: dark4,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  legendOptions: const LegendOptions(showLegends: false),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: false,
                    decimalPlaces: 1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Category List Heading
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, color: dark1, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isExpenseMode ? "Expense Categories" : "Income Categories",
                      style: TextStyle(
                        color: dark4,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (categoryData.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Center(
                    child: Text(
                      isExpenseMode
                          ? "No expenses recorded for this month"
                          : "No income recorded for this month",
                      style: TextStyle(
                        color: dark3,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (int index = 0; index < categoryData.length; index++)
                      _buildCategoryTile(index),
                  ],
                ),

              const SizedBox(height: 8),

              // 3. Day-wise spending bar chart
              DailyBarChart(
                dailyData: dailyData,
                daysInMonth: daysInMonth,
                isExpense: isExpenseMode,
                currency: currency,
              ),

              const SizedBox(height: 8),

              // 4. Account Breakdown
              AccountBreakdownCard(
                accountData: accountData,
                isExpense: isExpenseMode,
                currency: currency,
              ),

              const SizedBox(height: 8),

              // 5. 6-Month Cash Flow Trend Line Chart
              MonthlyTrendChart(
                trendData: trendData,
                currency: currency,
              ),

              const SizedBox(height: 8),

              // 6. Top 5 Transactions
              TopExpensesCard(
                topTransactions: topTransactions,
                isExpense: isExpenseMode,
                onRefresh: () => _loadAllStats(date),
                currency: currency,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: white2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onToggleMode(true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isExpenseMode ? red : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isExpenseMode
                        ? [
                            BoxShadow(
                              color: red.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 15,
                          color: isExpenseMode ? Colors.white : dark3,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Expenses",
                          style: TextStyle(
                            color: isExpenseMode ? Colors.white : dark3,
                            fontWeight: isExpenseMode
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                onTap: () => onToggleMode(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: !isExpenseMode ? green : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: !isExpenseMode
                        ? [
                            BoxShadow(
                              color: green.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 15,
                          color: !isExpenseMode ? Colors.white : dark3,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Income",
                          style: TextStyle(
                            color: !isExpenseMode ? Colors.white : dark3,
                            fontWeight: !isExpenseMode
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(int index) {
    final String categoryName = categoryData[index]['category'];
    final double catTotal =
        double.tryParse("${categoryData[index]['total_amount']}") ?? 0.0;
    final String formattedCategoryTotal =
        catTotal.truncateToDouble() == catTotal
            ? "${catTotal.toInt()}"
            : catTotal.toStringAsFixed(2);
    final double percentage = getPercentage(index);
    final Color categoryColor = index < colorList.length
        ? colorList[index]
        : colorList[index - colorList.length];
    final bool isExpanded = expandedCategories.contains(categoryName);
    final List<TransactionModel> items =
        categoryTransactions[categoryName] ?? [];
    final Color amountColor = isExpenseMode ? red : green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 36,
                      width: 64,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "$percentage%",
                          style: TextStyle(
                            color: dark4,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          color: dark4,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "$currency $formattedCategoryTotal",
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: dark3,
                        size: 20,
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
                    vertical: 12,
                  ),
                  child: Text(
                    "No individual records found",
                    style: TextStyle(
                      color: dark3,
                      fontSize: 13,
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
                    final item = items[i];
                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddExpensePage(
                              whatData: item.name,
                              dateData: item.date,
                              amountData: '${item.amount}',
                              descriptionData: item.description,
                              accountName: item.account,
                              categoryName: item.category,
                              isExpense: item.isExpense,
                            ),
                          ),
                        );
                        _loadAllStats(date);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: white1,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 16,
                                color: dark3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: dark4,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy')
                                            .format(item.date),
                                        style: TextStyle(
                                          color: dark3,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (item.account.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: white3,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            item.account,
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
                                  if (item.description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description,
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
                              "$currency ${item.amount}",
                              style: TextStyle(
                                color: amountColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
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
