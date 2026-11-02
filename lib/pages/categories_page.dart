import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:flutter/material.dart';

class EditCategories extends StatefulWidget {
  const EditCategories({super.key});

  @override
  State<EditCategories> createState() => _EditCategoriesState();
}

class _EditCategoriesState extends State<EditCategories> {
  List<String> categories = [];

  void getCategoryDatabase() async {
    categories = (await DatabaseHelper.getCategories())!;
    setState(() {});
  }

  void updateCategoryDatabase() async {
    await DatabaseHelper.deleteAllCategories();
    for (String name in categories) {
      await DatabaseHelper.addCategory(name);
    }
    print(await DatabaseHelper.getCategories());
  }

  @override
  void initState() {
    super.initState();
    getCategoryDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      appBar: AppBar(
        foregroundColor: white2,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: dark3),
          onPressed: () {
            updateCategoryDatabase();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Categories',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w500,
            color: dark1,
          ),
        ),
        elevation: 0,
        backgroundColor: white3,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Container(
              //height: 60,
              decoration: BoxDecoration(
                color: white1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category, color: dark2),
                        const SizedBox(width: 20),
                        Text(
                          categories[index],
                          style: TextStyle(
                            color: dark2,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_drop_up,
                            color: index == 0 ? white3 : dark2,
                          ),
                          onPressed: () {
                            if (index != 0) {
                              String temp = categories[index - 1];
                              categories[index - 1] = categories[index];
                              categories[index] = temp;
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: index == categories.length - 1
                                ? white3
                                : dark2,
                          ),
                          onPressed: () {
                            if (index != categories.length - 1) {
                              String temp = categories[index + 1];
                              categories[index + 1] = categories[index];
                              categories[index] = temp;
                              setState(() {});
                            }
                          },
                        ),
                        Expanded(child: Container()),
                        IconButton(
                          onPressed: () {
                            showAddCategoryDialog(categories[index], index);
                          },
                          icon: Icon(Icons.edit, color: dark4),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.delete, color: dark4),
                          onPressed: () {
                            setState(() {
                              categories.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAddCategoryDialog("", 0);
        },
        label: Text(
          "Add",
          style: TextStyle(
            color: white3,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(Icons.add, color: white3),
        backgroundColor: dark_blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  Future showAddCategoryDialog(String categoryName, int index) {
    //String CategoryName = categoryName;
    TextEditingController categoryNameController = TextEditingController();
    categoryNameController.text = categoryName;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    void validate() {
      if (formKey.currentState!.validate()) {
        if (categoryName.isNotEmpty) {
          categories[index] = categoryNameController.text;
          Navigator.pop(context);
          updateCategoryDatabase();
          setState(() {});
          return;
        }
        categories.add(categoryNameController.text);
        Navigator.pop(context);
        updateCategoryDatabase();
        setState(() {});
      } else {
        print("failure");
      }
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          categoryName.isEmpty ? "Add Category" : "Update Category",
          style: TextStyle(
            color: dark3,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width - 30,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    cursorColor: dark_blue,
                    controller: categoryNameController,
                    autofocus: true,
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
                    decoration: InputDecoration(
                      //hintText: widget.hintText,
                      labelText: "Name",
                      labelStyle: TextStyle(
                        color: dark2,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: dark_blue, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: dark4, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: red, width: 1.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: dark3, width: 1.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Text(
                    "*required",
                    style: TextStyle(
                      color: dark4,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: dark_blue,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              validate();
            },
            child: Text(
              categoryName.isEmpty ? "Add" : "Update",
              style: TextStyle(
                color: dark_blue,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditAccounts extends StatefulWidget {
  const EditAccounts({super.key});

  @override
  State<EditAccounts> createState() => _EditAccountsState();
}

class _EditAccountsState extends State<EditAccounts> {
  List<String> accounts = [];

  void getAccountsDatabase() async {
    accounts = (await DatabaseHelper.getAccounts())!;
    setState(() {});
  }

  void updateAccountsDatabase() async {
    await DatabaseHelper.deleteAllAccount();
    for (String name in accounts) {
      await DatabaseHelper.addAccount(name);
    }
    print(await DatabaseHelper.getAccounts());
  }

  @override
  void initState() {
    super.initState();
    getAccountsDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white3,
      appBar: AppBar(
        foregroundColor: dark2,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: dark4),
          onPressed: () {
            updateAccountsDatabase();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Accounts',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w500,
            color: dark2,
          ),
        ),
        elevation: 0,
        backgroundColor: white3,
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Container(
              //height: 60,
              decoration: BoxDecoration(
                color: white1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category, color: dark4),
                        const SizedBox(width: 20),
                        Text(
                          accounts[index],
                          style: TextStyle(
                            color: dark3,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_drop_up,
                            color: index == 0 ? white3 : dark2,
                          ),
                          onPressed: () {
                            if (index != 0) {
                              String temp = accounts[index - 1];
                              accounts[index - 1] = accounts[index];
                              accounts[index] = temp;
                              setState(() {});
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: index == accounts.length - 1
                                ? white3
                                : dark2,
                          ),
                          onPressed: () {
                            if (index != accounts.length - 1) {
                              String temp = accounts[index + 1];
                              accounts[index + 1] = accounts[index];
                              accounts[index] = temp;
                              setState(() {});
                            }
                          },
                        ),
                        Expanded(child: Container()),
                        IconButton(
                          onPressed: () {
                            showAddAccountDialog(accounts[index], index);
                          },
                          icon: Icon(Icons.edit, color: dark4),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.delete, color: dark4),
                          onPressed: () {
                            setState(() {
                              accounts.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAddAccountDialog("", 0);
        },
        label: Text(
          "Add",
          style: TextStyle(
            color: white1,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(Icons.add, color: white1),
        backgroundColor: dark_blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  Future showAddAccountDialog(String accountName, int index) {
    //String CategoryName = categoryName;
    TextEditingController accountNameController = TextEditingController();
    accountNameController.text = accountName;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    void validate() {
      if (formKey.currentState!.validate()) {
        if (accountName.isNotEmpty) {
          accounts[index] = accountNameController.text;
          Navigator.pop(context);
          updateAccountsDatabase();
          setState(() {});
          return;
        }
        accounts.add(accountNameController.text);
        updateAccountsDatabase();
        Navigator.pop(context);
        setState(() {});
      } else {
        print("failure");
      }
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          accountName.isEmpty ? "Add Account" : "Update Account",
          style: TextStyle(
            color: dark4,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width - 30,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: formKey,
                  child: TextFormField(
                    cursorColor: dark_blue,
                    controller: accountNameController,
                    autofocus: true,
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
                    decoration: InputDecoration(
                      //hintText: widget.hintText,
                      labelText: "Name",
                      labelStyle: TextStyle(
                        color: dark_blue,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: dark_blue, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: dark4, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: red, width: 1.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: dark4, width: 1.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Text(
                    "*required",
                    style: TextStyle(
                      color: dark4,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                color: dark_blue,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              validate();
            },
            child: Text(
              accountName.isEmpty ? "Add" : "Update",
              style: TextStyle(
                color: dark_blue,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
