import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:anyen_clinic/chat/services/SignalingService.dart';
import 'package:anyen_clinic/chat/websocket_service.dart';
import 'package:anyen_clinic/dialog/snackBar.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/utils/jwt_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen(
      {super.key,
      required this.roomId,
      required this.signaling,
      required this.isVideoCall,
      required this.webSocketService});
  final String roomId;
  final SignalingService signaling;
  final bool isVideoCall;
  final WebSocketService webSocketService;
  @override
  ConsumerState<CallScreen> createState() => CallScreenState();
}

class CallScreenState extends ConsumerState<CallScreen> {
  int seconds = 0;
  Timer? timer;
  bool isVideoOn = true;
  bool isMuted = false;
  bool isConnecting = false;
  String? currentUserId;

  late WebSocketService webSocketService;
  SignalingService signaling = SignalingService();

  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  static BuildContext? rootContext;
  double localVideoPosX = 20;
  double localVideoPosY = 20;

  @override
  void initState() {
    super.initState();
    signaling = widget.signaling;
    remoteRenderer.initialize();
    localRenderer.initialize();

    isVideoOn = widget.isVideoCall;
    webSocketService = widget.webSocketService;
    startTimer();
    initEverything();
  }

  static void close() {
    if (rootContext != null) {
      Navigator.of(rootContext!).pop();
    }
  }

  Future<void> initEverything() async {
    currentUserId = await jwtUtils.getUserId();
    if (currentUserId == null) {
      showErrorSnackBar('Failed to get user information', context);
      return;
    }
    // await setupWebSocket();
    if (signaling.localStream != null) {
      print("Local stream is not null");
      localRenderer.srcObject = signaling.localStream;
    }
    if (signaling.remoteStream != null) {
      print("Remote stream is not null");
      remoteRenderer.srcObject = signaling.remoteStream;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  // Future<void> setupWebSocket() async {
  //   if (!widget.isVideoCall) {
  //     localRenderer.srcObject = null;
  //     remoteRenderer.srcObject = null;
  //   } else {
  //     if (signaling.localStream != null) {
  //       localRenderer.srcObject = signaling.localStream;
  //     }
  //   }
  //   try {
  //     if (signaling.localStream != null) {
  //       localRenderer.srcObject = signaling.localStream;
  //     }

  //     signaling.onAddRemoteStream = (MediaStream remoteStream) {
  //       setState(() {
  //         remoteRenderer.srcObject = remoteStream;
  //       });
  //     };
  //   } catch (e) {
  //     print('❌ Error setting up WebSocket: $e');
  //     rethrow;
  //   }
  // }

  Future<void> endCall(BuildContext context, bool isSender) async {
    if (isSender) webSocketService.endCall();
    Navigator.pop(context);
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
    rootContext = context;
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
      body: Stack(
        children: [
          // video của đối phương full màn hoặc ảnh nếu không video
          remoteRenderer.srcObject != null
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: RTCVideoView(
                      remoteRenderer,
                      mirror: false,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.25,
                        backgroundImage: AssetImage("assets/images/doctor.png"),
                        backgroundColor: Color(0xFF119CF0),
                      ),
                      SizedBox(height: screenWidth * 0.03),
                    ],
                  ),
                ),
          // video của bạn, draggable ở phía trên
          Positioned(
            left: localVideoPosX,
            top: localVideoPosY,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isVideoOn
                    ? RTCVideoView(
                        localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : Container(
                        color: Colors.black87,
                        child: Center(
                          child: Icon(Icons.videocam_off, color: Colors.white),
                        ),
                      ),
              ),
            ),
          ),

          Positioned(
            bottom: 140, // cao hơn nút khoảng 100px
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "User1",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Text(
                  formatTime(seconds),
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.grey[400],
                  ),
                )
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
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
                    if (isVideoOn) {
                      signaling.toggleCamera(true);
                    } else {
                      signaling.toggleCamera(false);
                    }
                  },
                  screenWidth,
                ),
                SizedBox(width: 30),
                buildCallButton(
                  isMuted ? Icons.mic_off : Icons.mic,
                  isMuted ? Colors.grey : Colors.blue,
                  () {
                    setState(() {
                      isMuted = !isMuted;
                    });
                    signaling.toggleMicrophone(!isMuted);
                  },
                  screenWidth,
                ),
                SizedBox(width: 30),
                buildCallButton(Icons.call_end, Colors.red, () {
                  endCall(context, true);
                }, screenWidth),
              ],
            ),
          )
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
