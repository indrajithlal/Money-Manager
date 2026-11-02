import 'package:currency_picker/currency_picker.dart';
import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/database/database_helper.dart';
import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/pages/about_page.dart';
import 'package:money_manager/pages/categories_page.dart';
import 'package:money_manager/pages/home_page.dart';
import 'package:money_manager/widgets/custom_text_fields.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int dateFormat = 0;
  int timeFormat = 1;
  bool use24Format = false;
  bool enableBiometrics = false;
  String username = "Aleena M.A";
  String? _backupFilePath;

  // Function to open the file picker dialog
  Future<void> openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _backupFilePath = result.files.single.path;
      });
    }
    showAlert(
      context,
      "Restore?",
      "Are you sure you want to rewrite the database with $_backupFilePath",
      () {
        importDatabase(
          _backupFilePath!,
          () {
            showFooterMessage(
              context,
              "Succesfully imported $_backupFilePath",
              false,
            );
          },
          () {
            showFooterMessage(
              context,
              "Import Failed! Make sure the file has a '.db' extension",
              true,
            );
          },
        );
      },
      () {
        showFooterMessage(context, "Failed to import $_backupFilePath", true);
      },
    );
  }

  Future<void> signOut() async {
    //await Auth().signOut();
    await DatabaseHelper.clearData();
    setUserName("User");
    set24Format(false);
    setEnableBiometrics(false);
    setIsLoggedIn(false);
    Navigator.pop(context);
    nextScreen(context, const HomePage());
  }

  void getSavedData() async {
    username = await getUserName();
    use24Format = await get24FormatStatus();
    enableBiometrics = await getEnableBiometricsStatus();
    dateFormat = await getDateFormatIndex();
    print("24 format $use24Format");

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark4,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              //height: MediaQuery.of(context).size.height / 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: white2,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    onTap: showEditProfile,
                    /*leading: const SizedBox(
                      height: 60,
                      width: 60,
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/profilepic.jpeg'),
                      ),
                    ),*/
                    //contentPadding: const EdgeInsets.all(10),
                    title: Text(
                      'Username',
                      style: TextStyle(
                        color: white3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      //user?.email?.split("@")[0] ?? 'UserName',
                      username,
                      style: TextStyle(
                        color: white1,
                        fontWeight: FontWeight.w500,
                        fontSize: 25,
                      ),
                    ),
                    trailing: Icon(Icons.edit, color: white3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Material(
                color: white1,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaction",
                                  style: TextStyle(
                                    color: dark4,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ListTile(
                                  title: const MyText(text: 'Currency'),
                                  onTap: () {
                                    showCurrencyPicker(
                                      context: context,
                                      showFlag: false,
                                      showCurrencyName: true,
                                      showCurrencyCode: true,
                                      showSearchField: true,
                                      theme: CurrencyPickerThemeData(
                                        backgroundColor: white1,
                                        currencySignTextStyle: TextStyle(
                                          color: dark_blue,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        titleTextStyle: TextStyle(
                                          color: dark4,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        subtitleTextStyle: TextStyle(
                                          color: dark3,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onSelect: (Currency currency) {
                                        print(currency.symbol);
                                        setCurrency(currency.symbol);
                                        print(
                                          'Select currency: ${currency.name}',
                                        );
                                      },
                                    );
                                  },
                                  leading: Icon(Icons.euro, color: dark1),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: dark1,
                                  ),
                                ),
                                ListTile(
                                  title: const MyText(text: 'Accounts'),
                                  onTap: () {
                                    nextScreen(context, EditAccounts());
                                  },
                                  leading: Icon(
                                    Icons.credit_card,
                                    color: dark1,
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: dark1,
                                  ),
                                ),
                                ListTile(
                                  title: const MyText(text: 'Categories'),
                                  onTap: () {
                                    nextScreen(context, EditCategories());
                                  },
                                  leading: Icon(Icons.category, color: dark1),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: dark1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Security",
                                  style: TextStyle(
                                    color: dark4,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                /*ListTile(
                                    title:
                                        const MyText(text: 'Security Settings'),
                                    onTap: () {
                                      nextScreen(context,
                                          const Placeholder());
                                    },
                                    leading: Icon(
                                      Icons.lock,
                                      color: dark1,
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: dark1,
                                    ),
                                  ),*/
                                ListTile(
                                  title: const MyText(
                                    text: 'Enable Biometrics',
                                  ),
                                  leading: Icon(
                                    Icons.fingerprint,
                                    color: dark1,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      enableBiometrics = !enableBiometrics;
                                      setEnableBiometrics(enableBiometrics);
                                    });
                                  },
                                  trailing: CupertinoSwitch(
                                    activeColor: dark4,
                                    trackColor: white3,
                                    thumbColor: white1,
                                    value: enableBiometrics,
                                    onChanged: (value) {
                                      enableBiometrics = value;
                                      setEnableBiometrics(enableBiometrics);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Data",
                                  style: TextStyle(
                                    color: dark4,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ListTile(
                                  title: const MyText(text: 'Backup'),
                                  onTap: () async {
                                    //pickFolder();
                                    await exportDatabase();
                                    showFooterMessage(
                                      context,
                                      "backed up to Documents/money_manager/backups${getBackupName()}",
                                      false,
                                    );
                                    //showAlertOnlyOk(context, "Backup Successfull", "backed up the database to Documents/money_manager/backups${getBackupName()}", (){Navigator.pop(context);});
                                    // Show a message or confirmation that the export is complete.
                                  },
                                  leading: Icon(Icons.backup, color: dark1),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: dark1,
                                  ),
                                ),
                                ListTile(
                                  title: const MyText(text: 'Restore'),
                                  onTap: () async {
                                    openFilePicker();
                                  },
                                  leading: Icon(Icons.restore, color: dark1),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: dark1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Other",
                                  style: TextStyle(
                                    color: dark4,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    nextScreen(context, const AboutPage());
                                  },
                                  title: const MyText(text: 'About'),
                                  leading: Icon(Icons.info, color: dark_blue),
                                ),
                                ListTile(
                                  onTap: () {
                                    signOut();
                                  },
                                  title: Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  leading: Icon(Icons.logout, color: red),
                                ),
                              ],
                            ),
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
    );
  }

  Future showEditProfile() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: white1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: dark3,
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: SizedBox(
          //width: MediaQuery.of(context).size.width - 30,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePicEdit(
                  username: username,
                  onSave: (String name) {
                    setUserName(name);
                    getSavedData();
                  },
                ),
              ],
            ),
          ),
        ),
        /*actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: nord_dark_blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: nord_dark_blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                )
              ],*/
      ),
    );
  }
}

class MyText extends StatelessWidget {
  final String text;
  const MyText({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: dark1, fontSize: 18, fontWeight: FontWeight.w500),
    );
  }
}

class ProfilePicEdit extends StatefulWidget {
  final Function onSave;
  final String username;
  const ProfilePicEdit({
    required this.username,
    required this.onSave,
    super.key,
  });

  @override
  _ProfilePicEditState createState() => _ProfilePicEditState();
}

class _ProfilePicEditState extends State<ProfilePicEdit> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CustomTextField(
            textEditingController: nameController,
            label: "Username",
            hintText: "username",
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                  widget.onSave(nameController.text);
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: dark_blue,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
