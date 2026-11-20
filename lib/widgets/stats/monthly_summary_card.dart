import 'package:flutter/material.dart';
import 'package:money_manager/constants/theme_data.dart';

class MonthlySummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double savings;
  final double savingsRate;
  final double avgDailySpend;
  final String currency;

  const MonthlySummaryCard({
    super.key,
    required this.income,
    required this.expense,
    required this.savings,
    required this.savingsRate,
    required this.avgDailySpend,
    this.currency = '₹',
  });

  String _formatAmount(double value) {
    if (value.truncateToDouble() == value) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositiveSavings = savings >= 0;

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
                Icon(Icons.analytics_outlined, color: dark1, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Monthly Overview",
                  style: TextStyle(
                    color: dark4,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: white1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.speed_outlined, size: 12, color: dark3),
                      const SizedBox(width: 4),
                      Text(
                        "$currency ${_formatAmount(avgDailySpend)}/day",
                        style: TextStyle(
                          color: dark3,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 3 metrics cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: "Income",
                    amount: "$currency ${_formatAmount(income)}",
                    icon: Icons.arrow_downward_rounded,
                    accentColor: green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: "Expenses",
                    amount: "$currency ${_formatAmount(expense)}",
                    icon: Icons.arrow_upward_rounded,
                    accentColor: red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    label: "Net Savings",
                    amount: "$currency ${_formatAmount(savings)}",
                    icon: isPositiveSavings
                        ? Icons.savings_outlined
                        : Icons.warning_amber_rounded,
                    accentColor: isPositiveSavings ? dark_blue : orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String amount,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: white1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 13),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark3,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                color: dark4,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
