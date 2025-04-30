import 'package:flutter/material.dart';
import 'dart:math';

class GenderDropdown extends StatefulWidget {
  final TextEditingController controller;
  const GenderDropdown({super.key, required this.controller});

  @override
  _GenderDropdownState createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<GenderDropdown> {
  String? _selectedGender;
  final List<String> _genders = ["Nam", "Nữ", "Khác"];
  @override
  void initState() {
    super.initState();
    if (_genders.contains(widget.controller.text)) {
      _selectedGender = widget.controller.text;
    }
    widget.controller.addListener(_updateSelectedGenderFromController);
  }

  void _updateSelectedGenderFromController() {
    if (_genders.contains(widget.controller.text) &&
        widget.controller.text != _selectedGender) {
      setState(() {
        _selectedGender = widget.controller.text;
      });
    }
  }

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
            widget.controller.text = newValue;
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
