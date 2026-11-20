import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/models/models.dart';
import 'package:money_manager/pages/home_page.dart';
import 'package:money_manager/widgets/custom_borders.dart';
import 'package:money_manager/widgets/custom_text_fields.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  final String whatData;
  final String amountData;
  final String descriptionData;
  final DateTime dateData;
  final String accountName;
  final String categoryName;
  final bool isExpense;

  const AddExpensePage({
    required this.whatData,
    required this.amountData,
    required this.descriptionData,
    required this.dateData,
    required this.accountName,
    required this.categoryName,
    required this.isExpense,
    super.key,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  TextEditingController whatController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isAddExpense = true;

  String? accountName;
  String? categoryName;
  String expenseType = 'expense';
  List<String> type = ['expense', 'income'];
  List<String> accounts = [];
  List<String> categories = [];

  DateTime selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: TextStyle(color: dark3, fontSize: 17, fontWeight: FontWeight.w500),
    ),
  );

  void getDatabase() async {
    accounts = (await DatabaseHelper.getAccounts())!;
    categories = (await DatabaseHelper.getCategories())!;
    accountName = accounts.isEmpty ? "" : accounts[0];
    categoryName = categories.isEmpty ? "" : categories[0];
    accountName = widget.accountName.isEmpty ? accountName : widget.accountName;
    categoryName = widget.categoryName.isEmpty
        ? categoryName
        : widget.categoryName;
    if (!widget.isExpense) {
      categories.clear();
      categories.add("income");
      categoryName = categories[0];
    }
    setState(() {});
  }

  void onSubmit() async {
    if (descriptionController.text.isEmpty) {
      descriptionController.text = ' ';
    }
    if (_formKey.currentState!.validate()) {
      TransactionModel expense = TransactionModel(
        name: whatController.text,
        amount: int.parse(amountController.text),
        category: expenseType == 'expense' ? categoryName! : 'income',
        account: accountName!,
        date: selectedDate,
        description: descriptionController.text,
        isExpense: expenseType == 'expense' ? true : false,
      );
      if (!isAddExpense) {
        TransactionModel oldExpense = TransactionModel(
          name: widget.whatData,
          amount: int.parse(widget.amountData),
          category: widget.categoryName,
          account: widget.accountName,
          date: widget.dateData,
          description: widget.descriptionData,
          isExpense: widget.isExpense,
        );
        await DatabaseHelper.deleteTransaction(oldExpense);
      }
      await DatabaseHelper.addTransaction(expense);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getDatabase();
    if (widget.whatData.isNotEmpty) {
      setState(() {
        isAddExpense = false;
      });
    }
    whatController.text = widget.whatData;
    amountController.text = widget.amountData;
    descriptionController.text = widget.descriptionData;
    selectedDate = widget.dateData;

    if (!isAddExpense && !widget.isExpense) {
      categories.clear();
      categories.add("income");
      categoryName = categories[0];
      print(categoryName);
      print(categories);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white1,
      appBar: AppBar(
        backgroundColor: dark2,
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
          isAddExpense ? "Add Expense" : "Update Expense",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: white1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                textEditingController: whatController,
                label: "What",
                hintText: "food",
              ),
              //const SizedBox(height: 10),
              CustomAmountField(
                textEditingController: amountController,
                label: "Amount",
                hintText: "₹ 30",
              ),

              Text(
                'Category',
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
                      value: categoryName,
                      isExpanded: true,
                      items: categories.map(buildMenuItem).toList(),
                      onChanged: (value) {
                        setState(() {
                          categoryName = value;
                          //inputWhoField.text = payerName!;
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
                    switchToInputEntryModeIcon: Icon(Icons.edit, color: dark4),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: dark4,
                            onPrimary: white1,
                            onSurface: dark4,
                            surface: white1,
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
                    suffixIcon: Icon(Icons.calendar_today, color: dark_blue),
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

              Text(
                'Type',
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
                      value: expenseType,
                      isExpanded: true,
                      items: type.map(buildMenuItem).toList(),
                      onChanged: (value) {
                        setState(() {
                          expenseType = value!;
                          //inputWhoField.text = payerName!;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              /*CustomTextField(
                  textEditingController: whatController,
                  label: "Account",
                  hintText: "Cash"),*/
              Text(
                'Account',
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
                      value: accountName,
                      isExpanded: true,
                      items: accounts.map(buildMenuItem).toList(),
                      onChanged: (value) {
                        setState(() {
                          accountName = value;
                          //inputWhoField.text = payerName!;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              CustomTextField(
                textEditingController: descriptionController,
                label: "Description",
                hintText: "type something..",
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: dark2,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () {
          onSubmit();
        },
        label: SizedBox(
          width: 100,
          child: Center(
            child: Text(
              isAddExpense ? "Save" : "Update",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: white1,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
