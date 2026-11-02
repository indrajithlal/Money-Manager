import 'package:money_manager/constants/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelecterHeader extends StatefulWidget {
  final DateTime date;
  final Function onChange;

  const MonthSelecterHeader({
    required this.date,
    required this.onChange,
    super.key,
  });

  @override
  State<MonthSelecterHeader> createState() => _MonthSelecterHeaderState();
}

class _MonthSelecterHeaderState extends State<MonthSelecterHeader> {
  final DateFormat monthFormat = DateFormat.MMMM();
  DateTime date = DateTime.now();
  DateTime tempDate = DateTime.now();
  bool changeDate = false;

  List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    date = widget.date;
    tempDate = date;
  }

  Future<void> showMonthPicker() async {
    //changeDate = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  tempDate = DateTime(tempDate.year - 1);
                  Navigator.pop(context);
                  changeDate = true;
                  showMonthPicker();
                });
              },
              child: Icon(Icons.arrow_back_ios, color: dark3),
            ),
            Text(
              "${tempDate.year}",
              style: TextStyle(
                fontSize: 25,
                color: dark_blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  tempDate = DateTime(tempDate.year + 1);
                  Navigator.pop(context);
                  changeDate = true;
                  showMonthPicker();
                });
              },
              child: Icon(Icons.arrow_forward_ios, color: dark3),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int j = 0; j < 3; j++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              tempDate = DateTime(
                                tempDate.year,
                                (i + j * 4) + 1,
                              );
                              Navigator.pop(context);
                              changeDate = true;
                              showMonthPicker();
                            });
                          },
                          child: Text(
                            monthNames[i + j * 4],
                            style: TextStyle(
                              color: tempDate.month - 1 == (i + j * 4)
                                  ? red
                                  : dark1,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              tempDate = date;
              Navigator.pop(context);
            },
            child: Text(
              "cancel",
              style: TextStyle(
                color: dark_blue,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              date = tempDate;
              widget.onChange(date);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(
              "ok",
              style: TextStyle(
                color: dark_blue,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).then((value) {
      if (changeDate) {
        changeDate = false;
      } else {
        tempDate = date;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white1,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (date.month > 1) {
                  date = DateTime(date.year, date.month - 1);
                  widget.onChange(date);
                  setState(() {});
                } else {
                  date = DateTime(date.year - 1, 12);
                  widget.onChange(date);
                  setState(() {});
                }
                tempDate = date;
              },
              child: Icon(Icons.arrow_back_ios, color: dark3),
            ),
            GestureDetector(
              onTap: () {
                showMonthPicker();
              },
              child: Text(
                "${monthFormat.format(date)} ${date.year}",
                style: TextStyle(
                  fontSize: 20,
                  color: dark_blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (date.month < 12) {
                  date = DateTime(date.year, date.month + 1);
                  widget.onChange(date);
                  setState(() {});
                } else {
                  date = DateTime(date.year + 1, 1);
                  widget.onChange(date);
                  setState(() {});
                }
                tempDate = date;
              },
              child: Icon(Icons.arrow_forward_ios, color: dark3),
            ),
          ],
        ),
      ),
    );
  }
}
