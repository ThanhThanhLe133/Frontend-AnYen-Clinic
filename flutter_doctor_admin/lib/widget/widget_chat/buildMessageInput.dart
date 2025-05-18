import 'dart:io';

import 'package:ayclinic_doctor_admin/dialog/option_dialog.dart';
import 'package:ayclinic_doctor_admin/function.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MessageTextInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onTap;

  const MessageTextInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFECF8FF),
          hintText: 'Gõ nội dung...',
          hintStyle: TextStyle(
            fontSize: 16,
            color: Color(0xFF9AA5AC),
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        onSubmitted: (value) => onSend(),
        onTap: onTap,
      ),
    );
  }
}
