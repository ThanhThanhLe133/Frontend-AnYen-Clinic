import 'dart:async';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int seconds = 0;
  Timer? timer;
  bool isVideoOn = true;
  bool isMuted = false;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Color(0xFF9BA5AC)),
          iconSize: screenWidth * 0.08,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[50],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: screenWidth * 0.25,
                backgroundImage: AssetImage("assets/images/user.png"),
                backgroundColor: Color(0xFF119CF0),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                "User1",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                formatTime(seconds),
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCallButton(
                  isVideoOn ? Icons.videocam : Icons.videocam_off,
                  isVideoOn ? Colors.blue : Colors.grey,
                  () {
                    setState(() {
                      isVideoOn = !isVideoOn;
                    });
                    print("Video Call: ${isVideoOn ? "On" : "Off"}");
                  },
                  screenWidth,
                ),
                SizedBox(width: 30),
                buildCallButton(
                  isMuted ? Icons.mic_off : Icons.mic,
                  isMuted ? Colors.grey : Colors.blue,
                  () {
                    setState(() {
                      isMuted = !isMuted; // Đảo trạng thái Mute
                    });
                    print("Mute: ${isMuted ? "On" : "Off"}");
                  },
                  screenWidth,
                ),
                SizedBox(width: 30),
                buildCallButton(Icons.call_end, Colors.red, () {
                  Navigator.pop(context);
                }, screenWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget nút tròn
  Widget buildCallButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
    double screenWidth,
  ) {
    return CircleAvatar(
      radius: screenWidth * 0.08,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: screenWidth * 0.1),
        onPressed: onPressed,
      ),
    );
  }
}
