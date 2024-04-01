import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  const TextFieldInput({
    super.key,
    required this.textEditingController,
    required this.hintext,
    this.isPass = false,
    required this.textInputType,
    required this.validate,
  });

  final TextEditingController textEditingController;
  final bool isPass;
  final String hintext;
  final TextInputType textInputType;
  final String? Function(String?)? validate;

  @override
  Widget build(BuildContext context) {
    final inputBoreder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));

    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
          border: inputBoreder,
          hintText: hintext,
          focusedBorder: inputBoreder,
          filled: true,
          contentPadding: const EdgeInsets.all(0)),
      keyboardType: textInputType,
      obscureText: isPass,
      validator: validate,
    );
  }
}
