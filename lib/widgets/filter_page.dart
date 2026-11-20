import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  final Set<String> selectedCategories;
  final List<TransactionModel>? availableExpenses;

  const FilterPage({
    super.key,
    this.selectedCategories = const {},
    this.availableExpenses,
  });

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> categories = [];
  late Set<String> tempSelectedCategories;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tempSelectedCategories = Set.from(widget.selectedCategories);
    loadCategories();
  }

  void loadCategories() async {
    // Map of lowercase_key -> display_name for case-insensitive deduplication
    Map<String, String> categoryMap = {};

    // 1. Always guarantee "Income" category is present
    categoryMap['income'] = 'Income';

    // 2. Load from database CATEGORIES table
    List<String>? dbCats = await DatabaseHelper.getCategories();
    if (dbCats != null) {
      for (var c in dbCats) {
        final trimmed = c.trim();
        if (trimmed.isNotEmpty) {
          final lower = trimmed.toLowerCase();
          // Normalize display name: capitalize first letter
          final displayName = trimmed.length > 1
              ? trimmed[0].toUpperCase() + trimmed.substring(1)
              : trimmed.toUpperCase();
          categoryMap.putIfAbsent(lower, () => displayName);
        }
      }
    }

    // 3. Load from actual transactions in DB (in case legacy categories exist)
    if (widget.availableExpenses != null) {
      for (var exp in widget.availableExpenses!) {
        final trimmed = exp.category.trim();
        if (trimmed.isNotEmpty) {
          final lower = trimmed.toLowerCase();
          final displayName = trimmed.length > 1
              ? trimmed[0].toUpperCase() + trimmed.substring(1)
              : trimmed.toUpperCase();
          categoryMap.putIfAbsent(lower, () => displayName);
        }
        if (!exp.isExpense) {
          categoryMap['income'] = 'Income';
        }
      }
    }

    final sortedList = categoryMap.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (mounted) {
      setState(() {
        categories = sortedList;
        isLoading = false;
      });
    }
  }

  bool isCategorySelected(String cat) {
    return tempSelectedCategories.any(
      (c) => c.trim().toLowerCase() == cat.trim().toLowerCase(),
    );
  }

  void toggleCategory(String cat) {
    setState(() {
      final existing = tempSelectedCategories.firstWhere(
        (c) => c.trim().toLowerCase() == cat.trim().toLowerCase(),
        orElse: () => '',
      );
      if (existing.isNotEmpty) {
        tempSelectedCategories.remove(existing);
      } else {
        tempSelectedCategories.add(cat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter by Category',
                      style: TextStyle(
                        color: dark4,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (tempSelectedCategories.isNotEmpty) ...[
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          tempSelectedCategories.clear();
                        });
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: red,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, tempSelectedCategories);
                    },
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        color: white1,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tempSelectedCategories.isEmpty
                            ? "Showing all categories"
                            : "${tempSelectedCategories.length} of ${categories.length} selected",
                        style: TextStyle(color: dark3, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (tempSelectedCategories.length ==
                              categories.length) {
                            tempSelectedCategories.clear();
                          } else {
                            tempSelectedCategories.clear();
                            tempSelectedCategories.addAll(categories);
                          }
                        });
                      },
                      child: Text(
                        tempSelectedCategories.length == categories.length
                            ? "Deselect all"
                            : "Select all",
                        style: TextStyle(
                          color: dark_blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : categories.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              "No categories found in database",
                              style: TextStyle(
                                color: dark3,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = isCategorySelected(cat);
                            return CheckboxListTile(
                              dense: true,
                              title: Text(
                                cat,
                                style: TextStyle(
                                  color: dark4,
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              value: isSelected,
                              checkColor: white1,
                              activeColor: dark3,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              onChanged: (bool? value) {
                                toggleCategory(cat);
                              },
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
