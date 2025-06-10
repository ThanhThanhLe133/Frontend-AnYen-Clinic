import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:anyen_clinic/chat/services/SignalingService.dart';
import 'package:anyen_clinic/chat/websocket_service.dart';
import 'package:anyen_clinic/storage.dart';
import 'package:anyen_clinic/utils/jwt_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key, required this.roomId, required this.signaling});
  final String roomId;
  final SignalingService signaling;
  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
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
  late BuildContext rootContext;

  @override
  void initState() {
    super.initState();
    webSocketService = ref.read(webSocketServiceProvider);
    signaling = widget.signaling;
    startTimer();
    initEverything();
  }

  Future<void> initEverything() async {
    await initRenderers();

    currentUserId = await jwtUtils.getUserId();
    if (currentUserId == null) {
      showErrorSnackBar('Failed to get user information');
      return;
    }

    await setupWebSocket();
  }

  @override
  void dispose() {
    timer?.cancel();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> setupWebSocket() async {
    try {
      if (signaling.localStream != null) {
        localRenderer.srcObject = signaling.localStream;
      }

      signaling.onAddRemoteStream = (MediaStream remoteStream) {
        setState(() {
          remoteRenderer.srcObject = remoteStream;
        });
      };

      signaling.onSendIceCandidate = (RTCIceCandidate candidate) {
        showSuccessSnackBar('sending call');
        webSocketService.sendIceCandidate(widget.roomId, candidate);
      };

      // Lắng nghe ICE candidate từ server
      webSocketService.onReceiveIceCandidate((data) {
        showSuccessSnackBar('receive call');
        if (data['candidate'] != null) {
          signaling.addCandidate(data['candidate']);
        } else {
          print('❌ Candidate data invalid or missing');
        }
      });

      // Listen for end call
      webSocketService.onEndCall((data) {
        showInfoSnackBar('Cuộc gọi kết thúc!');
        if (data['sender'] != currentUserId) {
          endCall(rootContext, false);
        }
      });

      // Listen for user joined events
      webSocketService.onUserJoined((data) {
        print('👋 User joined: $data');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('A user joined the chat');
        }
      });

      // Listen for user left events
      webSocketService.onUserLeft((data) {
        print('👋 User left: $data');
        if (data['sender'] != currentUserId) {
          showInfoSnackBar('A user left the chat');
        }
      });

      // Listen for errors
      webSocketService.onError((error) {
        print('❌ WebSocket error: $error');
        showErrorSnackBar('Chat error: $error');
      });
    } catch (e) {
      print('❌ Error setting up WebSocket: $e');
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    // Get access token
    String? refreshToken = await getRefreshToken();
    final refreshRes = await http.post(
      Uri.parse('$apiUrl/auth/refresh-token'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (refreshRes.statusCode == 200) {
      final respond = jsonDecode(refreshRes.body);
      final newAccessToken = respond['access_token'];
      final newRefreshToken = respond['refresh_token'];

      // Lưu token mới
      if (newAccessToken != null) await saveAccessToken(newAccessToken);
      if (newRefreshToken != null) await saveRefreshToken(newRefreshToken);
    } else {
      showErrorSnackBar('Failed to get refresh token: ${refreshRes.body}');
      throw Exception('Failed to refresh token: ${refreshRes.body}');
    }
    await setupWebSocket();
  }

  Future<void> endCall(BuildContext context, bool isSender) async {
    signaling.close();
    if (isSender) webSocketService.endCall(widget.roomId);

    Navigator.pop(context);
  }

  void showErrorSnackBar(String message, {bool showRetry = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: showRetry
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () async {
                  await refreshToken();
                },
              )
            : null,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          isVideoOn
              ? Expanded(
                  child: Stack(
                    children: [
                      RTCVideoView(remoteRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                      Positioned(
                        right: 20,
                        top: 20,
                        width: 100,
                        height: 150,
                        child: RTCVideoView(localRenderer, mirror: true),
                      ),
                    ],
                  ),
                )
              : Column(
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
                      isMuted = !isMuted; // Đảo trạng thái Mute
                    });
                    if (isMuted) {
                      signaling.toggleMicrophone(false);
                    } else {
                      signaling.toggleMicrophone(true);
                    }
                  },
                  screenWidth,
                ),
                SizedBox(width: 30),
                buildCallButton(Icons.call_end, Colors.red, () {
                  endCall(context, true);
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
