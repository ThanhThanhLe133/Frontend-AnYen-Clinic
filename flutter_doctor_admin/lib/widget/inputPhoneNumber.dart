import 'package:ayclinic_doctor_admin/widget/phoneCode_drop_down/phoneCode_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InputPhoneNumber extends ConsumerWidget {
  const InputPhoneNumber({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.controller,
  });

  final double screenWidth;
  final double screenHeight;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: screenWidth * 0.9,
      height: screenHeight * 0.2,
      child: TextField(
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: controller,
        onChanged: (value) {},
        decoration: InputDecoration(
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.call, color: Color.fromARGB(255, 151, 200, 231)),
              const SizedBox(width: 8),
              PhoneCodeDropdown(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ],
          ),
          hintText: "Nhập số điện thoại",
          hintStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            color: const Color(0xFF9AA5AC),
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF9AA5AC), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        style: TextStyle(
          fontSize: screenWidth * 0.045,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
