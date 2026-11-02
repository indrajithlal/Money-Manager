import 'package:money_manager/constants/theme_data.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white1,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w500,
            color: white3,
          ),
        ),
        elevation: 0,
        backgroundColor: dark4,
        foregroundColor: white3,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: white3),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Center(child: Image.asset('assets/notification.png')),
          ),
          Text(
            'Nothing new here',
            style: TextStyle(
              color: dark3,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
