import 'package:anyen_clinic/login/login_screen.dart';
import 'package:anyen_clinic/widget/dateTimePicker.dart';
import 'package:anyen_clinic/widget/genderDropDown.dart';
import 'package:anyen_clinic/widget/normalButton.dart';
import 'package:flutter/material.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  _EditAccountScreenSate createState() => _EditAccountScreenSate();
}

class _EditAccountScreenSate extends State<EditAccountScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Sửa hồ sơ",
          style: TextStyle(
            color: Colors.blue,
            fontSize: screenWidth * 0.065,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xFF9BA5AC),
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1, vertical: screenHeight * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  "Họ và tên ",
                  style: TextStyle(fontSize: screenWidth * 0.035),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "*",
                  style: TextStyle(
                      fontSize: screenWidth * 0.035, color: Colors.red),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            TextField(
              style: TextStyle(fontSize: screenWidth * 0.04),
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
                hintText: "",
                hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                contentPadding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.03,
                    horizontal: screenWidth * 0.02),
              ),
            ),
            SizedBox(
              height: screenWidth * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Ngày sinh ",
                          style: TextStyle(fontSize: screenWidth * 0.035),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "*",
                          style: TextStyle(
                              fontSize: screenWidth * 0.035, color: Colors.red),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.03,
                    ),
                    DatePickerField(
                      width: screenWidth * 0.4,
                      initialDate: DateTime.now(),
                      onDateSelected: (selectedDate) {
                        print("Ngày được chọn: ${selectedDate.toString()}");
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Giới tính ",
                          style: TextStyle(fontSize: screenWidth * 0.035),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "*",
                          style: TextStyle(
                              fontSize: screenWidth * 0.035, color: Colors.red),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenWidth * 0.03,
                    ),
                    GenderDropdown(),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: screenWidth * 0.05,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Tiền sử bệnh ",
                style: TextStyle(fontSize: screenWidth * 0.035),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            TextField(
              style: TextStyle(fontSize: screenWidth * 0.04),
              maxLines: null,
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
                hintText: "",
                hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                contentPadding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.03,
                    horizontal: screenWidth * 0.02),
              ),
            ),
            SizedBox(
              height: screenWidth * 0.05,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Dị ứng ",
                style: TextStyle(fontSize: screenWidth * 0.035),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: screenWidth * 0.03,
            ),
            TextField(
              style: TextStyle(fontSize: screenWidth * 0.04),
              maxLines: null,
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
                hintText: "",
                hintStyle: TextStyle(fontSize: screenWidth * 0.04),
                contentPadding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.03,
                    horizontal: screenWidth * 0.02),
              ),
            ),
            SizedBox(
              height: screenWidth * 0.05,
            ),
            Spacer(),
            normalButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              label: "Lưu",
              nextScreen: LoginScreen(),
              action: null,
            )
          ],
        ),
      ),
    );
  }
}
