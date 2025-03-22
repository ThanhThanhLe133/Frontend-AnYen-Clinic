import 'package:anyen_clinic/widget/buildButton.dart';
import 'package:anyen_clinic/widget/dateTimePicker.dart';
import 'package:anyen_clinic/widget/genderDropDown.dart';
import 'package:flutter/material.dart';

void showUpdateInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return UpdateInfoDialog();
    },
  );
}

class UpdateInfoDialog extends StatelessWidget {
  const UpdateInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Vui lòng cập nhập thông tin",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                "Các bác sĩ cần một số thông tin cơ bản để có thể bắt đầu phiên tư vấn. Bạn vui lòng nhập thông tin chính xác nhé",
                style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Color(0xFF40494F),
                    height: 1.4),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: screenWidth * 0.03),

              // Họ và tên
              _buildLabel("Họ và tên"),
              SizedBox(height: screenWidth * 0.03),
              _buildTextField(),

              SizedBox(height: screenWidth * 0.03),

              // Ngày sinh & Giới tính
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Ngày sinh"),
                        SizedBox(height: screenWidth * 0.03),
                        DatePickerField(
                          width: screenWidth * 0.35,
                          initialDate: DateTime.now(),
                          onDateSelected: (selectedDate) {
                            print("Ngày được chọn: ${selectedDate.toString()}");
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Giới tính"),
                        SizedBox(height: screenWidth * 0.03),
                        GenderDropdown(),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenWidth * 0.03),

              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Chỉ số sức khoẻ",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Column(
                  children: [
                    _buildDateRow("Ngày đo:", screenWidth),
                    SizedBox(height: screenWidth * 0.03),
                    _buildMeasurementRow("Chiều cao:", "cm"),
                    SizedBox(height: screenWidth * 0.03),
                    _buildMeasurementRow("Cân nặng:", "kg"),
                  ],
                ),
              ),
              SizedBox(height: screenWidth * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                      text: "BỎ QUA",
                      isPrimary: false,
                      screenWidth: screenWidth),
                  CustomButton(
                    text: "CẬP NHẬT",
                    isPrimary: true,
                    screenWidth: screenWidth,
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm tạo tiêu đề có dấu *
  Widget _buildLabel(String text) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
        ),
        Text(
          "*",
          style: TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  /// Hàm tạo ô nhập thông tin
  Widget _buildTextField() {
    return TextField(
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Color(0xFFF3EFEF),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  /// Hàm tạo hàng nhập chỉ số sức khoẻ (chiều cao, cân nặng)
  Widget _buildMeasurementRow(String label, String unit) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFF3EFEF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(width: 5),
        Text(unit, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  /// Hàm tạo hàng nhập ngày đo
  Widget _buildDateRow(String label, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        DatePickerField(
          width: screenWidth * 0.35,
          initialDate: DateTime.now(),
          onDateSelected: (selectedDate) {
            print("Ngày được chọn: ${selectedDate.toString()}");
          },
        ),
      ],
    );
  }
}
