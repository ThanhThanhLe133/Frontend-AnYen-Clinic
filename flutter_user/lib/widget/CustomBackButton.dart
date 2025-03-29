import 'package:anyen_clinic/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomBackButton extends ConsumerWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: IconButton(
        icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
        iconSize: 40,
        onPressed: () async {
          ref.read(menuOpenProvider.notifier).state = false;
          Navigator.pop(context);
        },
      ),
    );
  }
}
