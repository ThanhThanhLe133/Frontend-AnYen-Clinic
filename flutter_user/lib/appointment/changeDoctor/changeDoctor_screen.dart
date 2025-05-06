import 'package:anyen_clinic/appointment/changeDoctor/Doctor_List.dart';
import 'package:flutter/material.dart';

class ChangeDoctorScreen extends StatelessWidget {
  const ChangeDoctorScreen({
    super.key,
    required this.doctorId,
  });
  final String doctorId;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;
    bool isSelected = true;
    return StatefulBuilder(builder: (context, setState) {
      return Scaffold(
          backgroundColor: Colors.white, body: DoctorList(doctorId: doctorId));
    });
  }
}
