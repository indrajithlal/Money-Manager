import 'package:money_manager/constants/theme_data.dart';
import 'package:flutter/material.dart';

OutlineInputBorder blueBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: dark_blue, width: 2),
  );
}

OutlineInputBorder darkBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: dark3, width: 2),
  );
}

OutlineInputBorder redBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: red, width: 2),
  );
}
