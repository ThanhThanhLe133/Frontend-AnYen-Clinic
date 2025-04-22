import 'dart:convert';

import 'package:anyen_clinic/makeRequest.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showPaymentHistoryDialog(BuildContext context, String appointmentId) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PaymentHistoryDialog(appointment_id: appointmentId);
    },
  );
}

class PaymentHistoryDialog extends StatefulWidget {
  final String appointment_id;

  const PaymentHistoryDialog({
    super.key,
    required this.appointment_id,
  });

  @override
  State<PaymentHistoryDialog> createState() => _PaymentHistoryDialogState();
}

class _PaymentHistoryDialogState extends State<PaymentHistoryDialog> {
  Map<String, dynamic> payment = {};
  Future<void> fetchPayment() async {
    String appointmentId = widget.appointment_id;
    final response = await makeRequest(
        url: '$apiUrl/payment/get-payment',
        method: 'GET',
        body: {"appointment_id": appointmentId});
    if (response.statusCode != 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu.")));
      Navigator.pop(context);
    } else {
      final data = jsonDecode(response.body);
      setState(() {
        payment = data['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPayment();
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");
    final formatDate = DateFormat("dd/MM/yyyy, HH:mm");
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
                  payment['payment_method'],
                  boldValue: true,
                  screenWidth),
              _buildInfoRow(
                "Trạng thái",
                payment['payment_status'] == 'Paid' ? "Thành công" : "Thất bại",
                screenWidth,
                colorValue: payment['payment_status'] == 'Paid'
                    ? Colors.green
                    : Colors.red,
              ),
              _buildInfoRow(
                "Số tiền",
                "${formatCurrency.format(payment['total_paid'])} đ",
                screenWidth,
                boldValue: true,
              ),
              _buildInfoRow(
                "Thời gian",
                formatDate.format(payment['paid_at']),
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
