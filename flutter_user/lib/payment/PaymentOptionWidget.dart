import 'package:flutter/material.dart';

class PaymentOptionWidget extends StatelessWidget {
  final String text;
  final bool isMoMo;
  final String value;
  final String selectedPayment;
  final VoidCallback onTap;
  final double screenWidth;

  const PaymentOptionWidget({
    super.key,
    required this.text,
    required this.isMoMo,
    required this.value,
    required this.selectedPayment,
    required this.onTap,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: screenWidth * 0.4,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.scale(
              scale: screenWidth / 500,
              child: Radio<String>(
                value: value,
                groupValue: selectedPayment,
                onChanged: (_) => onTap(),
                activeColor: Colors.blue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Image.asset(
              isMoMo ? "assets/images/momo.png" : "assets/images/banking.png",
              width: screenWidth * 0.08,
              height: screenWidth * 0.08,
              fit: BoxFit.contain,
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Wrap(
                children: [
                  Text(
                    text,
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
