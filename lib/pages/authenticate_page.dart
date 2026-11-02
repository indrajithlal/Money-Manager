import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/functions/authentication_service.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white1,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(height: 0),
          Text(
            "Money Manager",
            style: TextStyle(
              color: dark_blue,
              fontSize: 35,
              fontWeight: FontWeight.w500,
            ),
          ),
          //const SizedBox(height: 50,),
          Container(
            child: Center(child: Image.asset('assets/moneymanage.png')),
          ),
          //const SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: dark3),
                  child: Text(
                    "Unlock",
                    style: TextStyle(
                      fontSize: 18,
                      color: white1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    //Navigator.pop(context);
                    authenticateWithBiometrics(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
