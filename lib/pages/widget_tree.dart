import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/pages/authenticate_page.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/pages/home_page.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  Widget HomeScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    bool lockScreenStatus = await getEnableBiometricsStatus();
    setState(() {
      if (lockScreenStatus) {
        HomeScreen = const AuthPage();
      } else {
        HomeScreen = const HomePage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen;
  }
}
