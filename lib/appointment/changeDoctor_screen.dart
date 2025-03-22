import 'package:anyen_clinic/doctor/list_doctor_screen.dart';
import 'package:flutter/material.dart';

class ChangeDoctorScreen extends StatelessWidget {
  const ChangeDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    bool isSelected = true;
    return StatefulBuilder(builder: (context, setState) {
      return Scaffold(backgroundColor: Colors.white, body: DoctorListScreen());
    });
  }
}
