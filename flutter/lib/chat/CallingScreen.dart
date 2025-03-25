import 'dart:async';
import 'package:flutter/material.dart';

class CallingScreen extends StatefulWidget {
  final String receiverName;
  final String receiverImage;

  const CallingScreen(
      {super.key, required this.receiverName, required this.receiverImage});

  @override
  _CallingScreenState createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  int dotCount = 0;
  late Timer _timer;
  String callStatus = "Đang gọi";
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    _startTimeout(); // Bắt đầu đếm thời gian cuộc gọi
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startDotAnimation() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
      });
    });
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      setState(() {
        callStatus = "Người nhận không liên lạc được";
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    });
  }

  void _endCall() {
    _timeoutTimer?.cancel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: screenWidth * 0.25,
                backgroundImage: AssetImage(widget.receiverImage),
                backgroundColor: Color(0xFF119CF0),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                widget.receiverName,
                style: TextStyle(
                    fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                "$callStatus${callStatus == "Đang gọi" ? '.' * dotCount : ''}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: screenWidth * 0.05, color: Colors.grey[700]),
              ),
            ],
          ),
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenWidth * 0.1),
              child: CircleAvatar(
                radius: screenWidth * 0.08,
                backgroundColor: Colors.red,
                child: IconButton(
                    icon: Icon(Icons.call_end,
                        color: Colors.white, size: screenWidth * 0.1),
                    onPressed: _endCall),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
