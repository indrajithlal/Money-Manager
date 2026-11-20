import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/constants/theme_data.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> trendData;
  final String currency;

  const MonthlyTrendChart({
    super.key,
    required this.trendData,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxVal = 0.0;
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];

    for (int i = 0; i < trendData.length; i++) {
      final item = trendData[i];
      final double inc = ((item['income'] ?? 0) as num).toDouble();
      final double exp = ((item['expense'] ?? 0) as num).toDouble();

      incomeSpots.add(FlSpot(i.toDouble(), inc));
      expenseSpots.add(FlSpot(i.toDouble(), exp));

      maxVal = max(maxVal, max(inc, exp));
    }

    final double maxY = maxVal == 0 ? 100 : (maxVal * 1.25);

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
                Icon(Icons.show_chart_rounded, color: dark1, size: 20),
                const SizedBox(width: 8),
                Text(
                  "6-Month Trend",
                  style: TextStyle(
                    color: dark4,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Legends
                _buildLegendItem("Income", green),
                const SizedBox(width: 10),
                _buildLegendItem("Expense", red),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  minX: 0,
                  maxX: (trendData.length - 1).toDouble(),
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
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < trendData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                trendData[index]['label'] ?? '',
                                style: TextStyle(
                                  color: dark3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => dark4,
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isIncome = spot.barIndex == 0;
                          final label = isIncome ? "Inc" : "Exp";
                          return LineTooltipItem(
                            "$label: $currency ${spot.y.toInt()}",
                            TextStyle(
                              color: isIncome ? green : red,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    // Income line
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3.5,
                          color: green,
                          strokeWidth: 1.5,
                          strokeColor: white1,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: green.withValues(alpha: 0.08),
                      ),
                    ),
                    // Expense line
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3.5,
                          color: red,
                          strokeWidth: 1.5,
                          strokeColor: white1,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: red.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: dark3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
