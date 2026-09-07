import 'package:flutter/material.dart';

class CommonTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;

  const CommonTextField({super.key, required this.label, this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
