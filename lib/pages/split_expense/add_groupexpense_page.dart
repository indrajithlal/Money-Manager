import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/widgets/custom_borders.dart';
import 'package:money_manager/widgets/custom_text_fields.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SplitExpenseAddExpensepage extends StatefulWidget {
  final String id;
  final String participants;
  final Expense expense;
  const SplitExpenseAddExpensepage({
    required this.id,
    required this.participants,
    required this.expense,
    super.key,
  });

  @override
  State<SplitExpenseAddExpensepage> createState() =>
      _SplitExpenseAddExpensepageState();
}

class _SplitExpenseAddExpensepageState
    extends State<SplitExpenseAddExpensepage> {
  TextEditingController inputWhatField = TextEditingController();
  TextEditingController inputWhoField = TextEditingController();
  TextEditingController inputHowMuchField = TextEditingController();

  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  List<String> participantNames = ['indrajith', 'aleena', 'deepu'];
  List<bool> participantStatus = [];
  List<TextEditingController> participantsShareController = [];
  bool isAllSelected = false;
  String? payerName;

  void onMoneyEntered(value) {
    if (RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return;
    }

    List<int> selectedIndices = [];
    for (int i = 0; i < participantStatus.length; i++) {
      if (participantStatus[i]) {
        selectedIndices.add(i);
      }
    }
    double splitValue = (value == '' || selectedIndices.isEmpty)
        ? 0.0
        : (double.tryParse(value) ?? 0.0) / selectedIndices.length;
    splitValue = double.parse(splitValue.toStringAsFixed(1));
    for (int i = 0; i < participantStatus.length; i++) {
      if (participantStatus[i] == false) {
        participantsShareController[i].text = '';
      } else {
        participantsShareController[i].text = '$splitValue';
      }
    }
  }

  bool checkMoneySplitError() {
    bool errorOccured = false;
    double sum = 0.0;

    for (int i = 0; i < participantNames.length; i++) {
      sum += double.parse(
        participantsShareController[i].text.isEmpty
            ? "0.0"
            : participantsShareController[i].text,
      );
    }
    print(sum);
    double difference =
        double.parse(
          inputHowMuchField.text.isEmpty ? "0.0" : inputHowMuchField.text,
        ) -
        sum;
    difference = double.parse(difference.toStringAsFixed(2));

    if (difference > 1 || difference < -1) {
      errorOccured = true;
      print("e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Payment Discrepancy",
            style: TextStyle(
              color: red,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            "Amount paid doesn't match calculated total\n\nThere is a difference of $difference that needs to be settled",
            style: TextStyle(
              color: dark3,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  return;
                },
                child: Text(
                  "Ok",
                  style: TextStyle(
                    color: dark_blue,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return errorOccured;
  }

  void temp() async {
    List<Expense>? test = await DatabaseHelper.getAllExpenses();
    for (Expense expense in test!) {
      print(expense.borrowers);
      print(expense.tname);
      print(expense.tid);
    }
  }

  void validate() async {
    if (inputWhatField.text.isEmpty) {
      return;
    }

    if (inputHowMuchField.text.isEmpty) {
      return;
    } else {
      if (RegExp(r'[a-zA-Z]').hasMatch(inputHowMuchField.text)) {
        return;
      }
    }

    if (checkMoneySplitError()) {
      return;
    }

    Expense NewExpense = Expense(
      gid: int.parse(widget.id),
      tname: inputWhatField.text.trim().toLowerCase(),
      payername: payerName!,
      amount: int.parse(inputHowMuchField.text.trim().toLowerCase()),
      date: selectedDate,
      borrowers: encodeToString(getBorrowerNames()),
      borrowedamt: encodeToString(getBorrowedAmt()),
    );

    if (widget.expense.tname.isEmpty) {
      await DatabaseHelper.addExpense(NewExpense);
    } else {
      await DatabaseHelper.deleteExpense("${widget.expense.tid}");
      await DatabaseHelper.addExpense(NewExpense);
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  List<String> getBorrowerNames() {
    List<String> borrowers = [];
    for (int i = 0; i < participantNames.length; i++) {
      borrowers.add(participantNames[i]);
    }
    return borrowers;
  }

  List<String> getBorrowedAmt() {
    List<String> borrowedAmt = [];
    for (int i = 0; i < participantNames.length; i++) {
      borrowedAmt.add(
        participantsShareController[i].text.toLowerCase().trim().isEmpty
            ? "0"
            : participantsShareController[i].text.toLowerCase().trim().split(
                ".",
              )[0],
      );
    }
    return borrowedAmt;
  }

  String encodeToString(List<String> list) {
    String encodedString = '';
    for (String item in list) {
      encodedString += '$item,';
    }
    return encodedString.substring(0, encodedString.length - 1);
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(color: dark3, fontSize: 17, fontWeight: FontWeight.w500),
    ),
  );

  @override
  void initState() {
    super.initState();
    participantNames = widget.participants.isNotEmpty
        ? widget.participants.split(",")
        : [];
    participantStatus = List.generate(participantNames.length, (_) => false);
    participantsShareController = List.generate(
      participantNames.length,
      (_) => TextEditingController(),
    );
    if (participantNames.isNotEmpty) {
      payerName = participantNames[0];
    }
    initParticipants();
  }

  void initParticipants() async {
    String rawParticipants = widget.participants;
    Group? group = await DatabaseHelper.getGroupByID(widget.id);
    if (group != null && group.participants.isNotEmpty) {
      rawParticipants = group.participants;
    }

    if (!mounted) return;

    List<String> names =
        rawParticipants.isNotEmpty ? rawParticipants.split(",") : [];
    List<bool> status = List.generate(names.length, (_) => false);
    List<TextEditingController> controllers = List.generate(
      names.length,
      (_) => TextEditingController(),
    );

    String? currentPayer = names.isNotEmpty ? names[0] : null;

    if (widget.expense.tname.isNotEmpty) {
      inputWhatField.text = widget.expense.tname;
      inputWhoField.text = widget.expense.payername;
      currentPayer = widget.expense.payername;
      inputHowMuchField.text = "${widget.expense.amount}";
      selectedDate = widget.expense.date;

      List<String> oldBorrowers = widget.expense.borrowers.isNotEmpty
          ? widget.expense.borrowers.split(",")
          : [];
      List<String> borrowedAmt = widget.expense.borrowedamt.isNotEmpty
          ? widget.expense.borrowedamt.split(",")
          : [];

      for (int i = 0; i < names.length; i++) {
        int bIndex = oldBorrowers.indexOf(names[i]);
        if (bIndex != -1 && bIndex < borrowedAmt.length) {
          String amt = borrowedAmt[bIndex];
          if (amt.isNotEmpty &&
              int.tryParse(amt) != null &&
              int.parse(amt) != 0) {
            status[i] = true;
            controllers[i].text = amt;
          }
        } else if (i < borrowedAmt.length) {
          String amt = borrowedAmt[i];
          if (amt.isNotEmpty &&
              int.tryParse(amt) != null &&
              int.parse(amt) != 0) {
            status[i] = true;
            controllers[i].text = amt;
          }
        }
      }
    }

    setState(() {
      participantNames = names;
      participantStatus = status;
      participantsShareController = controllers;
      if (currentPayer != null && names.contains(currentPayer)) {
        payerName = currentPayer;
      } else if (names.isNotEmpty) {
        payerName = names[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: white1,
      appBar: AppBar(
        backgroundColor: dark4,
        foregroundColor: white1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
        title: Text(
          widget.expense.tname.isEmpty ? "Add Expense" : "Update Expense",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: white1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    textEditingController: inputWhatField,
                    label: "What",
                    hintText: "food",
                  ),
                  //const SizedBox(height: 10),
                  Text(
                    'Who paid',
                    style: TextStyle(
                      color: dark_blue,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: dark3, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: white1,
                          value: payerName,
                          isExpanded: true,
                          items: participantNames.map(buildMenuItem).toList(),
                          onChanged: (value) {
                            setState(() {
                              payerName = value;
                              inputWhoField.text = payerName!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Date',
                    style: TextStyle(
                      color: dark_blue,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000),
                        switchToInputEntryModeIcon: Icon(
                          Icons.edit,
                          color: dark4,
                        ),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: dark4,
                                onPrimary: white1,
                                onSurface: dark4,
                                //background: nord_green,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: dark_blue,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (dateTime != null) {
                        setState(() {
                          selectedDate = dateTime;
                        });
                      }
                    },
                    child: TextField(
                      enabled: false,
                      cursorColor: dark_blue,
                      style: TextStyle(
                        color: dark2,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      //controller: whatController,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: dark_blue,
                        ),
                        hintText:
                            "${selectedDate.day} ${DateFormat('MMMM').format(selectedDate)}, ${selectedDate.year}",
                        hintStyle: TextStyle(
                          color: dark3,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        focusedBorder: blueBorder(),
                        enabledBorder: darkBorder(),
                        disabledBorder: darkBorder(),
                        errorBorder: redBorder(),
                        border: darkBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How much",
                        style: TextStyle(
                          color: dark_blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        cursorColor: dark_blue,
                        controller: inputHowMuchField,
                        onChanged: (value) {
                          onMoneyEntered(value);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "this field cannot be empty";
                          }
                          return null;
                        },

                        style: TextStyle(
                          color: dark2,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        //controller: whatController,
                        decoration: InputDecoration(
                          hintText: "500",
                          hintStyle: TextStyle(
                            color: white3,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                          focusedBorder: blueBorder(),
                          enabledBorder: darkBorder(),
                          disabledBorder: darkBorder(),
                          errorBorder: redBorder(),
                          border: darkBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Select Users',
              style: TextStyle(
                color: dark_blue,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 2, color: dark2),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'All',
                          style: TextStyle(
                            color: dark2,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Checkbox(
                          value: isAllSelected,
                          onChanged: (value) {
                            for (int i = 0; i < participantStatus.length; i++) {
                              participantStatus[i] = value!;
                            }
                            onMoneyEntered(inputHowMuchField.text);
                            setState(() {
                              isAllSelected = value!;
                            });
                          },
                          activeColor: dark_blue,
                          checkColor: white1,
                        ),
                        Expanded(child: Container()),
                        Icon(Icons.person_add, color: dark_blue),
                      ],
                    ),
                  ),
                  Divider(thickness: 1.5, color: dark2),
                  Column(
                    children: [
                      for (
                        int index = 0;
                        index < participantNames.length;
                        index++
                      )
                        Row(
                          children: [
                            Checkbox(
                              value: participantStatus[index],
                              onChanged: (value) {
                                setState(() {
                                  participantStatus[index] = value!;
                                  isAllSelected = false;
                                  onMoneyEntered(inputHowMuchField.text);
                                });
                              },
                              activeColor: dark_blue,
                              checkColor: white1,
                            ),
                            Text(
                              participantNames[index],
                              style: TextStyle(
                                color: dark2,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(child: Container()),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                cursorColor: dark_blue,
                                controller: participantsShareController[index],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: dark2,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  focusColor: dark_blue,
                                  suffixIconColor: dark2,
                                  hintText: "0.0",
                                  hintStyle: TextStyle(
                                    color: dark3,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: const Icon(Icons.edit),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: dark2,
        elevation: 0,
        onPressed: () {
          _formKey.currentState!.validate();
          validate();
        },
        label: SizedBox(
          width: 70,
          child: Center(
            child: Text(
              widget.expense.tname.isEmpty ? "Save" : "Update",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: white3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
