import 'package:anyen_clinic/appointment/widget/appointmentConnectingCard%20copy.dart';
import 'package:flutter/material.dart';

class ConnectingAppointmentScreen extends StatelessWidget {
  const ConnectingAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppointmentConnectingCard(
          isOnline: true,
          date: "05/03/2025",
          time: "9:00",
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        AppointmentConnectingCard(
          isOnline: false,
          date: "05/03/2025",
          time: "9:00",
        ),
      ],
    );
  }
}
