import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.validator,
    this.keyboardType, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 37),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        keyboardType: keyboardType, 
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xff61169E)),
          fillColor: Color.fromARGB(234, 254, 246, 254),
          filled: true,
          labelStyle: TextStyle(color: Color.fromARGB(255, 31, 3, 54)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff61169E)),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff61169E)),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ),
    );
  }
}
