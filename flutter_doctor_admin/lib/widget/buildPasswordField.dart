import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordVisibilityNotifier extends StateNotifier<bool> {
  PasswordVisibilityNotifier() : super(true);

  void toggle() {
    state = !state;
  }
}

class PasswordField extends ConsumerStatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String hintText;
  final TextEditingController controller;
  final bool isObscure;

  const PasswordField({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.hintText,
    required this.controller,
    this.isObscure = true,
  });

  @override
  ConsumerState<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends ConsumerState<PasswordField> {
  late bool isObscure;

  @override
  void initState() {
    super.initState();
    isObscure = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.screenWidth * 0.9,
      height: widget.screenHeight * 0.2,
      child: TextField(
        controller: widget.controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: widget.screenWidth * 0.05,
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
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isObscure = !isObscure;
              });
            },
          ),
        ),
        style: TextStyle(
          fontSize: widget.screenWidth * 0.045,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
