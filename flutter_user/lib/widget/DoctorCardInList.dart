import 'package:anyen_clinic/doctor/details_doctor_screen.dart';
import 'package:flutter/material.dart';

class DoctorCardInList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final String name;
  final String specialty;
  final String workplace;
  final String imageUrl;
  final int percentage;
  final String doctorId;

  const DoctorCardInList(
      {super.key,
      required this.screenWidth,
      required this.screenHeight,
      required this.name,
      required this.specialty,
      required this.workplace,
      required this.imageUrl,
      required this.percentage,
      required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailScreen(doctorId: doctorId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.thumb_up,
                          color: Colors.blue, size: screenWidth * 0.05),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        '$percentage% hài lòng',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    'Chuyên khoa: $specialty',
                    style: TextStyle(fontSize: screenWidth * 0.03),
                  ),
                  Text(
                    'Công tác: $workplace',
                    style: TextStyle(fontSize: screenWidth * 0.03),
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
