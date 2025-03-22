import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showPaymentHistoryDialog(BuildContext context, String paymentMethod,
    bool isSuccess, int money, DateTime time) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PaymentHistoryDialog(
        paymentMethod: paymentMethod,
        isSuccess: isSuccess,
        money: money,
        time: time,
      );
    },
  );
}

class PaymentHistoryDialog extends StatelessWidget {
  final String paymentMethod;
  final bool isSuccess;
  final int money;
  final DateTime time;

  const PaymentHistoryDialog({
    super.key,
    required this.paymentMethod,
    required this.isSuccess,
    required this.money,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");
    final formatDate = DateFormat("dd/MM/yyyy, HH:mm");
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Lịch sử thanh toán",
              style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                "Hình thức thanh toán",
                paymentMethod,
                boldValue: true,
                screenWidth),
            _buildInfoRow(
              "Trạng thái",
              isSuccess ? "Thành công" : "Thất bại",
              screenWidth,
              colorValue: isSuccess ? Colors.green : Colors.red,
            ),
            _buildInfoRow(
              "Số tiền",
              "${money < 0 ? '' : '-'}${formatCurrency.format(money)} đ",
              screenWidth,
              boldValue: true,
            ),
            _buildInfoRow(
              "Thời gian",
              formatDate.format(time),
              screenWidth,
              boldValue: true,
            ),
            SizedBox(height: 20),
            Divider(height: 1),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenWidth * 0.02),
              ),
              child: Text("OK",
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.04)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    double screenWidth, {
    bool boldValue = false,
    Color? colorValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: screenWidth * 0.04, color: Color(0xFF40494F))),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
              color: colorValue ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
