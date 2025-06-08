import 'dart:async';
import 'dart:io';
import 'package:ayclinic_doctor_admin/DOCTOR/chat/signalingService.dart';
import 'package:ayclinic_doctor_admin/storage.dart';
import 'package:ayclinic_doctor_admin/utils/jwt_utils.dart';
import 'package:ayclinic_doctor_admin/widget/chat_widget/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key, required this.roomId});
  final String roomId;
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
  final signaling = SignalingService();

  @override
  void initState() {
    super.initState();
    webSocketService = ref.read(webSocketServiceProvider);
    initializeChat();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> initializeChat() async {
    setState(() {
      isConnecting = true;
    });

    try {
      // Get access token
      String? accessToken = await getAccessToken();

      // Get user ID
      currentUserId = await jwtUtils.getUserId();
      if (currentUserId == null) {
        showErrorSnackBar('Failed to get user information');
        return;
      }

      await setupWebSocket(accessToken!);
    } catch (e) {
      showErrorSnackBar('Error initializing chat: $e');
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  Future<void> setupWebSocket(String accessToken) async {
    try {
      String token = accessToken.replaceFirst("Bearer ", "");

      await webSocketService.connect(
        token,
        onConnect: () async {
          signaling.onSendIceCandidate = (candidateData) {
            webSocketService.emit('ice-candidate', candidateData);
          };

          // Lắng nghe ICE candidate từ server
          webSocketService.onReceiveIceCandidate((data) {
            signaling.addCandidate(data['candidate']);
          });

          // Lắng nghe offer từ server
          webSocketService.onReceiveOffer((data) async {
            final fromUserId = data['from'];
            final remoteSdp = data['sdp'];

            print('📞 Nhận offer từ $fromUserId');

            // Thiết lập kết nối peer và trả lời offer
            await signaling.setRemoteDescription(remoteSdp);
            final answerSdp = await signaling.createAnswer();

            webSocketService.onReceiveOffer((data) async {
              final fromUserId = data['from'];
              final remoteSdp = data['sdp'];

              print('📞 Nhận offer từ $fromUserId');

              await signaling.setRemoteDescription(remoteSdp);

              final answer = await signaling.createAnswer();

              webSocketService.sendAnswer(fromUserId, answer);
            });
          });

          // Lắng nghe answer từ server
          webSocketService.onReceiveAnswer((data) async {
            final remoteSdp = data['sdp'];
            print('✅ Nhận answer');
            await signaling.setRemoteDescription(remoteSdp);
          });

          showSuccessSnackBar('Connected to chat server');
        },
        onError: (error) {
          print('❌ WebSocket connection error: $error');
          String errorMessage = 'Connection error';
          if (error is SocketException) {
            errorMessage =
                'Cannot connect to server. Please check if the server is running.';
          } else {
            errorMessage = error.toString();
          }
          showErrorSnackBar(errorMessage, showRetry: true);
        },
        onDisconnect: () {
          print('🔌 WebSocket disconnected');

          showErrorSnackBar('Disconnected from chat server', showRetry: true);
        },
      );

      // Listen for user joined events
      webSocketService.onEndCall((data) {
        print('👋 User joined: $data');
        showInfoSnackBar('Cuộc gọi kết thúc!');
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

  Future<void> endCall() async {
    signaling.close();
    webSocketService.endCall(widget.roomId);
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
                  await initializeChat();
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
