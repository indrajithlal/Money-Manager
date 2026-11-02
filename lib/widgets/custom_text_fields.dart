import 'package:money_manager/constants/theme_data.dart';
import 'package:money_manager/widgets/custom_borders.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final String hintText;
  const CustomTextField({
    required this.textEditingController,
    required this.label,
    required this.hintText,
    super.key,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: dark_blue,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          cursorColor: dark_blue,
          controller: widget.textEditingController,
          validator: (value) {
            if (value!.isEmpty) {
              return "this field cannot be empty";
            }
            return null;
          },

          style: TextStyle(
            color: dark3,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          //controller: whatController,
          decoration: InputDecoration(
            hintText: widget.hintText,
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
    );
  }
}

class CustomAmountField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final String hintText;
  const CustomAmountField({
    required this.textEditingController,
    required this.label,
    required this.hintText,
    super.key,
  });

  @override
  State<CustomAmountField> createState() => _CustomAmountFieldState();
}

class _CustomAmountFieldState extends State<CustomAmountField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: dark_blue,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          keyboardType: TextInputType.number,
          cursorColor: dark_blue,
          controller: widget.textEditingController,
          validator: (value) {
            if (value!.isEmpty) {
              return "this field cannot be empty";
            }
            return null;
          },

          style: TextStyle(
            color: dark3,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          //controller: whatController,
          decoration: InputDecoration(
            hintText: widget.hintText,
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
    );
  }
}
