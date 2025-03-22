import 'package:anyen_clinic/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBackButton extends ConsumerWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
      iconSize: MediaQuery.of(context).size.width * 0.08,
      onPressed: () async {
        ref.read(menuOpenProvider.notifier).state = false;
        Navigator.pop(context);
      },
    );
  }
}
