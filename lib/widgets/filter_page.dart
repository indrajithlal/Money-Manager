import 'package:money_manager/constants/theme_data.dart';
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<bool> selectedMonths = [];
  List<bool> selectedYears = [];
  List<bool> selectedCategories = [];
  int numYears = 7;
  List<String> Months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  List<String> Categories = [
    'Food',
    'Travel',
    'Friends',
    'College',
    'Study',
    'Electronics',
    'Entertainment',
    'Fun',
  ];
  List<int> Years = [2017, 2018, 2019, 2020, 2021, 2022, 2023];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 12; i++) {
      selectedMonths.add(false);
    }
    for (int i = 0; i < Years.length; i++) {
      selectedYears.add(false);
    }
    for (int i = 0; i < Categories.length; i++) {
      selectedCategories.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    color: dark4,
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark4, // Background color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: white1,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Month',
                          style: TextStyle(
                            color: dark4,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < 12; i++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FilterChip(
                                    backgroundColor: white3,
                                    selectedColor: dark3,
                                    labelStyle: TextStyle(
                                      color: selectedMonths[i] ? white3 : dark4,
                                    ),
                                    selected: selectedMonths[i],
                                    label: Text(Months[i]),
                                    checkmarkColor: selectedMonths[i]
                                        ? white3
                                        : dark4,
                                    onSelected: (value) {
                                      setState(() {
                                        print(selectedMonths[i]);
                                        selectedMonths[i] = !selectedMonths[i];
                                        print(selectedMonths[i]);
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Year',
                          style: TextStyle(
                            color: dark4,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < numYears; i++)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FilterChip(
                                    backgroundColor: white3,
                                    selectedColor: dark3,
                                    labelStyle: TextStyle(
                                      color: selectedYears[i] ? white3 : dark4,
                                    ),
                                    selected: selectedYears[i],
                                    label: Text('${Years[i]}'),
                                    checkmarkColor: selectedYears[i]
                                        ? white3
                                        : dark4,
                                    onSelected: (value) {
                                      setState(() {
                                        print(selectedYears[i]);
                                        selectedYears[i] = !selectedYears[i];
                                        print(selectedYears[i]);
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            color: dark4,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              for (int i = 0; i < Categories.length; i++)
                                CheckboxListTile(
                                  title: Text(
                                    Categories[i],
                                    style: TextStyle(
                                      color: dark3,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  value: selectedCategories[i],
                                  //selectedTileColor: dark_color,
                                  checkColor: white1,
                                  selected: selectedCategories[i],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategories[i] =
                                          !selectedCategories[i];
                                    });
                                  },
                                  activeColor: dark3,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
