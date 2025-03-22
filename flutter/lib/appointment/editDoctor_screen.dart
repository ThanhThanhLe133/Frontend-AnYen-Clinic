import 'package:anyen_clinic/appointment/changeDoctor_screen.dart';
import 'package:anyen_clinic/payment/PaymentOptionWidget.dart';
import 'package:flutter/material.dart';

import '../widget/DoctorCard.dart';

class EditDoctorScreen extends StatelessWidget {
  const EditDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSelected = true;
    return StatefulBuilder(builder: (context, setState) {
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
            "Sửa bác sĩ",
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
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.all(screenWidth * 0.02),
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Bóng đậm hơn một chút
                      blurRadius: 7, // Mở rộng bóng ra xung quanh
                      spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Bác sĩ tư vấn hiện tại",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    DoctorCard(
                      doctorName: "BS.CKI Macus Horizon",
                      specialty: "Tâm lý - Nội tổng quát",
                      imageUrl:
                          "https://images.unsplash.com/photo-1537368910025-700350fe46c7",
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangeDoctorScreen()),
                          );
                        },
                        child: Text(
                          'Đổi bác sĩ',
                          style: TextStyle(
                            color: Color(0xFF119CF0),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Phí tư vấn",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF40494F))),
                    Text(
                      "99.000 đ",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đã thanh toán",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Color(0xFF40494F))),
                    Text(
                      "99.000 đ",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Thanh toán thêm",
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF40494F))),
                    Text(
                      "199.000 đ",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.all(screenWidth * 0.02),
                margin: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Bóng đậm hơn một chút
                      blurRadius: 7, // Mở rộng bóng ra xung quanh
                      spreadRadius: 1, // Kéo dài bóng theo mọi hướng
                      offset: Offset(0, 0), // Không dịch chuyển, bóng tỏa đều
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hình thức thanh toán",
                            style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF40494F)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PaymentOptionWidget(
                            text: "Momo",
                            isMoMo: true,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => isSelected = true);
                            },
                            screenWidth: screenWidth),
                        PaymentOptionWidget(
                            text: "Chuyển khoản ngân hàng",
                            isMoMo: false,
                            isSelected: !isSelected,
                            onTap: () {
                              setState(() => isSelected = true);
                            },
                            screenWidth: screenWidth),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              Spacer(),
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
                child: Text("CẬP NHẬT",
                    style: TextStyle(
                        color: Colors.white, fontSize: screenWidth * 0.04)),
              ),
            ],
          ),
        ),
      );
    });
  }
}
