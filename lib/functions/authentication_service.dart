import 'package:money_manager/functions/functions.dart';
import 'package:money_manager/pages/authenticate_page.dart';
import 'package:money_manager/pages/home_page.dart';
import 'package:money_manager/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

void authenticateWithBiometrics(BuildContext context) async {
  Widget homeScreen = const HomePage();
  final LocalAuthentication auth = LocalAuthentication();

  void goToHomeScreen() {
    nextScreen(context, homeScreen);
  }

  if (await getEnableBiometricsStatus()) {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
      );
      if (didAuthenticate) {
        Navigator.pop(context);
        goToHomeScreen();
      } else {
        Navigator.pop(context);
        homeScreen = const AuthPage();
        goToHomeScreen();
      }
    } on PlatformException catch (e) {
      print(e);
    }
  } else {
    Navigator.pop(context);
    goToHomeScreen();
    return;
  }
}
