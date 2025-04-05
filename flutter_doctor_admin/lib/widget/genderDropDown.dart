import 'package:flutter/material.dart';
import 'dart:math';

class GenderDropdown extends StatefulWidget {
  const GenderDropdown({super.key});

  @override
  _GenderDropdownState createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<GenderDropdown> {
  String? _selectedGender;
  final List<String> _genders = ["Nam", "Nữ", "Khác"];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: min(screenWidth * 0.3, 150),
      decoration: BoxDecoration(
        color: Color(0xFFF3EFEF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFD9D9D9), width: 1),
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.03,
        horizontal: screenWidth * 0.02,
      ),
      height: screenWidth * 0.13,
      child: DropdownButton<String>(
        dropdownColor: Colors.white,
        value: _selectedGender,
        underline: SizedBox(),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue!;
          });
        },
        items:
            _genders.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Center(
                  child: Text(
                    gender,
                    style: TextStyle(fontSize: screenWidth * 0.04),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
