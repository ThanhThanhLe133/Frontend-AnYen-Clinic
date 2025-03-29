import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showPrescriptionDialog(
  BuildContext context,
  List<Map<String, String>> medicines,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return PrescriptionDialog(medicines: medicines);
    },
  );
}

class PrescriptionDialog extends StatelessWidget {
  final List<Map<String, String>> medicines;
  const PrescriptionDialog({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Đơn thuốc",
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 10),
            ...medicines.map(
              (medicine) => _buildMedicineItem(medicine, screenWidth),
            ),
            SizedBox(height: 20),
            Divider(height: 1),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: "ĐÓNG",
                  isPrimary: false,
                  screenWidth: screenWidth,
                ),
                CustomButton(
                  text: "LIÊN HỆ CSKH",
                  isPrimary: true,
                  screenWidth: screenWidth,
                  onPressed: () {
                    print("Nút được nhấn!");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineItem(Map<String, String> medicine, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "• ${medicine['name']}",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "  ${medicine['dosage']}",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
