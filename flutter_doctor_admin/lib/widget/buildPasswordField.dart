import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordVisibilityNotifier extends StateNotifier<bool> {
  PasswordVisibilityNotifier() : super(true);

  void toggle() {
    state = !state;
  }
}

final passwordVisibilityProvider =
    StateNotifierProvider<PasswordVisibilityNotifier, bool>(
  (ref) => PasswordVisibilityNotifier(),
);

class PasswordField extends ConsumerWidget {
  final double screenWidth;
  final double screenHeight;
  final String hintText;
  final TextEditingController controller;

  const PasswordField({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obscurePassword = ref.watch(passwordVisibilityProvider);

    return SizedBox(
      width: screenWidth * 0.9,
      height: screenHeight * 0.2,
      child: TextField(
        controller: controller,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          hintText: hintText,
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
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              ref.read(passwordVisibilityProvider.notifier).toggle();
            },
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
