import 'package:flutter/material.dart';

import '../screen/portfolio.dart';

class BuildTextField extends StatelessWidget {
  const BuildTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.maxLines,
    required this.selectedLanguage,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final Language selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: selectedLanguage == Language.arabic
          ? TextAlign.right
          : TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF3949AB), // Deep blue for the label
          fontWeight: FontWeight.bold,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon:
            Icon(icon, color: const Color(0xff2195f1)), // Sky blue for the icon
        filled: true,
        fillColor: Colors.white, // Light blue background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF3949AB), width: 2), // Deep blue border
        ),
      ),
      style: const TextStyle(
        color: Colors.black, // Input text color
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
