import 'package:anyen_clinic/widget/phoneCode_drop_down/country_code_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneCodeDropdown extends ConsumerWidget {
  const PhoneCodeDropdown({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCode = ref.watch(countryCodeProvider);
    final List<Map<String, String>> countryCodes = [
      {
        "code": "+84",
        "flag": "https://flagcdn.com/w40/vn.png",
        "name": "Vietnam"
      },
      {
        "code": "+1",
        "flag": "https://flagcdn.com/w40/us.png",
        "name": "United States"
      },
      {
        "code": "+44",
        "flag": "https://flagcdn.com/w40/gb.png",
        "name": "United Kingdom"
      },
      {
        "code": "+33",
        "flag": "https://flagcdn.com/w40/fr.png",
        "name": "France"
      },
      {
        "code": "+49",
        "flag": "https://flagcdn.com/w40/de.png",
        "name": "Germany"
      },
    ];
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedCode,
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
        items: countryCodes.map((country) {
          return DropdownMenuItem<String>(
            value: country["code"],
            child: Row(
              children: [
                SizedBox(width: screenWidth * 0.01),
                Image.network(
                  country["flag"]!,
                  width: screenWidth * 0.06,
                  height: screenHeight * 0.04,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.1,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.flag, size: 24, color: Colors.grey);
                  },
                ),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  country["code"]!,
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            ref.read(countryCodeProvider.notifier).updateCode(newValue);
          }
        },
      ),
    );
  }
}
