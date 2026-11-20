import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/constants/theme_data.dart';

class DailyBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> dailyData;
  final int daysInMonth;
  final bool isExpense;
  final String currency;

  const DailyBarChart({
    super.key,
    required this.dailyData,
    required this.daysInMonth,
    required this.isExpense,
    this.currency = '₹',
  });

  @override
  State<DailyBarChart> createState() => _DailyBarChartState();
}

class _DailyBarChartState extends State<DailyBarChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.dailyData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: white2,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              "No daily records for this month",
              style: TextStyle(
                color: dark3,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    // Map day to amount
    final Map<int, double> dayAmountMap = {};
    double maxAmount = 0.0;
    int peakDay = 1;

    for (var item in widget.dailyData) {
      int day = (item['day'] as num).toInt();
      double amount = ((item['total_amount'] ?? 0) as num).toDouble();
      dayAmountMap[day] = amount;
      if (amount > maxAmount) {
        maxAmount = amount;
        peakDay = day;
      }
    }

    final double maxY = maxAmount == 0 ? 100 : (maxAmount * 1.25);
    final Color barColor = widget.isExpense ? red : green;
    final String typeLabel = widget.isExpense ? "Daily Spending" : "Daily Income";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: white2,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: dark1, size: 20),
                const SizedBox(width: 8),
                Text(
                  typeLabel,
                  style: TextStyle(
                    color: dark4,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (maxAmount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Peak: Day $peakDay (${widget.currency} ${maxAmount.toInt()})",
                      style: TextStyle(
                        color: dark4,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double chartWidth =
                      (widget.daysInMonth * 16.0).clamp(constraints.maxWidth, 700.0);

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          maxY: maxY,
                          alignment: BarChartAlignment.spaceAround,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => dark4,
                              tooltipPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final day = group.x;
                                final val = rod.toY.toInt();
                                return BarTooltipItem(
                                  "Day $day\n${widget.currency} $val",
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  int day = value.toInt();
                                  // Show every 3rd or 5th day label, or 1st/peak/last
                                  if (day == 1 ||
                                      day == 5 ||
                                      day == 10 ||
                                      day == 15 ||
                                      day == 20 ||
                                      day == 25 ||
                                      day == widget.daysInMonth) {
                                    return Text(
                                      "$day",
                                      style: TextStyle(
                                        color: dark3,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: white3.withValues(alpha: 0.6),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(
                            widget.daysInMonth,
                            (index) {
                              final int day = index + 1;
                              final double amount = dayAmountMap[day] ?? 0.0;
                              final bool isPeak = day == peakDay && amount > 0;

                              return BarChartGroupData(
                                x: day,
                                barRods: [
                                  BarChartRodData(
                                    toY: amount,
                                    color: isPeak
                                        ? barColor
                                        : barColor.withValues(alpha: 0.55),
                                    width: 8,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
