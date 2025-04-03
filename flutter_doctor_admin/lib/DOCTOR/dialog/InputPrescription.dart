import 'package:ayclinic_doctor_admin/widget/buildButton.dart';
import 'package:flutter/material.dart';

void showInputPrescriptionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return InputPrescriptionDialog();
    },
  );
}

class InputPrescriptionDialog extends StatefulWidget {
  const InputPrescriptionDialog({super.key});

  @override
  State<InputPrescriptionDialog> createState() =>
      _InputPrescriptionDialogState();
}

class _InputPrescriptionDialogState extends State<InputPrescriptionDialog> {
  List<TextEditingController> controllers = [TextEditingController()];

  void _addTextField() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: Text(
                      "Nhập đơn thuốc",
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenWidth * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tên, Số lượng",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "Liều dùng",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.03),
              ...controllers.map(
                (controller) => _buildTextField(controller, screenWidth),
              ),
              SizedBox(height: screenWidth * 0.05),
              Divider(height: 1),
              SizedBox(height: screenWidth * 0.05),
              Center(
                child: CustomButton(
                  text: "Thêm mới",
                  isPrimary: true,
                  screenWidth: screenWidth,
                  onPressed: _addTextField,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hàm tạo ô nhập thông tin
Widget _buildTextField(TextEditingController controller, double screenWidth) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: screenWidth * 0.4,
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Color(0xFFF3EFEF),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenWidth * 0.2,
          child: TextField(
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Color(0xFFF3EFEF),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.blue, width: 1),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
