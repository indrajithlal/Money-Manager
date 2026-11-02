import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/pages/home_page.dart';
import 'package:flutter/material.dart';

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void refreshHomePage(context) {
  Navigator.pop(context);
  Navigator.pop(context);
  nextScreen(context, const HomePage());
}

bool showAlert(
  BuildContext context,
  String title,
  String description,
  Function onOk,
  Function onCancel,
) {
  bool result = false;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: TextStyle(color: red, fontSize: 22, fontWeight: FontWeight.w500),
      ),
      content: Text(
        description,
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
              onCancel();
              Navigator.pop(context);
              result = false;
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
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () {
              onOk();
              Navigator.pop(context);
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
  return result;
}

void showFooterMessage(BuildContext context, String message, bool isError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: white1,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: isError ? red : dark3,
    ),
  );
}
