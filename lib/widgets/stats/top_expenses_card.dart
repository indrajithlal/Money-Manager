import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/add_expense_page.dart';

class TopExpensesCard extends StatelessWidget {
  final List<TransactionModel> topTransactions;
  final bool isExpense;
  final VoidCallback onRefresh;
  final String currency;

  const TopExpensesCard({
    super.key,
    required this.topTransactions,
    required this.isExpense,
    required this.onRefresh,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    if (topTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final String title = isExpense ? "Top Expenses" : "Top Income";
    final Color amountColor = isExpense ? red : green;

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
                Icon(Icons.workspace_premium_outlined, color: dark1, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: dark4,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  "Top ${topTransactions.length}",
                  style: TextStyle(
                    color: dark3,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topTransactions.length,
              separatorBuilder: (context, i) => const Divider(
                height: 16,
                thickness: 0.8,
                color: Color(0xFFD8DEE9),
              ),
              itemBuilder: (context, index) {
                final tx = topTransactions[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpensePage(
                          whatData: tx.name,
                          dateData: tx.date,
                          amountData: '${tx.amount}',
                          descriptionData: tx.description,
                          accountName: tx.account,
                          categoryName: tx.category,
                          isExpense: tx.isExpense,
                        ),
                      ),
                    );
                    onRefresh();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? yellow.withValues(alpha: 0.35)
                                : white1,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "#${index + 1}",
                              style: TextStyle(
                                color: index == 0 ? dark4 : dark3,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: dark4,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('dd MMM').format(tx.date),
                                    style: TextStyle(
                                      color: dark3,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: white3,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      tx.category,
                                      style: TextStyle(
                                        color: dark4,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (tx.account.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: white1,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        tx.account,
                                        style: TextStyle(
                                          color: dark3,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "$currency ${tx.amount}",
                          style: TextStyle(
                            color: amountColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: dark3,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
