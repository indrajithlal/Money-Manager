import 'package:flutter/material.dart';
import 'package:money_manager/constants/theme_data.dart';

class AccountBreakdownCard extends StatelessWidget {
  final List<Map<String, dynamic>> accountData;
  final bool isExpense;
  final String currency;

  const AccountBreakdownCard({
    super.key,
    required this.accountData,
    required this.isExpense,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    if (accountData.isEmpty) {
      return const SizedBox.shrink();
    }

    double total = 0.0;
    for (var item in accountData) {
      total += ((item['total_amount'] ?? 0) as num).toDouble();
    }

    final Color barColor = isExpense ? red : green;

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
                Icon(Icons.account_balance_wallet_outlined,
                    color: dark1, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Account Breakdown",
                  style: TextStyle(
                    color: dark4,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: accountData.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = accountData[index];
                final String accountName = item['account'] ?? 'Unknown';
                final double amount =
                    ((item['total_amount'] ?? 0) as num).toDouble();
                final double percentage = total > 0 ? (amount / total) : 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: white1,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                accountName.toLowerCase().contains("cash")
                                    ? Icons.payments_outlined
                                    : Icons.account_balance_outlined,
                                size: 14,
                                color: dark2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              accountName,
                              style: TextStyle(
                                color: dark4,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "$currency ${amount.toInt()}  (${(percentage * 100).toStringAsFixed(1)}%)",
                          style: TextStyle(
                            color: dark4,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: white1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          barColor.withValues(
                            alpha: (0.4 + (percentage * 0.6)).clamp(0.4, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
