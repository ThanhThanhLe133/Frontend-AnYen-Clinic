import 'package:anyen_clinic/appointment/widget/appointmentConnectedCard.dart';
import 'package:flutter/material.dart';

class ConnectedAppointmentScreen extends StatelessWidget {
  const ConnectedAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppointmentConnectedCard(
          isOnline: true,
          date: "05/03/2025",
          time: "9:00",
          status: "Đã hoàn thành",
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        AppointmentConnectedCard(
          isOnline: false,
          date: "05/03/2025",
          time: "9:00",
          status: "Sắp tới",
        ),
      ],
    );
  }
}
